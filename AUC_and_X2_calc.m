%% visualize - AUC & X^2
clear all;close all;clc
addpath(genpath('C:\Users\ydishon\Documents\Video_Saliency\Dimarudoy_saliency\Dropbox\toolbox\piotr_toolbox_V2.60'));
diemDataRoot = '\\CGM41\Users\gleifman\Documents\DimaCode\DIEM';%'Z:\RGB-D\DimaCode\DIEM'; % TODO current on external drive
%resFolder='C:\Users\ydishon\Documents\Video_Saliency\FinalResults\PCA_Fusion_v0\';
%resFolder='C:\Users\ydishon\Documents\Video_Saliency\FinalResults\PCA_Fusion_v1\';
%resFolder='C:\Users\ydishon\Documents\Video_Saliency\FinalResults\PCA_Fusion_v2\';
%resFolder='C:\Users\ydishon\Documents\Video_Saliency\FinalResults\PCA_Fusion_v3\';
%resFolder='C:\Users\ydishon\Documents\Video_Saliency\FinalResults\PCA_Fusion_v3_1\';
%resFolder='C:\Users\ydishon\Documents\Video_Saliency\FinalResults\PCA_Fusion_v4\';
%resFolder='C:\Users\ydishon\Documents\Video_Saliency\FinalResults\PCA_Fusion_v5\';
%resFolder='C:\Users\ydishon\Documents\Video_Saliency\FinalResults\PCA_Fusion_v6\';
%resFolder='C:\Users\ydishon\Documents\Video_Saliency\FinalResults\PCA_Fusion_v1\';
%resFolder='C:\Users\ydishon\Documents\Video_Saliency\FinalResults\PCA_Fusion_v2\';
%resFolder='C:\Users\ydishon\Documents\Video_Saliency\FinalResults\PCA_Fusion_v3_new\';
%resFolder='C:\Users\ydishon\Documents\Video_Saliency\FinalResults\PCA_Fusion_v7\';
%resFolder='C:\Users\ydishon\Documents\Video_Saliency\FinalResults\PCA_Fusion_v7_1\';
%resFolder='C:\Users\ydishon\Documents\Video_Saliency\FinalResults\PCA_Fusion_v7_2\';
%resFolder='C:\Users\ydishon\Documents\Video_Saliency\FinalResults\Track_v1\';
%resFolder='C:\Users\ydishon\Documents\Video_Saliency\FinalResults\PCA_Fusion_v8\';
%resFolder='C:\Users\ydishon\Documents\Video_Saliency\FinalResults\PCA_Fusion_v8_1\';
%resFolder='D:\Video_Saliency_Results\FinalResults2\PCA_Fusion_v8_2\';
%resFolder='D:\Video_Saliency_Results\FinalResults2\PCA_Motion_Batch_v0\';
%resFolder='D:\Video_Saliency_Results\FinalResults2\PCA_Spatial_Batch_v1\';
%resFolder='D:\Video_Saliency_Results\FinalResults2\PCA_Fused_Batch_v0\';
%resFolder='D:\Video_Saliency_Results\FinalResults2\PCA_Fused_Batch_v1\';
%resFolder='D:\Video_Saliency_Results\FinalResults3\TreeEnsamble_v0\';
%resFolder='D:\Video_Saliency_Results\FinalResults2\PCA_Fusion_v0Ran\';
%resFolder='D:\Video_Saliency_Results\FinalResults2\PCA_Fusion_v1slic\';
%resFolder='D:\Video_Saliency_Results\FinalResults3\TreeEnsamble_v0\';
%resFolder='D:\Video_Saliency_Results\FinalResults3\TreeEnsamble_v0_smooth\';
%resFolder='D:\Video_Saliency_Results\FinalResults3\TreeEnsamble_v0_smooth1\';
%resFolder='D:\Video_Saliency_Results\FinalResults3\TreeEnsamble_v1_smooth\';
%resFolder='D:\Video_Saliency_Results\FinalResults3\TreeEnsamble_v2_smooth\';
%resFolder='D:\Video_Saliency_Results\FinalResults3\TreeEnsamble_v3_hough\';
%resFolder='D:\Video_Saliency_Results\FinalResults2\PCA_Fusion_RanOrig\';
%resFolder='D:\Video_Saliency_Results\FinalResults2\PCA_Fusion_RanOrig_v1\';
%resFolder='D:\Video_Saliency_Results\FinalResults2\PCA_Fusion_v2_mahalRan\';
%resFolder='D:\Video_Saliency_Results\FinalResults3\TreeEnsamble_v4_clean_wo_x_y\';
%resFolder='D:\Video_Saliency_Results\FinalResults3\TreeEnsamble_v3_hough_and_clean\';
%resFolder='D:\Video_Saliency_Results\FinalResults4\PCA_M_MRF_v0\';
%resFolder='D:\Video_Saliency_Results\FinalResults3\TreeEnsamble_v5_clean_w_SpMo_8_2\';
%resFolder='D:\Video_Saliency_Results\FinalResults3\TreeEnsamble_v5_clean_w_SpMo_all\';
resFolder='\\CGM10\D\Video_Saliency_Results\FinalResults3\TreeEnsamble_v5_clean_w_SpMo_all_morph\';
DataRoot = diemDataRoot;
%videos = videoListLoad(DataRoot, 'DIEM');
videos=importdata(fullfile(DataRoot, 'list.txt'));
measures = {'chisq', 'auc'};
%methods = {'PCA','self', 'center','Dimtry', 'GBVS', 'PQFT'};
%methods = {'PCA_F','self', 'center','Dimtry', 'GBVS', 'PCA_M'};
%methods = {'PCA_M+S','self', 'PCA_S','Dimtry', 'PCA_MP', 'PCA_M'};
%methods = {'Track_v0','self', 'PCA_S','Dimtry', 'GBVS', 'PCA_M'};
%methods = {'Track_v1','self','PCA S','PCAMPolar','PCAF_old','PCA M'};
%methods = {'PCASpBatch','self','PCAF+F+P','Dima','PCAMBatch','PCA M*S'};
%methods = {'PCA_F_Batch','self','PCAF+F+P','Dima','PCAMBatch','PCA M*S'};
%methods = {'Tree_D5_v0','self','PCAF+F+P','Dima'};
%methods = {'PCA_F_ran','self','PCA F','Dima','PCA M','PCA M*S'};
%methods = {'PCA F_slic','self','PCA r_M','PCA r_S','PCA rg_M','PCA rg_S'};
%methods = {'Tree EnsG','self','PCAF+F+P','Dima'};
%methods = {'PCA_F_ran_orig','self','PCA ranM','Dima','PCA ranS'};
%methods = {'PCA_F_ran_orig','self'};
%methods = {'PCA_F_ran_orig','self','center','PCAF+F+P','Dima','GBVS','PQFT','Hou'};
%methods = {'PCA_F_ran_mahal','self','ran_orig','PCAF+F+P','Dima'};
%methods = {'Ens_v3_clean','self','PCA F+F+P','Dima'};
%methods = {'Ens_v3_hough','self','PCA F+F+P','Dima','Ens_v3_clean'};
%methods = {'PCA_F_v8_2_MRF_v0','self','PCA_F_v8_2','Dima'};
%methods = {'v5_clean_w_SpMo_8_2','self','PCA F+F+P','Dima'};
%methods = {'v5_clean_w_SpMo_all','self','PCA F+F+P','Dima'};
methods = {'v5_clean_w_SpMo_all_morph','self','PCA F+F+P','v5_clean_w_SpMo_all','Dima'};



