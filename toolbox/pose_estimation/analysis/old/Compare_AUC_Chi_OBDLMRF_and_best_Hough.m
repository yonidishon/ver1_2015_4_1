%% visualize - AUC & X^2
clear all;close all;clc
addpath(genpath('\\cgm10\Users\ydishon\Documents\Video_Saliency\Dimarudoy_saliency\Dropbox\toolbox\piotr_toolbox_V2.60'));
addpath(genpath('\\cgm10\Users\ydishon\Documents\Video_Saliency\Dimarudoy_saliency\Dropbox\Matlab\video_attention\release'));
addpath(genpath('\\cgm10\Users\ydishon\Documents\Video_Saliency\toolbox\visualization\figstate'));
diemDataRoot = '\\cgm10\D\DIEM';%'Z:\RGB-D\DimaCode\DIEM'; % TODO current on external drive
%resFolder='D:\Video_Saliency_Results\FinalResults3new\';
resFolder='\\cgm10\D\head_pose_estimation\Analysis_All\OBDL_full';
predFolder ='\\cgm10\D\head_pose_estimation\Analysis_All\OBDL_full';
DataRoot = diemDataRoot;
%videos = videoListLoad(DataRoot, 'DIEM');
videos=importdata(fullfile(DataRoot, 'list.txt'));
measures = {'chisq','auc','nss'};
% my_methods = dir(predFolder);my_methods = extractfield(my_methods,'name');
% my_methods = my_methods(~ismember(my_methods,{'.','..'}))';
% exterenal_methods =[];%TODO
% methods = [my_methods;exterenal_methods];%TODO
%methods = {'self','Hough','OBDL-MRF','OBDL'};
methods = {'self','Hough_15_p','Hough_PatchSz20','PCAs','PCAm','Roduy','OBDL-MRF','OBDL'};
%basefolder = '\\CGM10\D\head_pose_estimation';
%suffixfold = 'result_eval\';
% resfolder_method = {fullfile(basefolder,'pred_origandPCAmPCAs_15_float_post1',suffixfold),...
%     fullfile(basefolder,'pred_origandPCAmPCAs_15_float',suffixfold)};
%     resfolder_method={fullfile(basefolder,methods{1},suffixfold),...
%         fullfile(basefolder,methods{2},suffixfold),...
%         '\\Cgm10\d\Video_Saliency_Results\FinalResults2\PCA_Fusion_v8_2\',... % PCA_F F+P
%         '\\Cgm10\d\Video_Saliency_Results\FinalResults2\PCA_Fusion_v8_2\',... % Dima
%         '\\Cgm10\d\Video_Saliency_Results\FinalResults2\PCA_Fusion_v8_2\'}; % Humans
% meth_loc=[1,1,1,4,2];           
 meth_loc=[2,1,3,6,4,5];           
%testIdx = [8,10,11,12,15,16,34,42,44,48,53,55,59,70,74,83,84]; %subset without 3 videos used for training
testIdx = [6,8,10,11,12,14,15,16,34,42,44,48,53,54,55,59,70,74,83,84]; % Used by Borji on DIEM
seq_names = {'blicb'  'bws'  'ds'   'abb'  'abl'   'ai'   'aic'   'ail'   'hp6t'   'mg'   'mtnin' ...
    'ntbr' 'nim' 'os'  'pas'  'pnb'  'ss'  'swff'  'tucf'  'ufci'};
testSubset = 1:length(testIdx);
nt = length(testSubset);
nmeas = length(measures);
for im = 1:length(measures)
    meanChiSq = nan(nt, length(methods));
    sim=cell(nt,1);
    for i = 1:nt
            %tmp=matfile([resfolder_method{5},videos{testIdx(i)},'_similarity.mat']);%TODO
            tmp = matfile(fullfile(predFolder,[videos{testIdx(i)},'_similarity.mat']));
            sim{i}=zeros(length(methods),nmeas,size(tmp.sim,3));
            sim_length = size(tmp.sim,3);
            sim_height = size(tmp.sim,2);
            clear tmp
        for k=1:length(methods)
             if exist(fullfile(predFolder,[videos{testIdx(i)},'_similarity.mat']),'file')
                tmp=matfile(fullfile(predFolder,[videos{testIdx(i)},'_similarity.mat']));
                %fprintf('%s\n',mat2str(size(tmp.sim)));
                %sim{i}(k,:,:)=tmp.sim(meth_loc(k),:,1:sim_length);
                sim{i}(k,:,:)=tmp.sim(meth_loc(k),:,1:sim_length);
             else
                 sim{i}(k,:,:)=NaN(sim_height,sim_length);
                    fprintf(['Video:',videos{testIdx(i)},' has no Similarity.mat file',' For Method ',methods{k},'\n']);
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
    for ii =1:length(meanMeas)
        fprintf('%s : Mean (%s)  %.2f\n',methods{ii},measures{im},meanMeas(ii));
    end
    %lbl = videos(testIdx(testSubset(ind)));
    lbl = seq_names;
    % add dummy if there is only one test
    if (size(meanChiSq, 1) == 1), meanChiSq = [meanChiSq; zeros(1, length(methods))]; end;
    
    f=figure;
    bar(meanChiSq);set(gca,'Xlim',[0 size(meanChiSq,1)+6.5]);
    imLabel(lbl, 'bottom', -90, {'FontSize',8, 'Interpreter', 'None'});
    ylabel(measures{im});
    title(sprintf('Mean %s', mat2str(meanMeas, 2)));
    
    leg = legend(methods,'Location','northeast', 'Interpreter', 'none','FontSize',9);
    %maxfig(f,1);
    pause(5);
    %print('-dpng', fullfile(predFolder, sprintf('mean_%s_scores.png', measures{im})));
    
end

% histogram
visCompareMethods(sim, methods, measures, lbl, testIdx(testSubset), 'boxplot');
fprintf('Finished Processing:  %s\n',datestr(datetime('now')));
rmpath(genpath('\\cgm10\Users\ydishon\Documents\Video_Saliency\Dimarudoy_saliency\Dropbox\toolbox\piotr_toolbox_V2.60'));
rmpath(genpath('\\cgm10\Users\ydishon\Documents\Video_Saliency\Dimarudoy_saliency\Dropbox\Matlab\video_attention\release'));
rmpath(genpath('\\cgm10\Users\ydishon\Documents\Video_Saliency\toolbox\visualization\figstate'));