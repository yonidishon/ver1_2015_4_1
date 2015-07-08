%Prepare Data
%distributed_main_collect_data
%Training
gaze_ensamble_learner;
% Wait for Ayellet computer to finish writing the full tree
if strcmp(getComputerName(),'cgm-ayellet-1');
    buildfulltree;
    sync_file='\\cgm10\Users\ydishon\Documents\Video_Saliency\lockfiles\2015_06_30_sync\sync_file.mat';
    dummy=0;
    save(sync_file,'dummy');
else
    sync_file='\\cgm10\Users\ydishon\Documents\Video_Saliency\lockfiles\2015_06_30_sync\sync_file.mat';
    while(~exist(sync_file,'file'))
        pause(30);
    end
end
%Estimation
distributed_main_predict_hough;