function [] = calc_graphs_and_mean( Predinfo, measures, videos, frames , seq_names,sav,loc )
if ~exist('sav','var')
    sav = 0;
end
pred_nms = extractfield(Predinfo,'name');
sim_folds = extractfield(Predinfo,'sim_fold');
sim_inds = extractfield(Predinfo,'sim_ind');
nmeas = length(measures);
nt = length(videos);
for im = 1:length(measures)
    meanChiSq = nan(nt, length(pred_nms));
    sim=cell(nt,1);
    for ii = 1:nt
            
            if frames == Inf
                tmp = matfile(fullfile(sim_folds{1},[videos{ii},'_similarity.mat']));
                sim_length = size(tmp.sim,3);
                sim{ii}=zeros(length(pred_nms),nmeas,size(tmp.sim,3));
                clear tmp;
            else
                sim{ii}=zeros(length(pred_nms),nmeas,frames);
                sim_length = frames;
            end
            
        for k=1:length(pred_nms)
             if exist(fullfile(sim_folds{k},[videos{ii},'_similarity.mat']),'file')
                tmp=matfile(fullfile(sim_folds{k},[videos{ii},'_similarity.mat']));
                sim{ii}(k,:,:)=tmp.sim(sim_inds(k),:,1:sim_length);
             else
                 sim{ii}(k,:,:)=NaN(nmeas,sim_length);
                    fprintf(['Video:',videos{ii},' has no Similarity.mat file',' For Method ',pred_nms{k},'\n']);
             end
        end
        for j = 1:length(pred_nms)
            chiSq = sim{ii}(j,im,:);
            meanChiSq(ii, j) = mean(chiSq(~isnan(chiSq)));
        end
    end
    
    ind = find(~isnan(meanChiSq(:,1)));
    meanChiSq = meanChiSq(ind, :);
    meanMeas = mean(meanChiSq, 1);
    for ii =1:length(meanMeas)
        fprintf('%s : Mean (%s)  %.2f\n',pred_nms{ii},measures{im},meanMeas(ii));
    end
    %lbl = videos(testIdx(testSubset(ind)));
    lbl = seq_names;
    % add dummy if there is only one test
    if (size(meanChiSq, 1) == 1), meanChiSq = [meanChiSq; zeros(1, length(pred_nms))]; end;
    
    f=figure;
    mycolors =[0    1.0000         0
         0    0.6667         0
         0    0.3333         0
    1.0000         0         0
    0.6667         0         0];
theircolors =[ 0.7500    0.7500    0.7500
    0.5000    0.5000    0.5000
    0.2500    0.2500    0.2500];
%     mymap = [1.0000    1.0000         0
%     1.0000         0    1.0000
%     0.6667         0         0
%          0    0.3333         0
%          0    1.0000         0
%          0         0    0.6667
%          0         0         0
%     0.6667    0.6667    0.6667];
mymap = [mycolors;theircolors];
    b = bar(meanChiSq);colormap(mymap); set(gca,'Xlim',[0 size(meanChiSq,1)+6.5]);
    b(2).EdgeColor = 'k';
    imLabel(lbl, 'bottom', -45, {'FontSize',8, 'Interpreter', 'None'});
    ylabel(measures{im});
    title(sprintf('Mean %s', mat2str(meanMeas, 2)));
    
    leg = legend(pred_nms,'Location','northeast', 'Interpreter', 'none','FontSize',9);
    %maxfig(f,1);
    pause(5);
    %print('-dpng', fullfile(predFolder, sprintf('mean_%s_scores.png', measures{im})));
    if sav
        formatOut = 'yyyymmdd';
        dstr=datestr(now,formatOut);
        print(f,fullfile(loc,sprintf('%s_mean_%s',measures{im},dstr)),'-depsc','-r300');
    end
    
end

% histogram
% -1 is DUMMY bacause we don't use it in visCompareMethods
visCompareMethods(sim, pred_nms, measures, lbl, -1, 'boxplot');


end

