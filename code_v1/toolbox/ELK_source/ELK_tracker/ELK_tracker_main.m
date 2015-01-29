% lk tracker
function ELK_tracker_main(prm)

global ESC;
ESC = false;
%% init
clc;
if nargin==0 || isempty(prm)
    prm = loadDefaultParams;
end
tstamp = [];
if prm.add_tstamp
    tstamp = ['_' datestr(clock,30)];
end
if ~exist(prm.outputDir,'dir')
    mkdir(prm.outputDir);
end
resfile = fullfile(prm.outputDir,[prm.runName tstamp '.txt']);
fid = fopen(resfile,'w');fclose(fid);
imdir = prm.inputDir;
imfiles = getFrameList(imdir);
im = imread(fullfile(imdir,imfiles(prm.initFrame).name));
if size(im,3)==1
   prm.lkprm.ChannelsUsed =[ 1 0 0];  % use only a single channel - intensity
end

if prm.START_FROM_GT && exist(prm.annFile,'file');
    gt = load(prm.annFile);
    prm.target0 = gt(prm.initFrame,1:4);
    prm.target0(1:2)= prm.target0(1:2)-1;
else
    prm.target0 = get_initial_target_from_user(im,prm);
end
save([resfile(1:end-4) '_prm.mat'],'prm');

if size(im,3)==1
    im_lab = double(im);
elseif sum(sum(im(:,:,2)-im(:,:,3)))==0
    im_lab = double(im(:,:,1));
    prm.lkprm.ChannelsUsed =[ 1 0 0];
else
    im_lab = double(rgb2ycbcr(im));
end

target = init_target(im_lab,prm.target0);
PT=[]; FirstTemplateFlag=1;    % The first template is kept for optional late usage

% train initial FG/BG model
[roi,bbox,~] = setROI(target,round(prm.lkprm.lkROI*max(size(target.T))));
[~,~,classifier] = FG_BG_model(im_lab(roi(2):roi(4),roi(1):roi(3),:),'train',prm.fgbg,bbox,[],[]);

% Compute initial template likelihood map
[pr_T_fg,pr_T_bg,~] = FG_BG_model(target.T,'test',prm.fgbg,[],classifier,[]);

% Compute intial weights (an E-step) and model parameters (error variances, priors)
Theta.Vars=[];
if ~isfield(prm.lkprm,'FGBGPriors') || prm.lkprm.FGBGPriors==0  % if there is no prior - use equal prior of 0.5
    prm.lkprm.InitFGPrior=0.5;
end
Theta.FGPrior=prm.lkprm.InitFGPrior;
[Q, LL(prm.initFrame), Theta] = calculateP_andLL(target.T,target.T,Theta,[],prm,classifier,pr_T_fg,pr_T_bg,im_lab(roi(2):roi(4),roi(1):roi(3),:));

% init Kalman filter matrices
if prm.USE_KALMAN
    switch prm.kalman_dynamic_model
        case 'zero_motion'
            % state = [x,y]
            F = eye(3);
            X_pred = [target.p(5); target.p(6); target.p(1)];
        case 'const_speed'
            % state = [x,dx/dt,y,dy/dt]
            F = eye(5);
            F(1,2) = 1;
            F(3,4) = 1;
            X_pred = [target.p(5); 0; target.p(6); 0; target.p(1)];
    end
    Q_kf = diag(prm.Q_kf);
    P_kf = diag(prm.P_kf);
end

% display results
disp_prm.mode = 'Tr';
if (prm.DisplayGT) gt_rect=gt(prm.initFrame,1:4); else gt_rcet=[]; end
disp_prm = displayTrackingReuslts(im,target,1,disp_prm,prm.initFrame, gt_rect);
% save results to file
v = target.verticesOut;
writeResToFile(resfile,[1,vert2rect([v(1,:),v(2,:)])]);

Tout = target.T;
not_occ = 1;

szT = [size(target.T,2);size(target.T,1)];
combined_err_est = zeros(length(imfiles) ,1);
tmp_update = false(length(imfiles) ,1);
tmp_update(1) = true;
is_occ = false(length(imfiles) ,1);
is_occ(1:prm.initFrame-1)
occ_th = zeros(length(imfiles) ,1);
occ_th(1) = prm.occ_th;
Tfg_perc = ones(length(imfiles) ,1);

if prm.initFrame >1
    is_occ(1:prm.initFrame-1) = true;
    combined_err_est(1:prm.initFrame-1) = prm.occ_th;
