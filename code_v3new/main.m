%Set general run params and tree parameters (only if need to train tree
DATEANDTIME=clock; % getting the current time [yr,mnt,day,h,m,sec]
DATESTR=sprintf('%d_%d_%d',DATEANDTIME(1:3)); % get date yr_mnt_day

GENERALPARAMS.PatchSz = 7; % 5/3/1
GENERALPARAMS.GT = 'cluster'; % 'NN'
GENERALPARAMS.features = ; % TODOYD
GENERALPARAMS.full_tree_ver = '';%TODOYD
GENERALPARAMS.lockfile_prefix =DATESTR;

TREEPARAMS.numtrees = 10;
TREEPARAMS.fraction = 1/5;
TREEPARAMS.samples_per_frame = 100;
TREEPARAMS.numframe2skip = 5;
%20 videos used by Borji from the list.txt of DIEM:
% [6,8,10,11,12,14,15,16,34,42,44,48,53,54,55,59,70,74,83,84];
TREEPARAMS.trainset = [6,14,54]; 
TREEPARAMS.testset = [8,10,11,12,15,16,34,42,44,48,53,55,59,70,74,83,84];
TREEPARAMS.rand = 1;
TREEPARAMS.HIGHTH = 0.7;
TREEPARAMS.LOWTH = 0.4;

% data storage configuration
CollectDataDst = '\\CGM10\D\Video_Saliency_features_for_learner_patches_cluster\';

%Prepare Data for tree
%collect_data
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