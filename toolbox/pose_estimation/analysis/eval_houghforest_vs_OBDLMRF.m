% Main distributed Script to run code on multiple servers, Needs to use the CheckAndUpdateSource.m first

% If I want a longer add files function to add all nessary files.
%  addincludes;
clear all;close all;clc

%% Setup file to rule them all
addpath('\\cgm10\Users\ydishon\Documents\Video_Saliency\Dimarudoy_saliency\Dropbox\Matlab\video_attention');
addpath(genpath('\\cgm10\Users\ydishon\Documents\Video_Saliency\Dimarudoy_saliency\Dropbox\Matlab\video_attention\compare'));
addpath(genpath(fullfile('\\cgm10\Users\ydishon\Documents\Video_Saliency\Dimarudoy_saliency\GDrive', 'Software', 'dollar_261')));
%% Settings
DataRoot = '\\cgm10\D\DIEM';
uncVideoRoot = fullfile(DataRoot, 'video_unc'); % uncompress video.
gazeDataRoot = fullfile(DataRoot, 'gaze'); % gaze data from the DIEM.

% visualizations results
pred_fold = 'old_pred_origandPCAmPCAs_15_p';%'pred_origandPCAmPCAs_15_1_TH';
%finalResultRoot = '\\cgm10\D\head_pose_estimation\result_eval\';
finalResultRoot = ['\\cgm10\D\head_pose_estimation\Predictions\',pred_fold,'\result_eval\'];
savefold = '\\cgm10\D\head_pose_estimation\Analysis_All\OBDL';
visRoot = fullfileCreate(savefold,'vis');
PredMatDirPCAFbest='\\cgm10\Users\ydishon\Downloads\howManyBitsforSaliency\DATA\SEQ_DIEM';

measures = {'chisq', 'auc'};
%methods = {'PCA F','self','center','Dima','GBVS','PCA M'};
methods = {'HoughForest','self','OBDL-MRF','OBDL'};

%% Training and testing settings
videos = dir(fullfile('\\cgm10\D\head_pose_estimation\Predictions',pred_fold));
videos = {videos(cell2mat(extractfield(videos,'isdir'))).name}';
videos(ismember(videos,{'.','..','result_eval','result_eval_fixed'}))=[];
visVideo = true; %TODO
%% visualization
cmap = jet(256);
colors = [1 0 0;
    0 1 0;
    0 0 1;
    1 1 0;
    1 0 1;
    0.5 0.5 0.5;
    0 1 1];

%% TRY CATCH FOREACH of the servers
tstart=tic;%start_clock
warnNum=0;
video_count=0;

for ii=1:length(videos) % run for the length of the defined exp.
    try % MAIN ROUTINE to do.
        % PREPARE DATA Routine
        iv = ii;
        fprintf('Processing %s...\n ', videos{iv}); tic;
        temp = strsplit(videos{iv},'\');
        temp = temp{end};
        vr = VideoReader(fullfile(uncVideoRoot, sprintf('%s.avi', temp)));
        m = vr.Height;
        n = vr.Width;
        read(vr,inf);
        videoLen = vr.numberOfFrames;
        param = struct('videoReader', vr);
        s = load(fullfile(gazeDataRoot, sprintf('%s.mat', temp))); %george
        gazeData = s.data;
        clear s;
        
        % VISUALIZATION CONFIG
        videoFile = fullfile(visRoot, sprintf('%s.avi', temp));
        if visVideo
            vw = VideoWriter(videoFile, 'Motion JPEG AVI'); % 'Motion JPEG AVI' or 'Uncompressed AVI' or 'MPEG-4' on 2012a.
            open(vw);
        end
        
        try
            % convert to OBDL name formating
            mystr = strsplit(temp,'_');
            mystr = strjoin(mystr(1:end-1),'_');
            predMapPCAFbest=load(fullfile(PredMatDirPCAFbest,mystr,...
                'result_OBDL-MRF_H264_QP30'),'S');
            predMapPCAFbest1=load(fullfile(PredMatDirPCAFbest,mystr,...
                'result_OBDL_H264_QP30'),'S');
            predMapPCAFbest = imresize(predMapPCAFbest.S,[m,n]);
            predMapPCAFbest1 = imresize(predMapPCAFbest1.S,[m,n]);
            offset = 3;
            indFr = 1:300-offset-1;
            for ifr=1:length(indFr)
             fr = read(vr,indFr(ifr)+offset);
             predMap = im2double(imread(fullfile('\\cgm10\D\head_pose_estimation\Predictions',pred_fold,videos{iv},sprintf('%06d_sc0_c0_predmap.png',indFr(ifr)+offset))));
             predMap = predMap./max(predMap(:));
             gazeData.index = offset + indFr(ifr);
             gazeData.otherMaps(gazeData.index)=gazeData.otherMaps(gazeData.index)-gazeData.binaryMaps(gazeData.index);
             [sim(:,:,ifr), outMaps] = similarityFrame3(predMap, gazeData, measures, ...
                    'self', ...
                    struct('method', 'saliency_OBDL-MRF', 'map',predMapPCAFbest(:,:,indFr(ifr)+offset)),...
                    struct('method', 'saliency_OBDL', 'map',predMapPCAFbest1(:,:,indFr(ifr)+offset)));
                if visVideo
                    outfr = renderSideBySide(fr, outMaps, colors, cmap, sim(:,:,ifr),methods);
                    writeVideo(vw, outfr);
                end
            end
        catch me
            if visVideo
                close(vw);
            end
            error(me.message);
        end   
        if visVideo
            close(vw);
        end
        fprintf('%f sec\n', toc);
        vidnameonly=strsplit(vr.name,'.');vidnameonly=vidnameonly{1};
        movieIdx=iv;
        save(fullfile(savefold, [vidnameonly,'_similarity.mat']), 'sim', 'measures', 'methods', 'movieIdx','-v7.3');
        %save(fullfile(finalResultRoot, [vidnameonly,'.mat']),'frames', 'indFr', 'predMaps','-v7.3');
        % Finish processing saving and moving on
        video_count=video_count+1;
       
        % ERROR handling
    catch me
        warning('Run failed on %s- check log!',videos{iv});
        warnNum=warnNum+1;
        if warnNum>=3
            error('Run failed on 3 files aborting run');
        end
        rethrow(me);
    end
    clear sim 
end
% FINISHED RUN wrap things up
telapse=toc(tstart)
% [mail,ss]=myGmail('fuck you');
% SendmeEmail(mail,ss,subject,massege);
%exit();