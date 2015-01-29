% analyze cvpr results

EXPORT = 1;
resname = 'ELK_public_results';
resdir = 'C:\CVPR_DB_results';
datadir = 'C:\CVPR_2013_tracking_DB';
resdir = fullfile(resdir,resname);

resfile = dir(fullfile(resdir,'*.txt'));
res_idx = [2,5];
ann_idx = [1,4];
N = 21;
results.resdir = resdir;
results.N = N;
J = [];
if EXPORT
    exportfile = fullfile(resdir,['export_results_' resname '.csv']);
    fid = fopen(exportfile,'w');
end
wb = waitbar(0,'Analyzing results ...');
for ii = 1:length(resfile)
%     if strcmp(resfile(ii).name,'David.txt')
%         continue;
%     end
    j = measure_jaccard_for_seq(fullfile(resdir,resfile(ii).name),res_idx,...
        fullfile(datadir,resfile(ii).name(1:end-4),'groundtruth_rect.txt'),ann_idx);
    [AUC,th,acc] = comp_jaccard_AUC(j,N,0);
    J = cat(1,J,j);
    results.accuracy(:,ii) = acc;
    results.AUC(ii) = AUC;
    results.seqnames{ii} = resfile(ii).name(1:end-4);
    results.jaccard{ii} = j;
    fprintf('%20s %.3f\n',resfile(ii).name(1:end-4),AUC);
    
    if EXPORT        
        fprintf(fid,'%20s,%.3f\n',resfile(ii).name(1:end-4),AUC);
    end  
    waitbar(ii/length(resfile) ,wb);
end


%[AUC,th,acc] = comp_jaccard_AUC(J,N,0,resdir);

results.accuracy(:,end+1) = mean(results.accuracy,2);
results.AUC(end+1) = mean(results.accuracy(:,end));
results.seqnames{end+1} = 'overall';

save(fullfile(resdir,['analyzed_results_' resname '.mat']),'results');
fprintf('%20s %.3f\n','overall',results.AUC(end));
if EXPORT    
    fprintf(fid,'%20s,%.3f\n','overall',results.AUC(end));
    fclose(fid);
end
delete(wb);
