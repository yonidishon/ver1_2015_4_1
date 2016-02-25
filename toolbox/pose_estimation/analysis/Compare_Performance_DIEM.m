%% visualize - AUC & X^2
clear all;close all;clc
addpath(genpath('C:\Users\ydishon\Documents\Video_Saliency\Dimarudoy_saliency\Dropbox\toolbox\piotr_toolbox_V2.60'));
addpath(genpath('C:\Users\ydishon\Documents\Video_Saliency\Dimarudoy_saliency\Dropbox\Matlab\video_attention\release'));
addpath(genpath('C:\Users\ydishon\Documents\Video_Saliency\toolbox\visualization\figstate'));
diemDataRoot = 'D:\DIEM';%'Z:\RGB-D\DimaCode\DIEM'; % TODO current on external drive
%resFolder='D:\Video_Saliency_Results\FinalResults3new\';
resFolder='\\cgm10\D\head_pose_estimation\';

DataRoot = diemDataRoot;
%videos = videoListLoad(DataRoot, 'DIEM');
videos=importdata(fullfile(DataRoot, 'list.txt'));
measures = {'chisq', 'auc','nss'};
% methods = {'pred_PCAmPCAs',...
%     'pred_PCAmPCAs_w_max',...
%     'pred_HOGPCAmPCAs',...
%     'pred_origandPCAmPCAs',...
%     'P-5_GT-C_PCAsPCAm',...
%     'PCAs',...  
%     'PCAm',...
%     'HoughForest',...
%     'PCA_F F+P',...
%     'DIMA','Humans'};
methods = {'Post',...
    'No Post'};
basefolder = '\\CGM10\D\head_pose_estimation';
suffixfold = 'result_eval\';
resfolder_method = {fullfile(basefolder,'pred_origandPCAmPCAs_15_float_post1',suffixfold),...
    fullfile(basefolder,'pred_origandPCAmPCAs_15_float',suffixfold)};
%     resfolder_method={fullfile(basefolder,methods{1},suffixfold),...
%         fullfile(basefolder,methods{2},suffixfold),...
%         '\\Cgm10\d\Video_Saliency_Results\FinalResults2\PCA_Fusion_v8_2\',... % PCA_F F+P
%         '\\Cgm10\d\Video_Saliency_Results\FinalResults2\PCA_Fusion_v8_2\',... % Dima
%         '\\Cgm10\d\Video_Saliency_Results\FinalResults2\PCA_Fusion_v8_2\'}; % Humans
%meth_loc=[1,1,1,4,2];           
meth_loc=[1,1];           
%testIdx = [8,10,11,12,15,16,34,42,44,48,53,55,59,70,74,83,84]; %subset without 3 videos used for training
testIdx = [6,8,10,11,12,14,15,16,34,42,44,48,53,54,55,59,70,74,83,84]; % Used by Borji on DIEM
testSubset = 1:length(testIdx);
nt = length(testSubset);
nmeas = length(measures);
for im = 1:length(measures)
    meanChiSq = nan(nt, length(methods));
    sim=cell(nt,1);
    for i = 1:nt
            %tmp=matfile([resfolder_method{5},videos{testIdx(i)},'_similarity.mat']);%TODO
            tmp=matfile([resfolder_method{1},videos{testIdx(i)},'_similarity.mat']);
            sim{i}=zeros(length(methods),nmeas,size(tmp.sim,3));
            sim_length=size(tmp.sim,3);
            clear tmp
        for k=1:length(methods)
             if exist([resfolder_method{k},videos{testIdx(i)},'_similarity.mat'],'file')
                tmp=matfile([resfolder_method{k},videos{testIdx(i)},'_similarity.mat']);
                %fprintf('%s\n',mat2str(size(tmp.sim)));
                sim{i}(k,:,:)=tmp.sim(meth_loc(k),:,1:sim_length);
             else
                 sim{i}(k,:,:)=NaN(size(tmp.sim,2),size(tmp.sim,3));
                    fprintf(['Video:',videos{testIdx(i)},' has no Similarity.mat file','For Method',methods{k},'\n']);
             end
        end
        for j = 1:length(methods)
            chiSq = sim{i}(j,im,:);
            meanChiSq(i, j) = mean(chiSq(~isnan(chiSq)));
        end
    end
    
    ind = find(~isnan(meanChiSq(:,1)));
    meanChiSq = meanChiSq(ind, :);
    meanMeas = mean(meanChiSq, 1);
    lbl = videos(testIdx(testSubset(ind)));
    
    % add dummy if there is only one test
    if (size(meanChiSq, 1) == 1), meanChiSq = [meanChiSq; zeros(1, length(methods))]; end;
    
    f=figure, bar(meanChiSq);set(gca,'Xlim',[0 size(meanChiSq,1)+6.5]);
    imLabel(lbl, 'bottom', -90, {'FontSize',8, 'Interpreter', 'None'});
    ylabel(measures{im});
    title(sprintf('Mean %s', mat2str(meanMeas, 2)));
    
    leg = legend(methods,'Location','northeast', 'Interpreter', 'none','FontSize',9);
    maxfig(f,1);
    pause(5);
    print('-dpng', fullfile(resFolder, sprintf('mean_%s_scores.png', measures{im})));
end

% histogram
visCompareMethods(sim, methods, measures, videos, testIdx(testSubset), 'boxplot', resFolder);