% Input:
%   I -the Image
%   T- the template
%   pr_I_fg,pr_I_bg - the foreground and background likjlihood of the current image I
%   wI - the objecthood probability mask expected for the image, according to previous EM rounds
%   w - the objecthood probability of both template and image, according to previous EM rounds.
%   prm - th LK parameters
%   Vars - the variances of the channels used.
%   l - the level in the pyramid (used only for debug)
%
% Output:
%   p - the parameters of the found transformation

function [Tout,p,w, Stats, logicalCoords ] = colorLK_inv_comp_fast(I,T,pr_I_fg,pr_I_bg,wI,w,p,warps,prm,Vars,l)

lkEpsilon = prm.lkEpsilon;
lkMaxIter = prm.lkMaxIter;
w_fg=wI;    % forground image probability weights
w_bg=(1-wI); % background image probability weights
w_sum=sum(sum(w));

% Get image & template size
[sizTy,sizTx,sizTf] = size(T);
[sizIy,sizIx,sizIf] = size(I);
% Normalization factor for translation numeric stability
normFact = max(sizIy,sizIx);
p(5:6) = p(5:6)/normFact;

% Define Template coords. (homogeneos)
[xxT,yyT] = meshgrid(1:sizTx,1:sizTy);
xxT = xxT/normFact;
yyT = yyT/normFact;
XY = vertcat(xxT(:)' , yyT(:)' , ones(1,length(yyT(:)')));
TCorners = [ 1 sizTx sizTx 1;1 1 sizTy sizTy]/normFact;
TCorners = vertcat(TCorners,ones(1,4));

% Multiply variances by channel relevance probability
WVars= ChannelPR( Vars, prm ).*Vars;
if l>=prm.lkDoExhuastiveFromLevel
    
    % Determine the new scale of the template 
    W = setWarp(p);
    VerticesOut=(W*TCorners)*normFact;
    sizTy = round(VerticesOut(2,3)-VerticesOut(2,2))+1;   sizTx = round(VerticesOut(1,2)-VerticesOut(1,1))+1; 
    
    % Rescale the template
    T=imresize(T,[sizTy sizTx]);
    w=imresize(w,[sizTy sizTx]);
    w_fg=imresize(w_fg,[sizTy sizTx]);
    w_bg=imresize(w_bg,[sizTy sizTx]);
    [xxT,yyT] = meshgrid(1:sizTx,1:sizTy);
    xxT = xxT/normFact;
    yyT = yyT/normFact;
    XY = vertcat(xxT(:)' , yyT(:)' , ones(1,length(yyT(:)')));
    
    % Compute exhausive match map
    [x_max,y_max,Q] = compute_Q_map(I,pr_I_fg,pr_I_bg,T,w,w_fg,w_bg,WVars);
    
    % Set output: p, Tout and LogicalCoords according to the exhaustive search
    %Tout2 = I(y_max:y_max+sizTy-1,x_max:x_max+sizTx-1,:);
    p(5:6) = [x_max-1;y_max-1]/normFact;
    W = setWarp(p);
    warpXY = W*XY;
    for f = 1:sizTf
        % Resample Image & gradient images at required coords
        warpI(:,:,f) = resampleI(I(:,:,f),warpXY*normFact,[sizTy,sizTx],'zero');
        Weighted_MSE=sum(sum(w.*(warpI(:,:,f)-T(:,:,f)).^2));
        OptVars(1,f)=Weighted_MSE/w_sum;
    end % Feature-space Loop
    p(5:6) = p(5:6)*normFact;
    Tout = warpI;  % same as Tout2, but we are doing it this way to get the logical coords  
    logicalCoords = warpXY*normFact;
    Stats.OptVars = OptVars;
    Stats.Q=Q(y_max,x_max); Stats.Q1=nan; Stats.Q2=nan;
    return;
end

% Define Image coords.
[xxI,yyI] = meshgrid(1:sizIx,1:sizIy);
xxI = xxI/normFact;
yyI = yyI/normFact;
% Calculate template T gradients
[Tx,Ty] = gradient(T);
Tx = Tx*normFact;
Ty = Ty*normFact;
% Check if current scale is required
if all(warps==0)
    % Set  warp
    W = setWarp(p);
    % Warp coords.
    warpXY = W*XY;
    for f = 1:sizTf
        % Resample Image & gradient images at required coords
        warpI(:,:,f) = resampleI(I(:,:,f),warpXY*normFact,[sizTy,sizTx],'zero');
    end % Feature-space Loop
    Tout = warpI;
    p(5:6) = p(5:6)*normFact;
    return;
end

% Multi-transform Loop
for tr = 1:length(warps)
    % Check if current warp is enabled
    if warps(tr)
        Lambda=1;   % Used only if Levenberg Marquardt is applied
        convergFlag = 0;
        iter = 1;
        % Allocate memory for H & GD
        nWarpPrm = getNumOfWarpParams(tr);
        H = zeros(nWarpPrm);
        GD = zeros(nWarpPrm,1);
        % Pre-compute the Hessian componenet grad{T(W(x;0))}*(dW/dp)
        for f = 1:sizTf
            gradTdWdp{f}  = calcGradTdWdp(XY,Tx(:,:,f),Ty(:,:,f),tr);
        end
        % Gradient-Decent Loop
        Q=[];   % The Q function, progress through iterations
        while ~convergFlag && iter <= lkMaxIter
            % Initialize vars
            GD(:) = 0;
            RMS = 0;
            Q1=0;   % The square root term of the Q-function
            
            
            % Set  warp
            W = setWarp(p);
            % Warp coords.
            warpXY = W*XY;
            
            % resample probabilities related to image
            warp_pr_I_fg = resampleI(pr_I_fg,warpXY*normFact,[sizTy,sizTx],'zero');
            warp_pr_I_bg = resampleI(pr_I_bg,warpXY*normFact,[sizTy,sizTx],'zero');
            
            
            % Feature-space Loop
            for f = 1:sizTf
                if prm.ChannelsUsed(f)
                    % Resample Image & gradient images at required coords
                    warpI(:,:,f) = resampleI(I(:,:,f),warpXY*normFact,[sizTy,sizTx],'zero');
                    % Compute error variance
                    Weighted_MSE=sum(sum(w.*(warpI(:,:,f)-T(:,:,f)).^2));
                    OptVars(iter,f)=Weighted_MSE/w_sum;
                    if isfield(prm,'ErrorSTD_multiplier') && ~isempty(prm.ErrorSTD_multiplier)
                        OptVars(iter,f) = OptVars(iter,f)* prm.ErrorSTD_multiplier^2;
                    end
                    if prm.updateVarInLK
                        Vars(f)=OptVars(iter,f);
                        WVars= ChannelPR( Vars, prm ).*Vars;
                    end
                    % multiply the pixel weights by the channel's inverse sigma
                    wf=w/(2*WVars(f));   % wf- weights for feature channel
                    % Calculate error image (weighted) and SSD
                    errImg = wf.*(warpI(:,:,f)-T(:,:,f));   % Note: in theobjecthood-LK document notation the errorImg is (T-I) and (not (I-T), so the resulting GD here is -V in notation of the document
                    RMS = RMS + sqrt(mean(errImg(:).^2))/sizTf;
                    % Calculate gradieint decent component
                    GDC{f} = gradTdWdp{f}'*errImg(:); % gradient per component
                    GD = GD + GDC{f};
                    % Compute weighted hessian componenet
                    HC{f}= (repmat(wf(:),[1,size(gradTdWdp{f},2)]).*gradTdWdp{f})'*gradTdWdp{f};
                    H = H + HC{f};
                    % Compute the square root term of the Q function
                    Q1f(f)= -Weighted_MSE/(2*WVars(f)) - 0.5*log(WVars(f))*w_sum;    % weighted sum of square errors
                    Q1=Q1+Q1f(f);
                end
            end % Feature-space Loop
            
            % compute GD term additional log-probability terms
            log_warp_pr_I_fg=log(warp_pr_I_fg);
            [pr_FGx,pr_FGy] = gradient(log_warp_pr_I_fg);
            gradFGdWdp  = -calcGradTdWdp(XY,pr_FGx,pr_FGy,tr);
            V1=gradFGdWdp'*w_fg(:);
            log_warp_pr_I_bg=log(warp_pr_I_bg);
            [pr_BGx,pr_BGy] = gradient(log_warp_pr_I_bg);
            gradBGdWdp  = -calcGradTdWdp(XY,pr_BGx,pr_BGy,tr);
            V2=gradBGdWdp'*w_bg(:);
            
            if prm.USE_LOG_TERMS
                GD = GD + (V1+V2)/2;
                Q2 = sum(sum(w_fg.*log_warp_pr_I_fg + w_bg.*log_warp_pr_I_bg));   % the log-likelihood term of the Q-function
            else
                Q2 = 0;
            end
            
            % The Q function (the function we maximize in the LK iterations
            Q(iter)=Q2+Q1;  % Q should grow in each iteration
            Q1_Rec(iter)=Q1;  % Keep also the Q components per iteration
            Q2_Rec(iter)=Q2;
            GD_Rec{iter}= round([ [ GDC{:} ],[ V1 V2] ]);
            Vars_Rec(iter,:)=Vars;
            WVars_Rec(iter,:)=WVars;
            
            % Calculate dp
            if prm.GaussNewton==1
                dp = H\GD;%dp = inv(H)*GD;
                dp(isnan(dp)) = 0;
            else
                % update \Lambda
                if iter>1
                    if Q(end)-Q(end-1)<0
                        convergFlag=1;
                    elseif Q(end)-Q(end-1)<0.1
                        Lambda=Lambda*2;
                    elseif Q(end)-Q(end-1)>10
                        Lambda=Lambda/2;
                    end
                end
                if ~convergFlag
                    IH=inv(H);
                    dp = (IH+Lambda*diag(diag(IH)))*GD;     %dp = inv(H)*GD;
                    dp(isnan(dp)) = 0;
                else
                    dp=zeros(size(GD));
                end
            end
            dp_Rec{iter}=dp;
            
            pNew = updatep(p,dp,tr);
            % Check for convergence
            dpPercent = abs((pNew-p)./p);
            dpPercent(p==0) = pNew(p==0);
            if all(dpPercent<lkEpsilon)
                convergFlag = 1;
            else
                iter = iter+1;
            end
            p = pNew;            
        end % Gradient-Decent Loop
    end % Check if warp is enabled
end % Multi-transform Loop
% Set output vars.
p(5:6) = p(5:6)*normFact;
Tout = warpI;

% Prepare Stats strcuture output:
Stats.Q=Q;
Stats.Q1=Q1_Rec;
Stats.Q2=Q2_Rec;
Stats.OptVars=OptVars;
Stats.GR_Rec=GD_Rec;
Stats.Vars_Rec=Vars_Rec;
Stats.WVars_Rec=WVars_Rec;

% The (x,y) logical coordinates from which the pixels of TOUT are taken
logicalCoords=warpXY*normFact;

% =================================================================================

function gradTdWdp  = calcGradTdWdp(XY,Tx,Ty,warp)
% Calculate grad{I}(W(x;p))*(dW/dp)

Tx = Tx(:);
Ty = Ty(:);
x = XY(1,:)';
y = XY(2,:)';

switch warp
    case 1 %Translation
        gradTdWdp = horzcat(Tx, Ty);
    case 2 %Translation + uniform scale
        gradTdWdp = horzcat(Tx.*x + Ty.*y, Tx, Ty);
    case 3 %Translation + non-uniform scale
        gradTdWdp = horzcat(Tx.*x, Ty.*y, Tx, Ty);
    case 4 %Similarity
        gradTdWdp = horzcat(Tx.*x + Ty.*y, Tx.*(-y) + Ty.*x, Tx, Ty);
    case 5 %Affine
        gradTdWdp = horzcat(Tx.*x, Ty.*x, Tx.*y, Ty.*y, Tx, Ty);
end

% =================================================================================

function [nWarpPrm] = getNumOfWarpParams(warp)

switch warp
    case 1 % Translation'
        nWarpPrm = 2;
    case 2 % Translation + uniform scale
        nWarpPrm = 3;
    case 3 % Translation + non-uniform scale
        nWarpPrm = 4;
    case 4 % Similarity
        nWarpPrm = 4;
    case 5 % Affine - default
        nWarpPrm = 6;
end

%% =================================================================================
function [p] = setp(p,warp)

switch warp
    case 1 % Translation
        p = [0;0;0;0;p(1);p(2)];
    case 2 % Translation + uniform scale
        p = [p(1);0;0;p(1);p(2);p(3)];
    case 3 % Translation + non-uniform scale
        p = [p(1);0;0;p(2);p(3);p(4)];
    case 4 % Similarity
        p = [p(1);p(2);-p(2);p(1);p(3);p(4)];
    case 5 % Affine
        %do nothing
end

%% =================================================================================
function [p] = updatep(p,dp,warp)

W0 = setWarp(p);
dp_full = setp(dp,warp);
dW = setWarp(dp_full);
W = W0/dW;
W(3,:) = [];
p = W(:);
p(1) = p(1)-1;
p(4) = p(4)-1;
%% =================================================================================