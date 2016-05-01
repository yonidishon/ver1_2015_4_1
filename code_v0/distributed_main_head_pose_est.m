% Main distributed Script to run code on multiple servers, Needs to use the CheckAndUpdateSource.m first

% If I want a longer add files function to add all nessary files.
%  addincludes;
% clear all;close all;clc

%% Setup file to rule them all
setup_videoSaliency;

%% Settings
DataRoot = diemDataRoot; % DIEM dataset is the data
uncVideoRoot = fullfile(DataRoot, 'video_unc'); % uncompress video.
gazeDataRoot = fullfile(DataRoot, 'gaze'); % gaze data from the DIEM.
lockFileFolder='\\CGM10\Users\ydishon\Documents\Video_Saliency\lockfiles\20160423\';
% visualizations results
finalResultRoot = '\\cgm10\D\head_pose_estimation\Predictions\2016_04_23_Faces_and_poselets\';
visRoot = fullfileCreate(finalResultRoot,'vis');

jumpType = 'all'; % 'cut' or 'gaze_jump' or 'random' or 'all'
sourceType = 'rect';
% measures = {'chisq', 'auc', 'cc', 'nss'};
measures = {'chisq', 'auc','nss'};
%methods = {'PCA F','self','center','Dima','GBVS','PCA M'};
methods = {'PCAHoughMRF+F+P','self'};

% cache settings
% cache.root = fullfile(DataRoot, 'cache');
cache.frameRoot = saveRoot;%fullfile(saveRoot, 'cache');
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

testIdx = [6,8,10,11,12,14,15,16,34,42,44,48,53,54,55,59,70,74,83,84]; % used by Borji
testSubset = 1:length(testIdx);

visVideo = false;
candScale = 2; % Guassian scale index for candidate2map func.

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
            %indFr=1:length(jumpFrames);
            predMaps=zeros(m,n,length(indFr));
            sim = zeros(length(methods), length(measures), length(indFr));
            PCAHMRFmaps = importdata(fullfile('\\cgm10\D\head_pose_estimation\Predictions\2016_02_27_Post_MRF2',[videos{iv},'.mat']),'predMaps');
            PCAHMRFmaps = PCAHMRFmaps.predMaps;
            for ifr = 1:length(indFr)
                fr = preprocessFrames(param.videoReader, frames(indFr(ifr)), gbvsParam, ofParam, poseletModel, cache);
                PCAHMRF = PCAHMRFmaps(:,:,indFr(ifr));
                PCAHMRF = double(PCAHMRF)./double(max(PCAHMRF(:)));
                if ~isempty(fr.faces) && ~isempty(fr.poselet_hit)
                    gauss_face=face_gaze(fr.faces,[fr.height,fr.width]);
                    gauss_poselets=pose_gaze(fr.poselet_hit,[fr.height,fr.width]);
                    tmpmap=(1/3)*gauss_face+(2/9)*(gauss_face+gauss_poselets)+...
                        (1/3)*(gauss_face+gauss_poselets+PCAHMRF)+(1/9)*PCAHMRF;
                    predMaps(:,:,ifr)=tmpmap./max(tmpmap(:));
                elseif ~isempty(fr.faces)
                    gauss_face=face_gaze(fr.faces,[fr.height,fr.width]);
                    tmpmap=(5/9)*gauss_face+(1/3)*(gauss_face+PCAHMRF)+(1/9)*PCAHMRF;
                    predMaps(:,:,ifr)=tmpmap./max(tmpmap(:));
                elseif ~isempty(fr.poselet_hit)
                    gauss_poselets=pose_gaze(fr.poselet_hit,[fr.height,fr.width]);
                    tmpmap=(5/9)*gauss_poselets+(1/3)*(gauss_poselets+PCAHMRF)+(1/9)*PCAHMRF;
                    predMaps(:,:,ifr)=tmpmap./max(tmpmap(:));
                else
                    predMaps(:,:,ifr)=PCAHMRF;
                end
%                 if ~isempty(fr.faces) && ~isempty(fr.poselet_hit)
%                     gauss_face=face_gaze(fr.faces,[fr.height,fr.width]);
%                     gauss_poselets=pose_gaze(fr.poselet_hit,[fr.height,fr.width]);
%                     tmpmap=(1/3)*gauss_face+(2/9)*gauss_face.*gauss_poselets+...
%                                       (1/3)*gauss_face.*gauss_poselets.*PCAHMRF+(1/9)*PCAHMRF;
%                     predMaps(:,:,ifr)=tmpmap./max(tmpmap(:));           
%                 elseif ~isempty(fr.faces)
%                     gauss_face=face_gaze(fr.faces,[fr.height,fr.width]);
%                     tmpmap=(5/9)*gauss_face+(1/3)*gauss_face.*PCAHMRF+(1/9)*PCAHMRF;
%                     predMaps(:,:,ifr)=tmpmap./max(tmpmap(:));
%                 elseif ~isempty(fr.poselet_hit)
%                     gauss_poselets=pose_gaze(fr.poselet_hit,[fr.height,fr.width]);
%                     tmpmap=(5/9)*gauss_poselets+(1/3)*gauss_poselets.*PCAHMRF+(1/9)*PCAHMRF;
%                     predMaps(:,:,ifr)=tmpmap./max(tmpmap(:));
%                 else
%                     predMaps(:,:,ifr)=PCAHMRF;
%                 end
                gazeData.index = frames(indFr(ifr));
                %%%%%%%%%%%%%%%%%%%%%%%%% YONATAN 28/12/2014%%%%%%%%%%%%%%%%%%%%%
                % Dimtry's results aren't obtain for the video visualization but
                % are obtained for the graphes!
                % NEED TO ADD HERE MY RESULTS + DIMTRY RESULTS
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                [sim(:,:,ifr), outMaps] = similarityFrame3(predMaps(:,:,indFr(ifr)), gazeData, measures, ...
                    'self');
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
        save(fullfile(finalResultRoot, [vidnameonly,'.mat']),'frames', 'indFr', 'predMaps');
        % Finish processing saving and moving on
        dosave(lockfile,'success',1,'compname',getComputerName());
        video_count=video_count+1;
        
        % ERROR handling
    catch me
        dosave(lockfile,'success',0,'compname',getComputerName(),'theerror',me.getReport());
        warning('Run failed on %s- check log!',videos{iv});
        warnNum=warnNum+1;
    end
end
% FINISHED RUN wrap things up
telapse=toc(tstart);
subject=['MATLAB: Your Exp on: ',getComputerName(),'  -  has finished'];
massege=['Time for the Exp to run on ',getComputerName(),' is: ',num2str(telapse),'[sec]',...
    '\n','Number of Videos processed is:',num2str(video_count),'\n'];
fprintf(subject);fprintf(massege);
% [mail,ss]=myGmail('fuck you');
% SendmeEmail(mail,ss,subject,massege);
exit();