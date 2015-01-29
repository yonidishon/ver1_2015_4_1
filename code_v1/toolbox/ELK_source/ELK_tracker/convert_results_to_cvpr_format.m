% convert_results_to_cvpr_format
clear;clc;
resdir = 'C:\Users\Shaul Oron\Dropbox\PhD projects\ELK_2014\results\v25_final_exp2';
datadir = 'C:\Users\Shaul Oron\Documents\PhD_Projects\CVPR_2013_tracking_DB\all';
outdir = 'C:\Users\Shaul Oron\Dropbox\PhD projects\ELK_2014\CVPR2013_benchmark\tracker_benchmark_v1.0\results\results_TRE_CVPR13';

resfiles = dir(fullfile(resdir,'*.txt'));

for f = 1:length(resfiles)
    % load results and annotations
    res = load(fullfile(resdir,resfiles(f).name));
    ann = load(fullfile(datadir,resfiles(f).name(1:end-4),'groundtruth_rect.txt'));
    % adjust size
    if size(res,1)>size(ann,1)
        res = res(1:size(ann,1),:);
    elseif size(res,1)<size(ann,1)
        res(size(res,1)+1:size(ann,1),:) = 0;
    end
    % create result struct
    switch lower(resfiles(f).name(1:end-4))
        case 'david'
            results{1}.res = res(:,2:5);
            results{1}.anno = ann;
            results{1}.len = size(ann,1);
            results{1}.annoBegin = 300;
            results{1}.startFrame = 300;
        case 'tiger1'
            results{1}.res = res(6:end,2:5);
            results{1}.anno = ann(6:end,:);
            results{1}.len = 349;
            results{1}.annoBegin = 1;
            results{1}.startFrame = 6;
        otherwise
            results{1}.res = res(:,2:5);
            results{1}.anno = ann;
            results{1}.len = size(ann,1);            
            results{1}.annoBegin = 1;
            results{1}.startFrame = 1;
    end
    results{1}.fps = 0;
    results{1}.type = 'rect';
    % save to file
    save(fullfile(outdir,[resfiles(f).name(1:end-4) '_ELK.mat']),'results');
    
end
