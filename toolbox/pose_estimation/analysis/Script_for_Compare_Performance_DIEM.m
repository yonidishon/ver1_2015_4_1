%% visualize - AUC & X^2 & NSS
%clear all;close all;clc
%%%%%CHANGE THIS IF YOU'DE LIKE TO SAVE%%%%%%%%%%%%%%%%%
sav = 0;
addpath(genpath('\\cgm10\Users\ydishon\Documents\Video_Saliency\Dimarudoy_saliency\Dropbox\toolbox\piotr_toolbox_V2.60'));
addpath(genpath('\\cgm10\Users\ydishon\Documents\Video_Saliency\Dimarudoy_saliency\Dropbox\Matlab\video_attention\release'));
addpath(genpath('\\cgm10\Users\ydishon\Documents\Video_Saliency\toolbox\visualization\figstate'));
diemDataRoot = '\\cgm10\D\DIEM';
loc = '\\cgm10\D\head_pose_estimation\Analysis_All\OBDL_full';
measures = {'chisq','auc','nss'};
%measures = {'chisq','auc'};%,'nss'};
%List of Movies Used by Borji on DIEM
videos=importdata(fullfile(diemDataRoot, 'list.txt'));
testIdx = [6,8,10,11,12,14,15,16,34,42,44,48,53,54,55,59,70,74,83,84];
seq_names = cell(1,numel(testIdx));
videos = videos(testIdx);
for ii = 1:numel(seq_names)
    vid_name_splt = strsplit(lower(videos{ii}),'_');
    for jj=1:numel(vid_name_splt)-1
        abb(jj)= vid_name_splt{jj}(1);
    end
    seq_names(ii) = {abb};
    clear abb
end
% Number of frames (always start from 1) if Inf than all of them
frames = Inf;
clear ii jj testIdx diemDataRoot vid_name_splt
fprintf('Measures::\n');
fprintf('%s\n', measures{:});
%% List of Predictors to measure performance on
% Predinfo(1).name = 'self';
% Predinfo(1).sim_fold = '\\cgm10\D\head_pose_estimation\Analysis_All\OBDL_full';
% Predinfo(1).sim_ind = 2;
Predinfo(1).name = 'Ours (include HOG)';%'Hough_PCA_only_0_8_conf';
Predinfo(1).sim_fold = '\\cgm10\D\head_pose_estimation\Predictions\2016_02_27_Post_MRF2';
Predinfo(1).sim_ind = 3;
Predinfo(2).name = 'Ours (only PCA)';%'Hough_PCA_only_0_8_conf_MRF';
Predinfo(2).sim_fold = '\\cgm10\D\head_pose_estimation\Predictions\2016_02_27_Post_MRF2';
Predinfo(2).sim_ind = 1;
Predinfo(3).name = 'PCAs';
Predinfo(3).sim_fold = '\\cgm10\D\head_pose_estimation\Predictions\DIEMPCApng_PCAs\result_eval';
Predinfo(3).sim_ind = 1;
Predinfo(4).name = 'PCAm';
Predinfo(4).sim_fold = '\\cgm10\D\head_pose_estimation\Predictions\DIEMPCApng_PCAm\result_eval';
Predinfo(4).sim_ind = 1;
Predinfo(13).name = 'Roduy';
Predinfo(13).sim_fold = '\\cgm10\D\head_pose_estimation\Analysis_All\OBDL_full';
Predinfo(13).sim_ind = 6;
Predinfo(5).name = 'OBDL-MRF';
Predinfo(5).sim_fold = '\\cgm10\D\head_pose_estimation\Analysis_All\OBDL_full';
Predinfo(5).sim_ind = 4;
Predinfo(6).name = 'PMES';
Predinfo(6).sim_fold = '\\cgm10\D\head_pose_estimation\Analysis_All\OBDL_full\compressed';
Predinfo(6).sim_ind = 7;
Predinfo(7).name = 'MAM';
Predinfo(7).sim_fold = '\\cgm10\D\head_pose_estimation\Analysis_All\OBDL_full\compressed';
Predinfo(7).sim_ind = 1;
Predinfo(8).name = 'PIM-ZEN';
Predinfo(8).sim_fold = '\\cgm10\D\head_pose_estimation\Analysis_All\OBDL_full\compressed';
Predinfo(8).sim_ind = 6;
Predinfo(9).name = 'PIM-MCS';
Predinfo(9).sim_fold = '\\cgm10\D\head_pose_estimation\Analysis_All\OBDL_full\compressed';
Predinfo(9).sim_ind = 5;
Predinfo(10).name = 'MCSDM';
Predinfo(10).sim_fold = '\\cgm10\D\head_pose_estimation\Analysis_All\OBDL_full\compressed';
Predinfo(10).sim_ind = 3;
Predinfo(11).name = 'MSM-SM';
Predinfo(11).sim_fold = '\\cgm10\D\head_pose_estimation\Analysis_All\OBDL_full\compressed';
Predinfo(11).sim_ind = 4;
Predinfo(12).name = 'PNSP-CS';
Predinfo(12).sim_fold = '\\cgm10\D\head_pose_estimation\Analysis_All\OBDL_full\compressed';
Predinfo(12).sim_ind = 8;
% Predinfo(13).name = 'OBDL';
% Predinfo(13).sim_fold = '\\cgm10\D\head_pose_estimation\Analysis_All\OBDL_full';
% Predinfo(13).sim_ind = 5;
% Predinfo(9).name = 'GBVS';
% Predinfo(9).sim_fold = '\\cgm10\D\Video_Saliency_Results\FinalResults\PCA_Fusion_v1';
% Predinfo(9).sim_ind = 5;
% Predinfo(9).name = 'houghPCAMRF+F+P';
% Predinfo(9).sim_fold = '\\cgm10\D\head_pose_estimation\Predictions\2016_04_23_Faces_and_poselets';
% Predinfo(9).sim_ind = 1;

