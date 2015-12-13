% a script to measure the number of frames (per movie) that our
% implementations does better than Dimtry.
clear all;close all;clc
% show statistics:
% 1. A bar graph movie and precentage of frames in each movie we are doing better.
% 2. Need some sort of statistics on the conscutive frames (mean and median
% length (maybe a graph?).

basefolder = '\\CGM10\D\head_pose_estimation';
suffixfold = 'result_eval_fixed\';
videos_fold = {fullfile(basefolder,'pred_origandPCAmPCAs_15_float_post1'),...
               fullfile(basefolder,'pred_origandPCAmPCAs_15_float'),...
               '\\Cgm10\d\Video_Saliency_Results\FinalResults2\PCA_Fusion_v8_2\'};% Dima;
%addpath(genpath('\\CGM10\Users\ydishon\Documents\Video_Saliency\Dimarudoy_saliency\Dropbox\Matlab\video_attention'));
videos=importdata(fullfile('\\cgm10\d\DIEM', 'list.txt'));
testIdx = [6,8,10,11,12,14,15,16,34,42,44,48,53,54,55,59,70,74,83,84]; % Used by Borji on DIEM
videos=videos(testIdx);

VISDST = fullfile(videos_fold{1},suffixfold,'post_analysis');
vis_pre_vec = zeros(2,size(videos,1));
vis_post_vec = zeros(2,size(videos,1));
vis_ffp_vec = zeros(2,size(videos,1));
for ii=1:size(videos,1)
    data_post = importdata(fullfile(videos_fold{1},suffixfold,[videos{ii},'_similarity.mat']),'sim'); 
    FFPsim = squeeze(data_post.sim(3,:,:)); 
    data_post.sim = squeeze(data_post.sim(1,:,:));
    data_pre = importdata(fullfile(videos_fold{2},suffixfold,[videos{ii},'_similarity.mat']),'sim');  data_pre.sim = squeeze(data_pre.sim(1,:,:));
    data_dima = importdata(fullfile(videos_fold{3},[videos{ii},'_similarity.mat']),'sim');  data_dima.sim = squeeze(data_dima.sim(4,:,:));
    % fprintf('%s: length_pre = %i ,length_post = %i ,length_dima = %i\n',videos{ii},size(data_pre.sim,2),size(data_post.sim,2),size(data_dima.sim,2)); % - checked
    vid_len = size(data_dima.sim,2);
    pre_vs_dima = data_pre.sim > repmat([mean(data_dima.sim(1,~isnan(data_dima.sim(1,:))));mean(data_dima.sim(2,~isnan(data_dima.sim(2,:))))],1,vid_len); % 1st row is Chi-square 2nd row is AUC
    post_vs_dima = data_post.sim > repmat([mean(data_dima.sim(1,~isnan(data_dima.sim(1,:))));mean(data_dima.sim(2,~isnan(data_dima.sim(2,:))))],1,vid_len);
    ffp_vs_dima = FFPsim > repmat([mean(data_dima.sim(1,~isnan(data_dima.sim(1,:))));mean(data_dima.sim(2,~isnan(data_dima.sim(2,:))))],1,vid_len);
    vis_pre_vec(:,ii) = [sum(~pre_vs_dima(1,:));sum(pre_vs_dima(2,:))]./vid_len;
    vis_post_vec(:,ii) = [sum(~post_vs_dima(1,:));sum(post_vs_dima(2,:))]./vid_len;
    vis_ffp_vec(:,ii) = [sum(~ffp_vs_dima(1,:));sum(ffp_vs_dima(2,:))]./vid_len;
    %figure('Name',videos{ii});
    %plot(1:vid_len,data_pre.sim - data_dima.sim);% TODO plot of the difference between Dmitry and result (ignoring the NaN)
    
    %fprintf('Dimtry''s is: %s \n',mat2str(mean(data_dima.sim,2)));
end
% Chi-square bar
figure('Name','Chi-Square');
bar([vis_pre_vec(1,:)',vis_post_vec(1,:)',vis_ffp_vec(1,:)']);
ax = gca;
ax.XTick = 1:20;
ax.XTickLabel = videos;
set(ax,'TickLabelInterpreter','none');
ax.XTickLabelRotation =45;
legend('Original','PostProcssing','F+F+P');
title('Chi-Square (%) of frames won over Dmitry''s mean for that movie -(Higher is better)');
% AUC bar
figure('Name','AUC');
bar([vis_pre_vec(2,:)',vis_post_vec(2,:)',vis_ffp_vec(1,:)']);
ax = gca;
ax.XTick = 1:20;
ax.XTickLabel = videos;
set(ax,'TickLabelInterpreter','none');
ax.XTickLabelRotation =45;
legend('Original','PostProcssing','F+F+P');
title('AUC frames win (% of frames in movie) per movie over Dmitry code mean for that movie (Higher is better)');