% Visualization for pre and post processing analysis of houghforest
% (05/01/2016)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                   %               %              %              %
%   GT_CLUSTERED    %   VIS_0_1     %   VIS_0_2    %    VIS_0_3   %
%                   %               %              %              %  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                   %               %              %              %
%       FRAME       %   VIS_1_1     %   PCAS       %    PCAM      %
%                   %               %              %              %
basefolder = '\\CGM10\D\head_pose_estimation';
suffixfold = 'result_eval\';
videos_fold = {fullfile(basefolder,'29_12_2015_No_PCA'),...
    fullfile(basefolder,'2015_24_12_new_train_form_2S_PatchSz20')};
addpath(genpath('\\CGM10\Users\ydishon\Documents\Video_Saliency\Dimarudoy_saliency\Dropbox\Matlab\video_attention'));
% VIS_0_1 = '\\cgm10\D\Video_Saliency_Results\FinalResults3\TreeEnsamble_v7_w_SpMo_patch_cluster';
% VIS_0_1_TEXT ='Patches(7x7) CL 50%';
% VIS_0_2 = '\\cgm10\D\Video_Saliency_Results\FinalResults3\TreeEnsamble_v5_clean_w_SpMo_all';
% VIS_0_2_TEXT ='Pixel NN';
% VIS_0_3 = '\\cgm10\D\Video_Saliency_Results\FinalResults3\TreeEnsamble_v5_1_w_SpMo_patch_cluster';
% VIS_0_3_TEXT ='Patches(7x7) CL Rand';
% VIS_1_1 = ;
% VIS_1_1_TEXT ='';
% VIDEO_LOC='\\cgm41\users\gleifman\Documents\DimaCode\DIEM\video_unc';
% OF_LOC='\\cgm10\D\Video_Saliency_cache_Backup';
GAZE_LOC='\\cgm10\D\DIEM\gaze';
VISDST = fullfile(videos_fold{1},suffixfold,'Change_analysis'); % TODO
videos=importdata(fullfile('\\cgm10\d\DIEM', 'list.txt'));
testIdx = [6,8,10,11,12,14,15,16,34,42,44,48,53,54,55,59,70,74,83,84]; % Used by Borji on DIEM
videos=videos(testIdx);
% addpath(genpath('\\cgm10\Users\ydishon\Documents\Video_Saliency\code_v3\toolbox\PCA_Saliency'));
 
FRMS_CNT=300;
h=figure('Visible','off');
reverseStr = '';

% frame_size=[540,2880];
frame_size=[800,1080];
pos=[10,10];
height = (frame_size(1)-3*(frame_size(2)/3)/4)/2; % normilized height of graphs
shift =29;
% figure();
for ii=1:size(videos,1)
    wobj=VideoWriter(fullfile(VISDST,[videos{ii},'.mp4']),'MPEG-4');
    open(wobj);
    msg=sprintf('working on %s\r',videos{ii});
    fprintf([reverseStr, msg]);reverseStr = repmat(sprintf('\b'), 1, length(msg));
    gazefile=load(fullfile(GAZE_LOC,[videos{ii},'.mat']));
    gazefile=gazefile.data;
    [m,n]=size(imread(fullfile(videos_fold{1},videos{ii},sprintf('%06d_sc0_c0_predmap.png',1))));
    data_post = importdata(fullfile(videos_fold{1},suffixfold,[videos{ii},'_similarity.mat']),'sim');
    data_pre = importdata(fullfile(videos_fold{2},suffixfold,[videos{ii},'_similarity.mat']),'sim');
    FRMS_CNT = length(dir(fullfile(videos_fold{1},videos{ii},'*.png')))-shift-30;%size(data_post.sim,3); %TODO
    lines_mat = [round(n/4),1,round(n/4),m;...% vert x1,y1,x2,y2
                 round(2*n/4),1,round(2*n/4),m;... %vert
                 round(3*n/4),1,round(3*n/4),m;... %vert
                 round(3*n/4),1,round(3*n/4),m;... % hor
                 1,round(1*m/3),n,round(1*m/3);... % hor
                 1,round(2*m/3),n,round(2*m/3);... % hor
                       ];
    for jj=1:FRMS_CNT
        fr = jj+shift; % to make data aligned with similarity matrices
        gzpoints=gazefile.points{fr}; 
        gazePts = gzpoints(~isnan(gzpoints(:,1)), :);
        gazedensemap=points2GaussMap(gazePts', ones(1, size(gazePts, 1)), 0, [n m], gazefile.pointSigma);
        gazedensemap=insertText(gazedensemap,pos,'GT','FontSize',8);
        gazedensemap = insertShape(gazedensemap,'Line',lines_mat);
        premap = imread(fullfile(videos_fold{2},videos{ii},sprintf('%06d_sc0_c0_predmap.png',fr)));
        postmap = imread(fullfile(videos_fold{1},videos{ii},sprintf('%06d_sc0_c0_predmap.png',fr)));
        premap=insertText(im2uint8(premap),pos,'With PCAs','FontSize',8);
        postmap=insertText(im2uint8(postmap),pos,'NO PCAs','FontSize',8);
        premap = insertShape(premap,'Line',lines_mat);
        postmap = insertShape(postmap,'Line',lines_mat);
        [chi_graph,auc_graph] = Sim_pre_post_vis(squeeze(data_pre.sim(1,:,1:FRMS_CNT)),squeeze(data_post.sim(1,:,1:FRMS_CNT)),jj,shift,height);% TODO : instead of 1:FRMS_CNT      
        result_frame=[imresize(im2uint8(gazedensemap),[270,360]),imresize(premap,[270,360]),...
           imresize(postmap,[270,360]);auc_graph;chi_graph];
%          imshow(result_frame);
%          drawnow;
        writeVideo(wobj,result_frame);
    end
    close(wobj);
    clear data_post data_pre
end;


