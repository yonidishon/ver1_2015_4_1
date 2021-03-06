%% Setup file to rule them all
%setup_videoSaliency;
dropbox = 'C:\Users\ydishon\Documents\Video_Saliency\Dimarudoy_saliency\Dropbox';
gdrive = 'C:\Users\ydishon\Documents\Video_Saliency\Dimarudoy_saliency\GDrive';
addpath(genpath(fullfile(gdrive, 'Software', 'dollar_261')));
addpath(fullfile(dropbox, 'Matlab', 'video_attention'));
addpath(fullfile(dropbox, 'Matlab', 'video_attention', 'compare', 'BorjiMetrics')); % measures

%% Settings
DataRoot = '\\cgm10\D\DIEM' ; % DIEM dataset is the data
uncVideoRoot = fullfile(DataRoot, 'video_unc'); % uncompress video.
gazeDataRoot = fullfile(DataRoot, 'gaze'); % gaze data from the DIEM.
% visualizations results
finalResultRoot = '\\CGM10\D\head_pose_estimation\Predictions\2016_02_27_Post_MRF2';
visRoot = fullfile(finalResultRoot,'vis');

jumpType = 'all'; % 'cut' or 'gaze_jump' or 'random' or 'all'
sourceType = 'rect';
% measures = {'chisq', 'auc', 'cc', 'nss'};
measures = {'chisq', 'auc','nss'};
methods = {'ONLY_PCA16_0_8_MRF2','self','Hough_15_p_MRF2'};

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