%testIdx = [6,8,10,11,12,14,15,16,34,42,44,48,53,54,55,59,70,74,83,84]; % Used by Borji on DIEM
testIdx = [8,10,11,12,15,16,34,42,44,48,53,55,59,70,74,83,84]; % For Tree Enamble v0

testSubset = 1:length(testIdx);
nt = length(testSubset);
nmeas = length(measures);
for im = 1:length(measures)
    meanChiSq = nan(nt, length(methods));
    sim=cell(nt,1);
    for i = 1:nt
        if exist([resFolder,videos{testIdx(i)},'_similarity.mat'],'file')
            tmp=matfile([resFolder,videos{testIdx(i)},'_similarity.mat']);    
            sim{i}=tmp.sim;
        else
            sim{i}=NaN(length(methods),length(measures));
            fprintf(['Video:',videos{testIdx(i)},' has no Similarity.mat file\n']);
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
    
    figure, bar(meanChiSq);set(gca,'Xlim',[0 size(meanChiSq,1)+6.5]);
    imLabel(lbl, 'bottom', -90, {'FontSize',8, 'Interpreter', 'None'});
    ylabel(measures{im});
    title(sprintf('Mean %s', mat2str(meanMeas, 2)));
    legend(methods,'Location','northeast');
    
    print('-dpng', fullfile(resFolder, sprintf('overall_%s.png', measures{im})));
end

% histogram
visCompareMethods(sim, methods, measures, videos, testIdx(testSubset), 'boxplot', resFolder);