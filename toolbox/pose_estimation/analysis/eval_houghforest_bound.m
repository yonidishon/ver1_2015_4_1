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
movie_list = importdata('\\cgm10\D\DIEM\list.txt');
borji_list_subset = [6,8,10,11,12,14,15,16,34,42,44,48,53,54,55,59,70,74,83,84]; % Used by Borji on DIEM
%pred_fold = '2015_11_11_wColor';%'pred_origandPCAmPCAs_15_1_TH';
finalResultRoot = '\\cgm10\D\head_pose_estimation\bound_result_eval';
%finalResultRoot = ['\\cgm10\D\head_pose_estimation\',pred_fold,'\result_eval\'];
visRoot = fullfileCreate(finalResultRoot,'vis');
PredMatDirPCAFbest='\\Cgm10\d\Video_Saliency_Results\FinalResults2\PCA_Fusion_v8_2';

measures = {'chisq', 'auc'};
%methods = {'PCA F','self','center','Dima','GBVS','PCA M'};
methods = {'Performance_Bound_1_sigma','self','PCA F+F+P'};

%% Training and testing settings
videos = movie_list(borji_list_subset);
visVideo = false; %true; %TODO
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
            predMapPCAFbest=load(fullfile(PredMatDirPCAFbest,[temp,'.mat']),'predMaps');
            indFr = 1:videoLen-59;
            offset = 29;
            for ifr=1:length(indFr)
             fr = read(vr,indFr(ifr)+offset);
             gazeData.index = offset + indFr(ifr);
             %predMap = im2double(imread(fullfile('\\cgm10\D\head_pose_estimation',pred_fold,videos{iv},sprintf('%06d_sc0_c0_predmap.png',indFr(ifr)+offset))));
             % Code to extract the center of the biggest bulb in the 1
             % sigma area and convolve it with gaussian with sigma = 30
             % (because of distribution analysis
             HIGHTH=exp(-(1)^2/2);% distance of 2 sigma from maximum;
             fix_points = gazeData.points{gazeData.index};
             att_map=points2GaussMap(fix_points',ones(1,length(fix_points)),0,[gazeData.width,gazeData.height],gazeData.pointSigma);
             %[~,BB_POS]=patch_extract([gazeData.width,gazeData.height],gazeData.points{ii},gazeData.pointSigma,0);
             th_att_map=att_map>=HIGHTH;
             BB_pos=regionprops(th_att_map,'BoundingBox');

             if size(BB_pos,1)>1 % more than one position of intrest
                 areas=regionprops(th_att_map,'Area');
                 [areas,idx]=sort(extractfield(areas,'Area'));
                 % if the first is dominant that is your bounding
                 % box and the middle should be the attention point
                 if areas(1) > 2*areas(2)
                     BB_pos = BB_pos(idx(1)).BoundingBox;
                     att_pt = (BB_pos(1:2)+BB_pos(3:4)/2)';
                 else % clutter of Bounding boxes choose the biggest one with the least excentricity
                     ecce = extractfield(regionprops(th_att_map,'Eccentricity'),'Eccentricity')';
                     if ecce(idx(1)) < ecce(idx(2)) % the biggest areas is also more round
                         BB_pos = BB_pos(idx(1)).BoundingBox;
                         att_pt = (BB_pos(1:2)+BB_pos(3:4)/2)';
                     else
                         BB_pos = BB_pos(idx(2)).BoundingBox;
                         att_pt = (BB_pos(1:2)+BB_pos(3:4)/2)';
                     end
                 end
             elseif size(BB_pos,1) == 1 %only one BB
                 % check what the ratio of the bounding box
                 BB_pos = BB_pos.BoundingBox;
                 ratio = BB_pos(3)/BB_pos(4);
                 if ratio > 2 || ratio < 0.5 %(one dimension is twice the other
                     % calc in which side of the Bounding box there's more white pixels
                     if ratio > 2 % width is twice the height
                         BB_pos = uint16(BB_pos);
                         left_bb = sum(sum(th_att_map(BB_pos(2):BB_pos(2)+BB_pos(4),BB_pos(1):BB_pos(1)+round(BB_pos(3)/2))));
                         right_bb = sum(sum(th_att_map(BB_pos(2):BB_pos(2)+BB_pos(4),BB_pos(1)+round(BB_pos(3)/2)+1:BB_pos(1)+BB_pos(3))));
                         BB_pos = double(BB_pos);
                         if right_bb > left_bb
                             att_pt = [BB_pos(1)+3*BB_pos(3)/4,BB_pos(2)+BB_pos(4)/2]';
                         else
                             att_pt = [BB_pos(1)+1*BB_pos(3)/4,BB_pos(2)+BB_pos(4)/2]';
                         end
                     else % height is twice the width
                         BB_pos = uint16(BB_pos);
                         upper_bb = sum(sum(th_att_map(BB_pos(2):BB_pos(2)+BB_pos(4)/2,BB_pos(1):BB_pos(1)+BB_pos(3))));
                         lower_bb = sum(sum(th_att_map(BB_pos(2)+BB_pos(4)/2+1:BB_pos(2)+BB_pos(4),BB_pos(1):BB_pos(1)+BB_pos(3))));
                         BB_pos = double(BB_pos);
                         if upper_bb > lower_bb
                             att_pt = [BB_pos(1)+BB_pos(3)/2,BB_pos(2)+1*BB_pos(4)/4]';
                         else
                             att_pt = [BB_pos(1)+BB_pos(3)/2,BB_pos(2)+3*BB_pos(4)/4]';
                         end
                     end
                 else % just give the middle of the Bounding box
                     att_pt = (BB_pos(1:2)+BB_pos(3:4)/2)';
                 end
             end
             if isempty(BB_pos) % no att_map so put a bulb in the middle
                 att_pt = round([n,m]/2)';
             end
             % end of prediction
             predMap = points2GaussMap(att_pt,ones(1,length(att_pt)),0,[gazeData.width,gazeData.height],2*gazeData.pointSigma);
             predMap = predMap./max(predMap(:));
             
             gazeData.otherMaps(:,:,gazeData.index)=gazeData.otherMaps(:,:,gazeData.index)-gazeData.binaryMaps(:,:,gazeData.index);
             [sim(:,:,ifr), outMaps] = similarityFrame3(predMap, gazeData, measures, ...
                    'self', ...
                    struct('method', 'saliency_PCAF+F+P', 'map', predMapPCAFbest.predMaps(:,:,indFr(ifr))));
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
        save(fullfile(finalResultRoot, [vidnameonly,'_similarity.mat']), 'sim', 'measures', 'methods', 'movieIdx','-v7.3');
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
exit();