% JUST FOR TO COMPLETE THE RUN OF THE 08/01/2015%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% lockFileFolder='\\CGM10\Users\ydishon\Documents\Video_Saliency\lockfiles\2015_28_12\';
% lockfiles=dir([lockFileFolder,'*lockfile*']);
videos=videos(testIdx);
testIdx=1:length(videos);
testSubset = 1:length(testIdx);
% END JUST FOR TO COMPLETE THE RUN OF THE 08/01/2015%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
%[gbvsParam, ofParam, poseletModel] = configureDetectors();

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
%     lockfile = [lockfiles_folder,'\',videos{testIdx(ii)},'_lockfile','.mat'];
%     if exist(lockfile,'file') % somebody already working on this file go to next one.
%         continue;
%     else % nobody works on the file - lock it and work on it
%         dosave(lockfile,'compname',getComputerName());
%     end
    try % MAIN ROUTINE to do.
        % PREPARE DATA Routine
        iv = testIdx(testSubset(ii));
        fprintf('Time::%s\nProcessing %s...\n',datestr(clock,'dd/mm/yyyy, HH:MM'), videos{iv}); tic;
        
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
        FRMS_CNT= videoLen;%300;
        param = struct('videoReader', vr);
%         predmap_folder=fullfile(Ran_results_fold,videos{iv});
        % load jump frames (FOR MY IMP. LOAD 'all')
        %[jumpFrames, before, after] = jumpFramesLoad(DataRoot, iv, jumpType, 50, 30, videoLen - 30);
        % Going on all videos frames from 1 to VideoLen (Dmitry went from 30 to
        % VideoLen-30)
        [jumpFrames, before, after] = jumpFramesLoad(DataRoot, iv, jumpType, 50, 30, videoLen-30);
        %[jumpFrames, before, after] = jumpFramesLoad(DataRoot, iv, jumpType, 50, 30,FRMS_CNT+30-1);
        % PROCESS FRARMES AND CALCULATE SIMILARITY TO GAZE VER
        % load gaze data
        s = load(fullfile(gazeDataRoot, sprintf('%s.mat', videos{iv})));%george
        gazeData = s.data;
        clear s;
        
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
            FRMS_CNT = length(indFr);
            %indFr=1:length(jumpFrames);
            sim = zeros(length(methods), length(measures), length(indFr));
            post_fold = '\\CGM10\D\head_pose_estimation\Predictions\22_02_2016_Pcas_only_subpatches_16_0_8conf';
            post_files = extractfield(dir(fullfile(post_fold,videos{iv},'*.png')),'name');
            post_fold1 = '\\CGM10\D\head_pose_estimation\Predictions\old_pred_origandPCAmPCAs_15_p';
            post_files1 = extractfield(dir(fullfile(post_fold1,videos{iv},'*.png')),'name');
            predMaps_tmp=zeros(m,n,length(FRMS_CNT));
            predMaps_tmp1=zeros(m,n,length(FRMS_CNT));
            for kk =1:FRMS_CNT
                predMaps_tmp(:,:,kk)= im2double(imread(fullfile(post_fold,videos{iv},post_files{kk+29})));
                predMaps_tmp1(:,:,kk)= im2double(imread(fullfile(post_fold1,videos{iv},post_files1{kk+29})));
            end
            T_t = 1; T_o = 1; T_c = 1;
%             BLK_SZ = 4;
%             MBLK_SZ = 1;
%             PEL_MC = 4;
            ONE_DEGREE_PXLS = 58;
            h=strsplit(videos{iv},'x');H=str2num(h{2});
            ONE_DEGREE_MBLKS = ONE_DEGREE_PXLS*size(predMaps_tmp,1)/H/4;  % div by 4 to reduce cal and be more consice with the OBDL code
            tic
            % div by 4 to reduce cal and be more consice with the OBDL code
            predMaps = SalOBDL_MRF(imresize(predMaps_tmp(:,:,1:FRMS_CNT),1/4), ONE_DEGREE_MBLKS,T_t,T_o,T_c);
            tot = toc;
            disp(toc)
            times = toc/FRMS_CNT;
            disp(times)
            fprintf('This is how much time it took waiting for user');
            return
%             predMaps1 = SalOBDL_MRF(imresize(predMaps_tmp1(:,:,1:FRMS_CNT),1/4), ONE_DEGREE_MBLKS,T_t,T_o,T_c);
% 
%             for ifr = 1:length(indFr)
%                 gazeData.index = frames(indFr(ifr));
%                 [sim(:,:,ifr), outMaps] = similarityFrame3(predMaps(:,:,indFr(ifr)), gazeData, measures, ...
%                     'self',...
%                     'saliency__15_p',predMaps1(:,:,indFr(ifr)));
%                 if (saveVideo && verNum >= 2012)
%                     outfr = renderSideBySide(read(vr,frames(indFr(ifr))), outMaps, colors, cmap, sim(:,:,ifr),methods);
%                     writeVideo(vw, outfr);
%                 end
%             end
        catch me
            if (saveVideo && verNum >= 2012)
                close(vw);
            end
            rethrow(me);
        end
        
%         if (saveVideo && verNum >= 2012)
%             close(vw);
%         end
%         
%         fprintf('%f sec\n', toc);
%         fprintf('Time is: %s\n',datestr(clock,'dd/mm/yyyy, HH:MM'));
%         vidnameonly=strsplit(vr.name,'.');vidnameonly=vidnameonly{1};
%         movieIdx=iv;
%         save(fullfile(finalResultRoot, [vidnameonly,'_similarity.mat']), 'sim', 'measures', 'methods', 'movieIdx');
%         save(fullfile(finalResultRoot, [vidnameonly,'.mat']),'frames', 'indFr', 'predMaps');
%         % Finish processing saving and moving on
%         %dosave(lockfile,'success',1,'compname',getComputerName());
%         video_count=video_count+1;
        
        % ERROR handling
    catch me
        %dosave(lockfile,'success',0,'compname',getComputerName(),'theerror',me.getReport());
        warning('Run failed on %s- check log!',videos{iv});
        warnNum=warnNum+1;
        if warnNum>=1
            error('Run failed on 1 files aborting run on comp %s',getComputerName());
        end
    end
end
% FINISHED RUN wrap things up
telapse=toc(tstart);
%diary off;
%fclose(fileID);
subject=['MATLAB: Your Exp on: ',getComputerName(),'  -  has finished'];
massege=['Time for the Exp to run on ',getComputerName(),' is: ',num2str(telapse),'[sec]',...
    '\n','Number of Videos processed is:',num2str(video_count),'\n'];
fprintf(subject);fprintf(massege);
% [mail,ss]=myGmail('fuck you');
% SendmeEmail(mail,ss,subject,massege);
%exit();