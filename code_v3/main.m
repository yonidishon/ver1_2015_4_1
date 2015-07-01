%Prepare Data
%distributed_main_collect_data
%Training
gaze_ensamble_learner;
% Wait for Ayellet computer to finish writing the full tree
sync_file='\\cgm10\Users\ydishon\Documents\Video_Saliency\lockfiles\2015_06_30_sync\sync_file.mat';
if strcmp(getComputerName(),'cgm-ayellet-1');
    buildfulltree;
    dummy=0;
    save(sync_file,'dummy');
else
    while(~exist(sync_file,'file'))
        pause(30);
    end
end
%Estimation
distributed_main_predict_hough;