end

%% main tracking loop
lkprm = prm.lkprm;
for frm = (prm.initFrame+1):length(imfiles)
    if ESC
        break;
    end
    
    %% load image
    im = imread(fullfile(imdir,imfiles(frm).name));
    if size(im,3)==1
        im_lab = double(im);
    elseif sum(sum(im(:,:,2)-im(:,:,3)))==0
        im_lab = double(im(:,:,1));
    else
        im_lab = double(rgb2ycbcr(im));
    end
    
    %% Set New Image Region Of Interest (ROI)
    [roi,tr_bbox,dxy] = setROI(target,round(prm.lkprm.lkROI*max(size(target.T))));
    lk_im = im_lab(roi(2):roi(4),roi(1):roi(3),:);
    
    % compute image FG/BG liklihood
    [pr_I_fg,pr_I_bg,~] = FG_BG_model(lk_im,'test',prm.fgbg,[],classifier,[]);
    
    %% LK  
    % Run_lk
    [p,Tout,rmse,w, Stats, NewVars, Scales] = ...
        multiScaleLK(lk_im,target.T,pr_I_fg,pr_I_bg,Q,target.p-dxy,lkprm,Theta.Vars);
    p = p+dxy;    
    disp_prm.mode = 'Tr-Scl';        
    [combined_err_est(frm), Tfg_perc(frm), Tout_fg]  = ...
        ComputeGoodnessScores( Tout, target, prm ,   classifier );    
    
    %% Kalman filter
    if prm.USE_KALMAN
        R_kf = diag(prm.R_kf*combined_err_est(frm));
        idx = find(~is_occ(1:frm),prm.occ_med_samples,'last');
        occ_th0 = median(combined_err_est(idx));
        %std_th0 = std(combined_err_est(idx));
        Q_kf = diag(prm.Q_kf*(occ_th0/4));
        % predict new state
        switch prm.kalman_dynamic_model
            case 'zero_motion'
                X = [p(5); p(6); p(1)];
                [X_pred,P_kf] = kalman_filter(X_pred,X,P_kf,Q_kf,R_kf,F);
                p_pred(5:6) = X_pred(1:2);
                p_pred(1) = X_pred(3);
                p_pred(4) = X_pred(3);
            case 'const_speed'
                dx = p(5)-target.p(5);
                dy = p(6)-target.p(6);
                X = [p(5); dx; p(6); dy; p(1)];
                [X_pred,P_kf] = kalman_filter(X_pred,X,P_kf,Q_kf,R_kf,F);
                p_pred(5) = X_pred(1);
                p_pred(6) = X_pred(3);
                p_pred(1) = X_pred(5);
                p_pred(4) = X_pred(5);
        end       
        p = p_pred';
    end
    
    
    %% ZOH
    rct = round(vert2rect([target.verticesOut(1,:),target.verticesOut(2,:)]));
    rct(3:4) = [size(target.T,2)-1,size(target.T,1)-1];
    ZerosPad=zeros(1,length(size(im_lab))-2);
    im_lab_padd=zeros(size(im_lab)+[30 30 ZerosPad]); im_lab_padd(16:16+size(im_lab,1)-1,16:16+size(im_lab,2)-1,:)=im_lab;
    Tzoh = im_lab_padd((rct(2)+15):(rct(2)+rct(4)+15),(rct(1)+15):(rct(1)+rct(3)+15),:);    
    [zoh_err_est, zoh_perc]  = ...
        ComputeGoodnessScores( Tzoh, target, prm , classifier );
    
    %% Occlusion handling
    if ~prm.DO_OCC
        % Update the error std parameter for the feature channels
        if prm.ESTIMATE_SIG_ERR || isempty(Theta.Vars)
            Theta.Vars=NewVars;
        end
        % Compute the objecthood probabilities and log-likelihood (E step)
        [ Q, LL(frm), Theta ] = calculateP_andLL(Tout,target.T, Theta,Scales,prm,classifier,pr_T_fg,pr_T_bg,lk_im);
            
        % Update the target transformation
        target = updateTarget(target,p);
    else
        % Compute occlusion threshold
        if prm.ADDAPTIVE_OCC_TH
            idx = find(~is_occ(1:frm),prm.occ_med_samples,'last');
            occ_th0 = median(combined_err_est(idx));
            a = numel(idx)/prm.occ_med_samples;
            occ_th0 = a*occ_th0 + (1-a)*prm.occ_th;
            occ_th0 = min(max(occ_th0,prm.occ_th_min),prm.occ_th_max);
            occ_th(frm) = prm.occTHGain*occ_th0;
            if is_occ(frm-1)
                occ_th(frm) = occ_th(frm)*prm.occ_recovery_th_gain;
            end
        else
            occ_th(frm) = prm.occ_th;
        end
        
        % Check for occluison
        if (combined_err_est(frm)<occ_th(frm) || zoh_err_est<occ_th(frm)) && Tfg_perc(frm) >= prm.w_percentile_th
            is_occ(frm) = false;    % No occlusion
            if zoh_err_est>=combined_err_est(frm)
                % Update the error std parameter for the feature channels
                if prm.ESTIMATE_SIG_ERR || isempty(Theta.Vars)
                    Theta.Vars=NewVars;
                end
                % Compute the objecthood probabilities and log-likelihood (E step)
                [ Q, LL(frm), Theta ] = calculateP_andLL(Tout,target.T, Theta,Scales,prm,classifier,pr_T_fg,pr_T_bg, lk_im);          
                % Update the target transformation
                target = updateTarget(target,p);
            else  % ZOH declared
                disp_prm.mode = 'ZOH';
            end
        else
            is_occ(frm) = true; % Occlusion declared
            disp_prm.mode = 'Occ-Lost';
            
            % try to recover using exhaustive search for Q function maxima (2D tr only)
            [ T,I] = rescale_TandI(target.T,lk_im,prm.lkprm); % rescale
            
            % resize template acording to last known scale
            w = Q.w;
            wF = Q.wI;
            wB = 1-Q.wI;
            if prm.occResizeTemplate
                scl = 1+target.p(1);
                T   = imresize(T,scl);
                w   = imresize(w,scl);
                wF  = imresize(wF,scl);
                wB  = imresize(wB,scl);
            end
            
            [x_max,y_max,x_max_tmp,y_max_tmp] = compute_Q_map_pyramid(I,pr_I_fg,pr_I_bg,T,w,wF,wB,Theta.Vars,target.p(5)-dxy(5),target.p(6)-dxy(6),prm.occDispResults);
            
            x_max = x_max+dxy(5);
            y_max = y_max+dxy(6);
            ZerosPad=zeros(1,length(size(im_lab))-2);
            im_lab_padd=zeros(size(im_lab)+[30 30 ZerosPad]); im_lab_padd(16:16+size(im_lab,1)-1,16:16+size(im_lab,2)-1,:)=im_lab;
            Tout_exh = im_lab_padd((rct(2)+15):(rct(2)+rct(4)+15),(rct(1)+15):(rct(1)+rct(3)+15),:);
            
            [ err_est, Tout_fg_perc_exh  ] = ...
                ComputeGoodnessScores( Tout_exh, target, prm ,  classifier );
            
            if prm.occExhasutSearchWithOldTemplates
                % perform exhaustive search with old templates
                if ~isempty(PT)
                    for ii=1:length(PT)
                        [syT,sxT, NofC ] = size(target.T);
                        T = imresize(PT(ii).T,[syT,sxT]);
                        [ T,~] = rescale_TandI(T,lk_im,prm.lkprm); % rescale
                        wT = imresize(PT(ii).W,[syT,sxT]);
                        wF = Q.wI;
                        wB = 1-Q.wI;
                        w = wF.*wT;                        
                        if prm.occResizeTemplate
                            scl = 1+target.p(1);
                            T   = imresize(T,scl);
                            w   = imresize(w,scl);
                            wF  = imresize(wF,scl);
                            wB  = imresize(wB,scl);
                        end
                        
                        [x_max_oldT(ii),y_max_oldT(ii),~,~] = compute_Q_map_pyramid(I,pr_I_fg,pr_I_bg,T,w,wF,wB,Theta.Vars,target.p(5)-dxy(5),target.p(6)-dxy(6),prm.occDispResults);
                        
                        x_max_oldT(ii) = x_max_oldT(ii)+dxy(5);
                        y_max_oldT(ii) = y_max_oldT(ii)+dxy(6);
                        ZerosPad=zeros(1,length(size(im_lab))-2);
                        im_lab_padd=zeros(size(im_lab)+[30 30 ZerosPad]); im_lab_padd(16:16+size(im_lab,1)-1,16:16+size(im_lab,2)-1,:)=im_lab;
                        Tout_exh_oldT{ii} = im_lab_padd((rct(2)+15):(rct(2)+rct(4)+15),(rct(1)+15):(rct(1)+rct(3)+15),:);
                        
                        target_tmp = target;
                        target_tmp.T = T;
                        [ err_est(ii+1), Tout_fg_perc_exh_oldT{ii}  ] = ...
                            ComputeGoodnessScores( Tout_exh_oldT{ii}, target_tmp, prm , classifier ); 
                    end
                    [err_est,idx] = min(err_est);
                    if idx>1
                        Tout_fg_perc_exh = Tout_fg_perc_exh_oldT{idx-1};
                        Tout_exh = Tout_exh_oldT{idx-1};
                        x_max = x_max_oldT(idx-1);
                        y_max = y_max_oldT(idx-1);
                    end                    
                end
            end
                        
            % check if both Q function have the same maximum
            if abs(x_max-x_max_tmp)<=1 && abs(y_max-y_max_tmp)<=1 && prm.occCheckTemplateAndLL
                x_max_tmp = x_max_tmp+dxy(5);
                y_max_tmp = y_max_tmp+dxy(6);
                Tout_exh_tmp = im_lab(y_max_tmp:min(y_max_tmp+size(T,1)-1,size(im_lab,1)),x_max_tmp:min(x_max_tmp+size(T,2)-1,size(im_lab,2)),:);
                
                [ err_est_tmp, Tout_fg_perc_exh_tmp ] = ...
                    ComputeGoodnessScores( Tout_exh_tmp, target, prm ,   classifier );
                
                if err_est_tmp<err_est
                    err_est = err_est_tmp;
                    Tout_exh = Tout_exh_tmp;
                    Tout_fg_perc_exh = Tout_fg_perc_exh_tmp;
                end
            end
            
            lk_err = combined_err_est(frm);
            exh_search_err = err_est;
            zoh_err = zoh_err_est;
            
            % check which method produced min error
            if lk_err<=exh_search_err && lk_err<=zoh_err
                % LK is the best solution
                target = updateTarget(target,p);
                TOutBest = Tout;
                perc =  Tfg_perc(frm);
                fin_err = lk_err;
            elseif zoh_err<=exh_search_err && zoh_err<=lk_err
                % ZOH is the best solution
                % Do nothing leave target as-is
                TOutBest = Tzoh;
                perc = zoh_perc;
                fin_err = zoh_err;
                combined_err_est(frm)=fin_err;
            else
                % Exhaustive search is the best solution
                p_tmp = target.p;
                p_tmp(5:6) = [x_max;y_max];
                target = updateTarget(target,p_tmp);
                TOutBest = Tout_exh;
                perc = Tout_fg_perc_exh;
                fin_err = exh_search_err;
                combined_err_est(frm)=fin_err;
            end
            
            if perc >= prm.w_percentile_th
                if fin_err < occ_th(frm) || perc >= 0.9
                    is_occ(frm) = false;
                    [ Q, LL(frm), Theta ] = calculateP_andLL(TOutBest,target.T, Theta,Scales,prm,classifier,pr_T_fg,pr_T_bg,lk_im);
                    fprintf('Recovered from occlusion frm %04d\n',frm);
                end
                disp_prm.mode = 'Occ-Trk';
            end
        end
    end
    
    %% Template update
    % Update the error std parameter for the feature channels
    if prm.ESTIMATE_SIG_ERR && ~is_occ(frm)
        Theta.Vars=NewVars;
    end
    
    % Template update
    TemplateUpdateFlag=0;
    NoOcclusion = all(~is_occ(max(1,frm-prm.occ_recovery_min_interval_for_update):frm));
    HighObjecthood=Tfg_perc(frm) >= prm.w_percentile_th;
    TimeHasCome = (mod(frm,prm.template_update_freq)==0 || (frm-find(tmp_update,1,'last')>prm.template_update_freq));
    if   (TimeHasCome && NoOcclusion && HighObjecthood)
        
        tmp_update(frm) = true;
        TemplateUpdateFlag=1;
        fprintf('<<<   updating template frm %04d   >>>\n',frm);
        
        % Check previous templates: Are they better?
        TemplateHaBeenUpdated=0;
        if prm.CheckOldTemplatesBeforeUpdate
            
            % Keeping templates for later usage (first or previous)
            if FirstTemplateFlag
                PT(1).W=Q.wT;
                PT(1).T=target.T;
            end
            if prm.KeepPrevTemplate && ~ FirstTemplateFlag
                PT(2).W=Q.wT;
                PT(2).T=target.T;
            end
            FirstTemplateFlag=0;
            
            % Check if old templates are helpful
            errPT=[]; percPT=[];
            if ~isempty(PT)
                for ii=1:length(PT)
                    % Prepare temporary Q (weights mask) and target (template) for past template
                    [syT,sxT, NofC ]=size(target.T);
                    tQ{ii}.wI = Q.wI;
                    tQ{ii}.wT=imresize(PT(ii).W,[syT,sxT]);  % Image weights according to the current image
                    tQ{ii}.w= tQ{ii}.wT.*tQ{ii}.wI;     %  objecthood weights according to their product
                    tTarget{ii}=target;
                    tTarget{ii}.T= imresize(PT(ii).T, [syT, sxT ]);
                    
                    % Try locating the target with the past tempalte
                    [PT_p{ii},tTout{ii}] = ...
                        multiScaleLK(lk_im,tTarget{ii}.T,pr_I_fg,pr_I_bg,tQ{ii},target.p-dxy,lkprm,Theta.Vars);
                    PT_p{ii} = PT_p{ii}+dxy;
                    [ errPT(ii), percPT(ii) ] = ...
                        ComputeGoodnessScores( tTout{ii}, tTarget{ii}, prm ,   classifier );
                end
                
                [minerr, minInd]=min(errPT); % get the best score
                if minerr<combined_err_est(frm) % Replace to an old template
                    if prm.UsePrevTemplatesThemselves
                        target = updateTarget(tTarget{minInd},PT_p{minInd});
                        Q= tQ{minInd};
                        Tout=tTout{minInd};
                        TemplateHaBeenUpdated=1; % Do not update the template to Tout
                    else
                        target = updateTarget(target,PT_p{minInd});
                        Q= tQ{minInd};
                    end
                end
            end         
        end
        
        % Update with a the current Tout
        if ~TemplateHaBeenUpdated
            target = init_target(im_lab,vert2rect([target.verticesOut(1,:),target.verticesOut(2,:)]));    % Change the template
            Q.wI = imresize(Q.wI,[size(target.T,1),size(target.T,2)]);
            Q.wT = imresize(Q.wT,[size(target.T,1),size(target.T,2)]);
            Q.w = imresize(Q.w,[size(target.T,1),size(target.T,2)]);
            Tout = target.T;
        end
    end
    
    %% FG/BG model update
    ModelUpdateFlag=0;
    TimeHasCome=(mod(frm,prm.fgbg_update_freq)==0 || (frm-find(tmp_update,1,'last')>prm.template_update_freq));
    if (TimeHasCome && NoOcclusion && HighObjecthood) || TemplateUpdateFlag
        
        % Get ROI and bounding box for the current image position
        [roi,bbox,~] = setROI(target,round(prm.lkprm.lkROI*max(size(target.T))));
        
        % Set objecthood mask to use in FG/Bg model training
        if prm.FGBGupdateWithWeights
            mask=Q.wI;
            if ~all( size(Q.wI) == [ bbox(4)-bbox(2)+1, bbox(3)-bbox(1)+1])
                mask=imresize(mask, [ bbox(4)-bbox(2)+1, bbox(3)-bbox(1)+1 ]);
            end
        else
            mask = [];
        end
        
        % FG/BG model update
        [~,~,classifier] = FG_BG_model(im_lab(roi(2):roi(4),roi(1):roi(3),:),'train',prm.fgbg,bbox,[], mask);
        ModelUpdateFlag=1;
    end
    
    % Update the template log-likelihood map if required
    if TemplateUpdateFlag || ModelUpdateFlag
        [pr_T_fg,pr_T_bg,~] = FG_BG_model(target.T,'test',prm.fgbg,[],classifier,[]);    % Recompute the templates log-likelihood
    end
    
    %% Outputs
    %display results    
    if prm.DisplayGT gt_rect=gt(frm,1:4); else gt_rcet=[]; end
    disp_prm = displayTrackingReuslts(im,target,frm,disp_prm,0,gt_rect);
    % write results
    v = target.verticesOut;
    writeResToFile(resfile,[frm,vert2rect([v(1,:),v(2,:)])]);
end

try
    close(10);
end
