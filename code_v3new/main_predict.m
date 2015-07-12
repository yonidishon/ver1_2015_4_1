% SCRIPT
%% Settings
uncVideoRoot = fullfile(DataRoot, 'video_unc'); % uncompress video.
gazeDataRoot = fullfile(DataRoot, 'gaze'); % gaze data from the DIEM.

% visualizations results
cache.frameRoot = cacheRoot;
cache.renew = false;%true; %true; % use in case the preprocessing mechanism updated
%% Training and testing settings
videos = videoListLoad(DataRoot, 'DIEM');
testIdx = TREEPARAMS.testset;

visVideo = true;

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
tstart = tic;%start_clock
warnNum = 0;
video_count = 0;
fprintf('Loading learned random forest....\n');
tree = load(fullfile(TreesDst,[GENERALPARAMS.full_tree_ver,'_fulltree']));
tree = tree.fulltree;
data_folder = CollectDataDst;
for ii=1:length(testIdx) % run for the length of the defined exp.
    lockfile = fullfile(lockfiles_folder,[videos{testIdx(ii)},'_predict.mat']);
    if exist(lockfile,'file') ||...
        ~exist(fullfile(lockfiles_folder,[videos{testIdx(ii)},'_collect.mat']),'file');
        % somebody already working on this file or there isn't collect on this version
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
        
        % VISUALIZATION CONFIG
        videoFile = fullfile(visRoot, sprintf('%s.avi', videos{iv}));
        if visVideo 
            vw = VideoWriter(videoFile, 'Motion JPEG AVI'); % 'Motion JPEG AVI' or 'Uncompressed AVI' or 'MPEG-4' on 2012a.
            open(vw);
        end
        
        try
            frames = GENERALPARAMS.offset:GENERALPARAMS.frame_pred_num;
            indFr = find(frames);
            
            % predicting the gaze map (Gaussian values max==1);
            predMaps_tree=predict_tree_gaze(tree,videos(TREEPARAMS.trainset),...
                data_folder,videos{iv},[m,n],GENERALPARAMS.frame_pred_num,GENERALPARAMS.offset);
            
            method1=load(fullfile(methods_paths{1},[videos{iv},'.mat']),'predMaps');

            for ifr=1:length(indFr)
             fr = preprocessFrames(param.videoReader, frames(indFr(ifr)), gbvsParam, ofParam, poseletModel, cache);   
             gazeData.index = frames(indFr(ifr));
             [sim(:,:,ifr), outMaps] = similarityFrame3(predMaps_tree(:,:,indFr(ifr)), gazeData, measures, ...
                    'self', ...
                    struct('method', ['saliency_',methods{1}], 'map', method1.predMaps(:,:,indFr(ifr))), ...
                    struct('method', ['saliency_',methods{2}], 'map', fr.saliencyDIMA));
                if visVideo
                    outfr = renderSideBySide(fr.image, outMaps, colors, cmap, sim(:,:,ifr),methods);
                    writeVideo(vw, outfr);
                end
            end
        catch me
            if  visVideo
                close(vw);
            end
            if strcmp(me.message,'Movie belong to the training set!')
                fprintf('%s %s\nSkipping....\n',videos{iv},me.message);
                delete(videoFile);
            else
                rethrow(me);
            end
        end   
        if visVideo
            close(vw);
        end
        fprintf('%f sec\n', toc);
        vidnameonly=strsplit(vr.name,'.');vidnameonly=vidnameonly{1};
        movieIdx=iv;
        save(fullfile(FinalResultRoot, [vidnameonly,'_similarity.mat']), 'sim', 'measures', 'methods', 'movieIdx','-v7.3');
        save(fullfile(FinalResultRoot, [vidnameonly,'.mat']),'frames', 'indFr','predMaps_tree','-v7.3');
        % Finish processing saving and moving on
        dosave(lockfile,'success',1,'compname',getComputerName());
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
subject=['MATLAB: Your Exp on: ',getComputerName(),'  -  has finished\n'];
massege=['Time for the Exp to run on ',getComputerName(),' is: ',num2str(telapse),'[sec]',...
    '\n','Number of Videos processed is:',num2str(video_count),'\n'];
fprintf(subject);fprintf(massege);
% [mail,ss]=myGmail('fuck you');
% SendmeEmail(mail,ss,subject,massege);
exit();