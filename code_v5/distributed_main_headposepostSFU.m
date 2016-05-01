%% Setup file to rule them all
%setup_videoSaliency;
dropbox = 'C:\Users\ydishon\Documents\MATLAB\Video_Saliency\Dimarudoy_saliency\Dropbox';
gdrive = 'C:\Users\ydishon\Documents\MATLAB\Video_Saliency\Dimarudoy_saliency\GDrive';
addpath(genpath(fullfile(gdrive, 'Software', 'dollar_261')));
addpath(fullfile(dropbox, 'Matlab', 'video_attention'));
addpath(fullfile(dropbox, 'Matlab', 'video_attention', 'compare', 'BorjiMetrics')); % measures

%% Settings
finalResultRoot = '\\CGM10\D\head_pose_estimation\PredictionsSFU\2016_03_04_MRF2_div16';
methods = {'ONLY_PCA16_0_8_MRF2','Hough_15_p_MRF2'};
%visVideo = true;
% Gaze settings
% gazeParam.pointSigma = 10;
%% Training and testing settings
%% visualization
% cmap = jet(256);
% colors = [1 0 0;
%     0 1 0;
%     0 0 1;
%     1 1 0;
%     1 0 1;
%     0.5 0.5 0.5;
%     0 1 1];
%% configure all detectors
%[gbvsParam, ofParam, poseletModel] = configureDetectors();

% if (~exist(visRoot, 'dir'))
%     mkdir(visRoot);
% end

%sim = cell(length(testSubset), 1);

%% TRY CATCH FOREACH of the servers
tstart=tic;%start_clock
warnNum=0;
video_count=0;
videos = extractfield(dir('\\CGM10\D\head_pose_estimation\PredictionsSFU\pred_01_05_2016_PCAonly_subpatches_08confSFU176x144'),'name');
videos = videos(~ismember(videos,{'.','..'}));
for ii=1:length(videos) % run for the length of the defined exp.
%     lockfile = [lockfiles_folder,'\',videos{testIdx(ii)},'_lockfile','.mat'];
%     if exist(lockfile,'file') % somebody already working on this file go to next one.
%         continue;
%     else % nobody works on the file - lock it and work on it
%         dosave(lockfile,'compname',getComputerName());
%     end
    
    
        iv = ii;
        fprintf('Time::%s\nProcessing %s...\n',datestr(clock,'dd/mm/yyyy, HH:MM'), videos{iv}); tic;
        
        % prepare video
%         if (saveVideo && verNum >= 2012)
%             vw = VideoWriter(videoFile, 'Motion JPEG AVI'); % 'Motion JPEG AVI' or 'Uncompressed AVI' or 'MPEG-4' on 2012a.
%             open(vw);
%         end
            %m=288;n=352;
            m=144;n=176;
            post_fold = '\\CGM10\D\head_pose_estimation\PredictionsSFU\pred_01_05_2016_PCAonly_subpatches_08confSFU176x144';
            post_files = extractfield(dir(fullfile(post_fold,videos{iv},'*.png')),'name');
%             post_fold1 = '\\CGM10\D\head_pose_estimation\PredictionsSFU\pred_29_02_2016_origandPCAsPCAm_15_p';
%             post_files1 = extractfield(dir(fullfile(post_fold1,videos{iv},'*.png')),'name');
            FRMS_CNT = numel(dir(fullfile(post_fold,videos{ii},'*.png')));
            predMaps_tmp=zeros(m,n,length(FRMS_CNT));
%             predMaps_tmp1=zeros(m,n,length(FRMS_CNT));
            for kk =1:FRMS_CNT
                predMaps_tmp(:,:,kk)= im2double(imread(fullfile(post_fold,videos{iv},post_files{kk})));
                predMaps_tmp1(:,:,kk)= im2double(imread(fullfile(post_fold1,videos{iv},post_files1{kk})));
            end
            T_t = 1; T_o = 1; T_c = 1;
            ONE_DEGREE_PXLS = 24/2;
            %
            H=144;
            ONE_DEGREE_MBLKS = ONE_DEGREE_PXLS*size(predMaps_tmp,1)/H/4;  % div by 4 to reduce cal and be more consice with the OBDL code
            tic
            % div by 4 to reduce cal and be more consice with the OBDL code
            predMaps_PCA_only = SalOBDL_MRF(imresize(predMaps_tmp(:,:,1:FRMS_CNT),1/4), ONE_DEGREE_MBLKS,T_t,T_o,T_c);
            predMaps_Hough_p = SalOBDL_MRF(imresize(predMaps_tmp1(:,:,1:FRMS_CNT),1/4), ONE_DEGREE_MBLKS,T_t,T_o,T_c);
            times = toc/FRMS_CNT;
            disp(times*1000)
            
%         if (saveVideo && verNum >= 2012)
%             close(vw);
%         end
        
        fprintf('%f sec\n', toc);
        fprintf('Time is: %s\n',datestr(clock,'dd/mm/yyyy, HH:MM'));
        save(fullfile(finalResultRoot, [videos{ii},'.mat']),'predMaps_PCA_only');%,'predMaps_Hough_p');
        video_count=video_count+1;
        
end