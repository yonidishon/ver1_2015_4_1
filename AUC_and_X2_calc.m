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
resFolder='C:\Users\ydishon\Documents\Video_Saliency\FinalResults\PCA_Fusion_v8_1\';

DataRoot = diemDataRoot;
%videos = videoListLoad(DataRoot, 'DIEM');
videos=importdata(fullfile(DataRoot, 'list.txt'));
measures = {'chisq', 'auc'};
%methods = {'PCA','self', 'center','Dimtry', 'GBVS', 'PQFT'};
%methods = {'PCA_F','self', 'center','Dimtry', 'GBVS', 'PCA_M'};
%methods = {'PCA_M+S','self', 'PCA_S','Dimtry', 'PCA_MP', 'PCA_M'};
%methods = {'Track_v0','self', 'PCA_S','Dimtry', 'GBVS', 'PCA_M'};
%methods = {'Track_v1','self','PCA S','PCAMPolar','PCAF_old','PCA M'};
methods = {'PCAF+F+P','self','PCA S','Dima','PCA MP','PCA M*S'};
testIdx = [6,8,10,11,12,14,15,16,34,42,44,48,53,54,55,59,70,74,83,84];
testSubset = 1:length(testIdx);
nt = length(testSubset);
nmeas = length(measures);
for im = 1:length(measures)
    meanChiSq = nan(nt, length(methods));
    sim=cell(nt,1);
    for i = 1:nt
        tmp=matfile([resFolder,videos{testIdx(i)},'_similarity.mat']);    
        sim{i}=tmp.sim;
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