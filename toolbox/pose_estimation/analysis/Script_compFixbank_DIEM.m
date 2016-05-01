%% visualize - AUC & X^2 & NSS
clear all;close all;clc
addpath(genpath('\\cgm10\Users\ydishon\Documents\Video_Saliency\Dimarudoy_saliency\Dropbox\toolbox\piotr_toolbox_V2.60'));
addpath(genpath('\\cgm10\Users\ydishon\Documents\Video_Saliency\Dimarudoy_saliency\Dropbox\Matlab\video_attention\release'));
addpath(genpath('\\cgm10\Users\ydishon\Documents\Video_Saliency\toolbox\visualization\figstate'));
diemDataRoot = '\\cgm10\D\DIEM';

measures = {'chisq','auc','nss'};
%List of Movies Used by Fixation Bank on DIEM
videos=importdata(fullfile(diemDataRoot, 'list.txt'));
testIdx = [35,17,16,56,11,57,69,82,48,67,46,81,30,31,47,25,75,73,74,26,65,9,62,40,7,50,70]; % Fixbank
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
% 1st exp no resizing
% Predinfo(1).name = 'self';
% Predinfo(1).sim_fold = '\\cgm10\d\head_pose_estimation\Predictions\2016_04_07_Fix_compare\result_eval';
% Predinfo(1).sim_ind = 2;
% Predinfo(2).name = 'Ours (No MRF)';%'Hough_p_MRF';
% Predinfo(2).sim_fold = '\\cgm10\d\head_pose_estimation\Predictions\2016_04_07_Fix_compare\result_eval';
% Predinfo(2).sim_ind = 1;
Predinfo(1).name = 'self';
Predinfo(1).sim_fold = '\\cgm10\d\head_pose_estimation\Predictions\\2016_04_07_Fix_MRFComp';
Predinfo(1).sim_ind = 2;
Predinfo(2).name = 'Ours';%'Hough_p_MRF';
Predinfo(2).sim_fold = '\\cgm10\d\head_pose_estimation\Predictions\\2016_04_07_Fix_MRFComp';
Predinfo(2).sim_ind = 1;
Predinfo(3).name = 'Ours (No MRF)';%'Hough_p_MRF';
Predinfo(3).sim_fold = '\\cgm10\d\head_pose_estimation\Predictions\\2016_04_07_Fix_MRFComp';
Predinfo(3).sim_ind = 3;
% Predinfo(3).name = 'Ours';%'Hough_15_p';
% Predinfo(3).sim_fold = '\\cgm10\d\head_pose_estimation\Predictions\2016_04_07_Fix_compare';
% Predinfo(3).sim_ind = 3;
% Predinfo(4).name = 'PCAs';
% Predinfo(4).sim_fold = '\\cgm10\D\head_pose_estimation\Predictions\DIEMPCApng_PCAs\result_eval';
% Predinfo(4).sim_ind = 1;
% Predinfo(5).name = 'PCAm';
% Predinfo(5).sim_fold = '\\cgm10\D\head_pose_estimation\Predictions\DIEMPCApng_PCAm\result_eval';
% Predinfo(5).sim_ind = 1;
% Predinfo(6).name = 'Roduy';
% Predinfo(6).sim_fold = '\\cgm10\D\head_pose_estimation\Analysis_All\OBDL_full';
% Predinfo(6).sim_ind = 6;
% Predinfo(7).name = 'OBDL-MRF';
% Predinfo(7).sim_fold = '\\cgm10\D\head_pose_estimation\Analysis_All\OBDL_full';
% Predinfo(7).sim_ind = 4;
% Predinfo(8).name = 'OBDL';
% Predinfo(8).sim_fold = '\\cgm10\D\head_pose_estimation\Analysis_All\OBDL_full';
% Predinfo(8).sim_ind = 5;
% Predinfo(9).name = 'OBDL';
% Predinfo(9).sim_fold = '\\cgm10\D\head_pose_estimation\Analysis_All\OBDL_full';
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
 calc_graphs_and_mean( Predinfo, measures, videos, frames ,seq_names);
%% Finish Up
fprintf('Finished Processing:  %s\n',datestr(datetime('now')));
rmpath(genpath('\\cgm10\Users\ydishon\Documents\Video_Saliency\Dimarudoy_saliency\Dropbox\toolbox\piotr_toolbox_V2.60'));
rmpath(genpath('C:\Users\ydishon\Documents\Video_Saliency\Dimarudoy_saliency\Dropbox\toolbox\piotr_toolbox_V2.60\toolbox'));
rmpath(genpath('\\cgm10\Users\ydishon\Documents\Video_Saliency\Dimarudoy_saliency\Dropbox\Matlab\video_attention\release'));
rmpath(genpath('\\cgm10\Users\ydishon\Documents\Video_Saliency\Dimarudoy_saliency\GDrive\Software\dollar_261'));
rmpath(genpath('\\cgm10\Users\ydishon\Documents\Video_Saliency\toolbox\visualization\figstate'));