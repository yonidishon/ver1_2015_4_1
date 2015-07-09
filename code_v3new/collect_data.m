%SCRIPT to run code on multiple servers, Needs to use the CheckAndUpdateSource.m first

% If I want a longer add files function to add all nessary files.
%  addincludes;
% clear all;close all;clc

%% Settings
uncVideoRoot = fullfile(DataRoot, 'video_unc'); % uncompress video.
gazeDataRoot = fullfile(DataRoot, 'gaze'); % gaze data from the DIEM.
cache.frameRoot = cacheRoot;
cache.renew = false;%true; % use in case the preprocessing mechanism updated

%% Training and testing settings
videos = videoListLoad(DataRoot, 'DIEM');
nv = length(videos);
testIdx = [TREEPARAMS.trainset,TREEPARAMS.testset]; 

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

%% TRY CATCH FOREACH of the servers
tstart=tic;%start_clock
warnNum=0;
video_count=0;
for ii=1:length(testIdx) % run for the length of the defined exp.
    lockfile = fullfile(lockfiles_folder,[videos{testIdx(ii)},'_collect.mat']);
    if exist(lockfile,'file') % somebody already working on this file go to next one.
        continue;
    else % nobody works on the file - lock it and work on it
        dosave(lockfile,'compname',getComputerName());
    end
    try % MAIN ROUTINE to do.
        % PREPARE DATA Routine
        iv = testIdx(ii);
        fprintf('Processing %s...\n ', videos{iv}); tic;
        
        % prepare video
        vr = VideoReader(fullfile(uncVideoRoot, sprintf('%s.avi', videos{iv})));

        m = vr.Height;
        n = vr.Width;
        read(vr,inf);
        videoLen = vr.numberOfFrames;
        param = struct('videoReader', vr);
        
        % PROCESS FRARMES AND CALCULATE SIMILARITY TO GAZE VER
        % load gaze data
        s = load(fullfile(gazeDataRoot, sprintf('%s.mat', videos{iv}))); %george
        gazeData = s.data;
        clear s;
        
        if (~exist(fullfile(CollectDataDst,videos{iv}), 'dir'))
            mkdir(fullfile(CollectDataDst,videos{iv}));
        end
        try
            % compare
            frames = GENERALPARAMS.offset:videoLen-GENERALPARAMS.offset;
            indFr = find(frames);
            for ifr = 1:length(indFr)
                fr = preprocessFrames(param.videoReader, frames(indFr(ifr)), gbvsParam, ofParam, poseletModel, cache);
                gazeData.index = frames(indFr(ifr));
                [~,Smap,Mmap]=PCA_Saliency_all(fr.ofx,fr.ofy,fr.image);
                [responeses,data]=process_data_for_learner_patch(Smap,Mmap,gazeData,GENERALPARAMS.GT,GENERALPARAMS.PatchSz);
                if isempty(responeses) || isempty(data) 
                    continue;
                end
                save(fullfile(CollectDataDst,videos{iv},sprintf('frame_%06d.mat',frames(indFr(ifr)))),'responeses','data');
            end
        catch me
            rethrow(me);
        end       
        fprintf('%f sec\n', toc);
        video_count=video_count+1;
        
        % ERROR handling
    catch me
        dosave(lockfile,'success',0,'compname',getComputerName(),'theerror',me.getReport());
        warning('Run failed on %s- check log!',videos{iv});
        warnNum=warnNum+1;
        if warnNum>=3
            error('Run failed on 3 files aborting run on comp %s',getComputerName());
        end
        rethrow(me);
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
%exit();