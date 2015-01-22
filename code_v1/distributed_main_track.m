% Main distributed Script to run code on multiple servers, Needs to use the CheckAndUpdateSource.m first

% If I want a longer add files function to add all nessary files.
%  addincludes;
% clear all;close all;clc

%% Setup file to rule them all
setup_videoSaliency;

%% LOG FILE Creation
time_sig=datestr(clock,'yyyy_mm_dd_HH_MM');
if ~exist([saliency_dir,'\','logFiles'],'dir')
    mkdir([saliency_dir,'\','logFiles']);
end
log_filename=[saliency_dir,'\','logFiles','\',time_sig,'_log.txt'];
fileID=fopen(log_filename,'w');
clc; diary(log_filename);

%% Settings
DataRoot = diemDataRoot; % DIEM dataset is the data
uncVideoRoot = fullfile(DataRoot, 'video_unc'); % uncompress video.
gazeDataRoot = fullfile(DataRoot, 'gaze'); % gaze data from the DIEM.
cuts=load('\\CGM10\Users\ydishon\Documents\Video_Saliency\data\00_cuts.mat','cuts');
cuts=cuts.cuts;

% visualizations results
finalResultRoot = '\\CGM10\Users\ydishon\Documents\Video_Saliency\FinalResults\Track_v1\';
visRoot = fullfileCreate(finalResultRoot,'vis');

jumpType = 'all'; % 'cut' or 'gaze_jump' or 'random' or 'all'
sourceType = 'rect';
% measures = {'chisq', 'auc', 'cc', 'nss'};
measures = {'chisq', 'auc'};
%methods = {'PCA F','self','center','Dima','GBVS','PCA M'};
%methods = {'Tracking','self','PCA S','Dima','GBVS','PCA M'};
methods = {'Tracking','self','PCA S','PCAMPolar','PCAF_old','PCA M'};

% cache settings
% cache.root = fullfile(DataRoot, 'cache');
cache.frameRoot = fullfile(saveRoot, 'cache');
% cache.featureRoot = fullfileCreate(cache.root, '00_features_v6');
% cache.gazeRoot = fullfileCreate(cache.root, '00_gaze');
cache.renew = false;%true; %true; % use in case the preprocessing mechanism updated
% cache.renewFeatures = true; % use in case the feature extraction is updated
% cache.renewJumps = true; % recalculate the final result

% Gaze settings
% gazeParam.pointSigma = 10;

%% Training and testing settings
videos = videoListLoad(DataRoot, 'DIEM');
nv = length(videos);

% testIdx = 1:nv;
% testSubset = 1:length(testIdx);
testIdx = [6,8,10,11,12,14,15,16,34,42,44,48,53,54,55,59,70,74,83,84]; % used by Borji
testSubset = 1:length(testIdx);

% testSubset = 11:length(testIdx);
% testSubset = 9;
% jumpFromType = 'prev-int'; % 'center', 'gaze', 'prev-cand', 'prev-int'
visVideo = true;
candScale = 2; % Guassian scale index for candidate2map func.

%%%%%%%%% JUST FOR TO COMPLETE THE RUN OF THE 08/01/2015 for the distributed cache files %%%%%
lockFileFolder='\\CGM10\Users\ydishon\Documents\Video_Saliency\lockfiles\2015_01_04\';
lockfiles=dir([lockFileFolder,'*lockfile*']);
videos=[];
for k=1:length(lockfiles)
    runData=load([lockFileFolder,lockfiles(k).name]);
    if strcmp(runData.compname,getComputerName())
        str1=strsplit(lockfiles(k).name,'_lockfile');
        str1=str1(1);%strcat(str1(1),'.avi');
        videos=[videos;str1];
    end
end
testIdx=1:length(videos);
testSubset = 1:length(testIdx);
%%%%%%%%%% END JUST FOR TO COMPLETE THE RUN OF THE 08/01/2015%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% visualization
cmap = jet(256);
colors = [1 0 0;
    0 1 0;
    0 0 1;
    1 1 0;
    1 0 1;
    0.5 0.5 0.5;
    0 1 1];

%% configure all detectors
[gbvsParam, ofParam, poseletModel] = configureDetectors();

vers = version('-release');
verNum = str2double(vers(1:4));

if (~exist(visRoot, 'dir'))
    mkdir(visRoot);
end

%sim = cell(length(testSubset), 1);

%% TRY CATCH FOREACH of the servers
tstart=tic;%start_clock
warnNum=0;
video_count=0;
for ii=1:length(testIdx) % run for the length of the defined exp.
    lockfile = [lockfiles_folder,'\',videos{testIdx(ii)},'_lockfile','.mat'];
    if exist(lockfile,'file') % somebody already working on this file go to next one.
        continue;
    else % nobody works on the file - lock it and work on it
        dosave(lockfile,'compname',getComputerName());
    end
    try % MAIN ROUTINE to do.
        % PREPARE DATA Routine
        iv = testIdx(testSubset(ii));
        fprintf('Processing %s...\n ', videos{iv}); tic;
        
        % prepare video
        if (isunix) % use matlab video reader on Unix
            vr = VideoReaderMatlab(fullfile(uncVideoRoot, sprintf('%s.mat', videos{iv})));
        else
            if (verNum < 2011)
                vr = mmreader(fullfile(uncVideoRoot, sprintf('%s.avi', videos{iv})));
            else
                vr = VideoReader(fullfile(uncVideoRoot, sprintf('%s.avi', videos{iv})));
            end
        end
        m = vr.Height;
        n = vr.Width;
        videoLen = vr.numberOfFrames;
        param = struct('videoReader', vr);
        [X,Y] = meshgrid(1:n,1:m);
        
        % load jump frames (FOR MY IMP. LOAD 'all')
        %[jumpFrames, before, after] = jumpFramesLoad(DataRoot, iv, jumpType, 50, 30, videoLen - 30);
        % Going on all videos frames from 1 to VideoLen (Dmitry went from 30 to
        % VideoLen-30)
        [jumpFrames, before, after] = jumpFramesLoad(DataRoot, iv, jumpType, 50, 30, videoLen-30);
        
        % calculate the saliency maps from scrath
        %frIdx=1:vr.NumberOfFrames;
        %frIdx=30:(vr.NumberOfFrames-30);
        
        % JUST PROCESSFRAMES VER
        %preprocessFrames(param.videoReader, jumpFrames(frIdx), gbvsParam, ofParam, poseletModel, cache);
        
        % PROCESS FRARMES AND CALCULATE SIMILARITY TO GAZE VER
        % load gaze data
        s = load(fullfile(gazeDataRoot, sprintf('%s.mat', videos{iv}))); %george
        gazeData = s.data;
        clear s;
        %gazeParam.gazeData = gazeData.points;
        % 11/1/2015 - YD CHECK IF my selfsimilarity is doing alright
        %         if isfield(gazeData,'selfSimilarity')
        %             gazeData = rmfield(gazeData,'selfSimilarity');
        %         end
        % visualize
        videoFile = fullfile(visRoot, sprintf('%s.avi', videos{iv}));
        saveVideo = visVideo && (~exist(videoFile, 'file'));
        if (saveVideo && verNum >= 2012)
            vw = VideoWriter(videoFile, 'Motion JPEG AVI'); % 'Motion JPEG AVI' or 'Uncompressed AVI' or 'MPEG-4' on 2012a.
            open(vw);
        end
        
        try
            
            % compare
            frames = jumpFrames + after;
            indFr = find(frames <= videoLen);
            predMaps=zeros(m,n,length(indFr));
            sim = zeros(length(methods), length(measures), length(indFr));
            
            % initialize variables for tracker
            opt = struct('numsample',600, 'condenssig',0.25, 'ff',1, ...
                'batchsize',5, 'affsig',[9,9,.05,.05,.005,.001]);
            if ~isfield(opt,'tmplsize')   opt.tmplsize = [32,32];  end
            if ~isfield(opt,'numsample')  opt.numsample = 400;  end
            if ~isfield(opt,'affsig')     opt.affsig = [4,4,.02,.02,.005,.001];  end
            if ~isfield(opt,'condenssig') opt.condenssig = 0.01;  end
            
            if ~isfield(opt,'maxbasis')   opt.maxbasis = 16;  end
            if ~isfield(opt,'batchsize')  opt.batchsize = 5;  end
            if ~isfield(opt,'errfunc')    opt.errfunc = 'L2';  end
            if ~isfield(opt,'ff')         opt.ff = 1.0;  end
            if ~isfield(opt,'minopt')
                opt.minopt = optimset; opt.minopt.MaxIter = 25; opt.minopt.Display='off';
            end
            dump_frames = false;%true;% option to save the results
            opt.dump = dump_frames;
            rand('state',0);  randn('state',0);
            f = read(vr, frames(indFr(1)));
            framefortrack = double(rgb2gray(f))/256;
            cutFrames = movieScenecuts(videos{iv},videoListLoad(DataRoot, 'DIEM'),cuts);
            initialBB = gazedataToBoundingBox(gazeData.points{indFr(1)},gazeData.height,gazeData.width);
            % from [top_left_x,top_left_y,w,h] to  [center_x,center_y,w,h,rot]
            p = [initialBB(1)+round(initialBB(3)/2),initialBB(2)+round(initialBB(4)/2),initialBB(3:4),0];
            initialBBfortracker = [p(1), p(2), p(3)/32, p(5), p(4)/p(3), 0];
            initialBBfortracker = affparam2mat(initialBBfortracker);
            tmpl.mean = warpimg(framefortrack, initialBBfortracker, opt.tmplsize);
            tmpl.basis = [];
            tmpl.eigval = [];
            tmpl.numsample = 0;
            tmpl.reseig = 0;
            sz = size(tmpl.mean);  N = sz(1)*sz(2);
            BBfortracker = [];
            BBfortracker.est = initialBBfortracker;
            BBfortracker.wimg = tmpl.mean;
            wimgs = [];
            if (exist('dispstr','var'))  dispstr='';  end
            cut_ind=1;
            while(frames(indFr(cut_ind))>cutFrames(cut_ind)) cut_ind=cut_ind+1;end
            % Main loop for each frame
            BBforsave=zeros(length(indFr),4);
            for ifr = 1:length(indFr)
                fr = preprocessFrames(param.videoReader, frames(indFr(ifr)), gbvsParam, ofParam, poseletModel, cache);
                framefortrack = double(rgb2gray(fr.image))/256;
                tmp1=affparam2geom(BBfortracker.est);
                BBforsave(ifr,:)=[tmp1(1),tmp1(2),tmp1(3)*32,tmp1(5)*tmp1(3)*32];
                % Too small BB (under 75*75 pixels)
                if BBforsave(ifr,3)*BBforsave(ifr,4)<30^2
                    scalesq=sqrt(30^2/BBforsave(ifr,3)*BBforsave(ifr,4));
                    BBforsave(ifr,:)=[BBforsave(ifr,1),BBforsave(ifr,2),scalesq*BBforsave(ifr,3),scalesq*BBforsave(ifr,4)];
                    tmp1=[BBforsave(ifr,1),BBforsave(ifr,2),BBforsave(ifr,3)/32,0,BBforsave(ifr,3)/BBforsave(ifr,4),0];
                    tmpl.mean = warpimg(framefortrack, affparam2mat(tmp1), opt.tmplsize);
                    tmpl.basis = [];
                    tmpl.eigval = [];
                    tmpl.numsample = 0;
                    tmpl.reseig = 0;
                    sz = size(tmpl.mean);  N = sz(1)*sz(2);
                    BBfortracker = [];
                    BBfortracker.est=affparam2mat(tmp1);
                    BBfortracker.wimg = tmpl.mean;
                    wimgs=[];
                end
                % center of BB is outside the frame -> object is outside of
                % frame -> reset object to center
                if (BBforsave(ifr,1)+BBforsave(ifr,3))>n || (BBforsave(ifr,1)+BBforsave(ifr,3))<1 ...
                        || (BBforsave(ifr,2)+BBforsave(ifr,4))>m || (BBforsave(ifr,2)+BBforsave(ifr,4))<1
                   BBforsave(ifr,:)=[round(n/2),round(m/2),100,100];
                   tmp1=[BBforsave(ifr,1),BBforsave(ifr,2),BBforsave(ifr,3)/32,0,BBforsave(ifr,3)/BBforsave(ifr,4),0];
                   tmpl.mean = warpimg(framefortrack, affparam2mat(tmp1), opt.tmplsize);
                    tmpl.basis = [];
                    tmpl.eigval = [];
                    tmpl.numsample = 0;
                    tmpl.reseig = 0;
                    sz = size(tmpl.mean);  N = sz(1)*sz(2);
                    BBfortracker = [];
                    BBfortracker.est=affparam2mat(tmp1);
                    BBfortracker.wimg = tmpl.mean;
                    wimgs=[];
                end

                % if scenecut+15 then initialize everything
                if ~isempty(cutFrames) && cut_ind<length(cutFrames) && frames(indFr(ifr))==cutFrames(cut_ind)+15
                    initialBB = gazedataToBoundingBox(gazeData.points{frames(indFr(ifr))},gazeData.height,gazeData.width);
                    % from [top_left_x,top_left_y,w,h] to  [center_x,center_y,w,h,rot]
                    p = [initialBB(1)+round(initialBB(3)/2),initialBB(2)+round(initialBB(4)/2),initialBB(3:4),0];
                    initialBBfortracker = [p(1), p(2), p(3)/32, p(5), p(4)/p(3), 0];
                    initialBBfortracker = affparam2mat(initialBBfortracker);
                    tmpl.mean = warpimg(framefortrack, initialBBfortracker, opt.tmplsize);
                    tmpl.basis = [];
                    tmpl.eigval = [];
                    tmpl.numsample = 0;
                    tmpl.reseig = 0;
                    sz = size(tmpl.mean);  N = sz(1)*sz(2);
                    BBfortracker = [];
                    BBfortracker.est = initialBBfortracker;
                    BBfortracker.wimg = tmpl.mean;
                    wimgs=[];
                    cut_ind=cut_ind+1;
                end
                % do tracking (if no scene cuts then do it until the rest
                % of the movie
                BBfortracker = estwarp_condens(framefortrack, tmpl, BBfortracker, opt);
                % do update
                wimgs = [wimgs, BBfortracker.wimg(:)];
                if (size(wimgs,2) >= opt.batchsize)
                    if (isfield(BBfortracker,'coef'))
                        ncoef = size(BBfortracker.coef,2);
                        recon = repmat(tmpl.mean(:),[1,ncoef]) + tmpl.basis * BBfortracker.coef;
                        [tmpl.basis, tmpl.eigval, tmpl.mean, tmpl.numsample] = ...
                            sklm(wimgs, tmpl.basis, tmpl.eigval, tmpl.mean, tmpl.numsample, opt.ff);
                        BBfortracker.coef = tmpl.basis'*(recon - repmat(tmpl.mean(:),[1,ncoef]));
                    else
                        [tmpl.basis, tmpl.eigval, tmpl.mean, tmpl.numsample] = ...
                            sklm(wimgs, tmpl.basis, tmpl.eigval, tmpl.mean, tmpl.numsample, opt.ff);
                    end
                    %    wimgs = wimgs(:,2:end);
                    wimgs = [];
                    
                    if (size(tmpl.basis,2) > opt.maxbasis)
                        %tmpl.reseig = opt.ff^2 * tmpl.reseig + sum(tmpl.eigval(tmpl.maxbasis+1:end).^2);
                        tmpl.reseig = opt.ff * tmpl.reseig + sum(tmpl.eigval(opt.maxbasis+1:end));
                        tmpl.basis  = tmpl.basis(:,1:opt.maxbasis);
                        tmpl.eigval = tmpl.eigval(1:opt.maxbasis);
                        if (isfield(BBfortracker,'coef'))
                            BBfortracker.coef = BBfortracker.coef(1:opt.maxbasis,:);
                        end
                    end
                end
                % draw result
                if (exist('truepts','var'))
                    trackpts(:,:,ifr) = BBfortracker.est([3,4,1;5,6,2])*[pts0; ones(1,npts)];
                    pts = cat(3, pts0+repmat(sz'/2,[1,npts]), truepts(:,:,ifr), trackpts(:,:,ifr));
                    idx = find(pts(1,:,2) > 0);
                    if (length(idx) > 0)
                        % trackerr(f) = mean(sqrt(sum((pts(:,idx,2)-pts(:,idx,3)).^2,1)));
                        trackerr(ifr) = sqrt(mean(sum((pts(:,idx,2)-pts(:,idx,3)).^2,1)));
                    else
                        trackerr(ifr) = nan;
                    end
                    meanerr(ifr) = mean(trackerr(~isnan(trackerr)&(trackerr>0)));
                    if (exist('dispstr','var'))  fprintf(repmat('\b',[1,length(dispstr)]));  end;
%                     dispstr = sprintf('%d: %.4f / %.4f',ifr,trackerr(ifr),meanerr(ifr));
%                     fprintf(dispstr);
%                     figure(2);  plot(trackerr,'r.-');
%                     figure(1);
                end
%                 drawopt = drawtrackresult(drawopt, ifr, frame, tmpl, BBfortracker, pts);
                %%% UNCOMMENT THIS TO SAVE THE RESULTS (uses a lot of memory)
                %%% saved_params{f} = param;
%                 if (isfield(opt,'dump') && opt.dump > 0)
%                     imwrite(frame2im(getframe(gcf)),sprintf('dump/%s.%04d.png',title,ifr));
%                 end
                fg=exp(-((X - BBforsave(ifr,1)).^2/2/(BBforsave(ifr,3)/6)^2 + (Y - BBforsave(ifr,2)).^2/2/(BBforsave(ifr,4)/6)^2));
                predMaps(:,:,ifr)=fg./max(fg(:));
                gazeData.index = frames(indFr(ifr));
                %%%%%%%%%%%%%%%%%%%%%%%%% YONATAN 28/12/2014%%%%%%%%%%%%%%%%%%%%%
                % Dimtry's results aren't obtain for the video visualization but
                % are obtained for the graphes!
                % NEED TO ADD HERE MY RESULTS + DIMTRY RESULTS
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                [sim(:,:,ifr), outMaps] = similarityFrame3(predMaps(:,:,indFr(ifr)), gazeData, measures, ...
                    'self', ...
                    struct('method', 'saliency_PCAS', 'map', fr.saliencyPCA), ...
                    struct('method', 'saliency_PCAMPolar', 'map', fr.saliencyMotionPCAPolar), ...
                    struct('method', 'saliency_PCAF_old', 'map', fr.Fused_Saliency), ...
                    struct('method', 'saliency_PCAM', 'map', fr.saliencyMotionPCA));
                    %struct('method', 'saliency_DIMA', 'map', fr.saliencyDIMA), ...
                    %struct('method', 'saliency_GBVS', 'map', fr.saliencyGBVS), ...
                %             [sim{i}(:,:,ifr), outMaps, extra] = similarityFrame2(predMaps(:,:,indFr(ifr)), gazeParam.gazeData{frames(indFr(ifr))}, gazeParam.gazeData(frames(indFr([1:indFr(ifr)-1, indFr(ifr)+1:end]))), measures, ...
                %                 'self', ...
                %                 struct('method', 'center', 'cov', [(n/16)^2, 0; 0, (n/16)^2]), ...
                %                 struct('method', 'saliency_GBVS', 'map', fr.saliency), ...
                %                 struct('method', 'saliency_PQFT', 'map', fr.saliencyPqft), ...
                %                 struct('method', 'saliency_Hou', 'map', fr.saliencyHou));
                if (saveVideo && verNum >= 2012)
                    %methodnms={'PCA','Self','Center','DIMA','GBVS','PQFT'};
                    outfr = renderSideBySide(fr.image, outMaps, colors, cmap, sim(:,:,ifr),methods);
                    writeVideo(vw, outfr);
                end
            end
        catch me
            if (saveVideo && verNum >= 2012)
                close(vw);
            end
            rethrow(me);
        end
        
        if (saveVideo && verNum >= 2012)
            close(vw);
        end
        
        fprintf('%f sec\n', toc);
        vidnameonly=strsplit(vr.name,'.');vidnameonly=vidnameonly{1};
        movieIdx=iv;
        save(fullfile(finalResultRoot, [vidnameonly,'_similarity.mat']), 'sim', 'measures', 'methods', 'movieIdx');
        save(fullfile(finalResultRoot, [vidnameonly,'.mat']),'frames', 'indFr', 'predMaps','BBforsave');
        % Finish processing saving and moving on
        dosave(lockfile,'success',1,'compname',getComputerName());
        video_count=video_count+1;
        
        % ERROR handling
    catch me
        dosave(lockfile,'success',0,'compname',getComputerName(),'theerror',me.getReport());
        warning('Run failed on %s- check log!',videos{iv});
        warnNum=warnNum+1;
        if warnNum>=3
            diary off;
            fclose(fileID);
            error('Run failed on 3 files aborting run on comp %s',getComputerName());
        end
    end
end
    % FINISHED RUN wrap things up
    telapse=toc(tstart);
    diary off;
    fclose(fileID);
    subject=['MATLAB: Your Exp on: ',getComputerName(),'  -  has finished'];
    massege=['Time for the Exp to run on ',getComputerName(),' is: ',num2str(telapse),'[sec]',...
        '\n','Number of Videos processed is:',num2str(video_count),'\n'];
    fprintf(subject);fprintf(massege);
    % [mail,ss]=myGmail('fuck you');
    % SendmeEmail(mail,ss,subject,massege);