% Predinfo(3).name = 'Hough_PatchSz20';
% Predinfo(3).sim_fold = '\\cgm10\D\head_pose_estimation\Analysis_All\OBDL_full';
% Predinfo(3).sim_ind = 3;
% Predinfo(9).name = 'Hough_PCA_only_0_8_conf';
% Predinfo(9).sim_fold = '\\cgm10\D\head_pose_estimation\Predictions\22_02_2016_Pcas_only_subpatches_16_0_8conf\result_eval';
% Predinfo(9).sim_ind = 1;
% Predinfo(10).name = 'Hough_PCA_only_0_8_conf_MRF';
% Predinfo(10).sim_fold = '\\cgm10\D\head_pose_estimation\Predictions\2016_02_27_Post_MRF2';
% Predinfo(10).sim_ind = 1;
fprintf('Reporting Results on the following methods::\n');

nm = extractfield(Predinfo,'name')';
fold = extractfield(Predinfo,'sim_fold')';
str = [nm,fold]';
fprintf('%s resides in:: %s\n',str{:});
fprintf('Indices:: %s\n',mat2str(extractfield(Predinfo,'sim_ind')'));
clear str fold nm
%% Do the Calculations of the similarity
 calc_graphs_and_mean( Predinfo, measures, videos, frames ,seq_names,sav,loc);
%% Finish Up
fprintf('Finished Processing:  %s\n',datestr(datetime('now')));
rmpath(genpath('\\cgm10\Users\ydishon\Documents\Video_Saliency\Dimarudoy_saliency\Dropbox\toolbox\piotr_toolbox_V2.60'));
rmpath(genpath('\\cgm10\Users\ydishon\Documents\Video_Saliency\Dimarudoy_saliency\Dropbox\toolbox\piotr_toolbox_V2.60\toolbox'));
rmpath(genpath('\\cgm10\Users\ydishon\Documents\Video_Saliency\Dimarudoy_saliency\Dropbox\Matlab\video_attention\release'));
rmpath(genpath('\\cgm10\Users\ydishon\Documents\Video_Saliency\Dimarudoy_saliency\GDrive\Software\dollar_261'));
rmpath(genpath('\\cgm10\Users\ydishon\Documents\Video_Saliency\toolbox\visualization\figstate'));