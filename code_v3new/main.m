%Set general run params and tree parameters (only if need to train tree
DATEANDTIME=clock; % getting the current time [yr,mnt,day,h,m,sec]
DATESTR=sprintf('%d_%d_%d',DATEANDTIME(1:3)); % get date yr_mnt_day


global GENERALPARAMS TREEPARAMS; 

GENERALPARAMS.PatchSz = 7; % 7/5/3/1
GENERALPARAMS.GT = 'cluster';%'NN'
GENERALPARAMS.features = 'PCAsPCAm';
GENERALPARAMS.full_tree_ver = sprintf('P-%d_GT-%s_%s_400Sa_w_Time',...
    GENERALPARAMS.PatchSz,GENERALPARAMS.GT,GENERALPARAMS.features);
GENERALPARAMS.lockfile_prefix =DATESTR;
GENERALPARAMS.frame_pred_num = 300;
GENERALPARAMS.offset = 30;

TREEPARAMS.numtrees = 10;
TREEPARAMS.fraction = 1/5;
TREEPARAMS.samples_per_frame = 400;
TREEPARAMS.numframe2skip = 5;
%20 videos used by Borji from the list.txt of DIEM:
% [6,8,10,11,12,14,15,16,34,42,44,48,53,54,55,59,70,74,83,84];
TREEPARAMS.trainset = [6,14,54]; 
TREEPARAMS.testset = [8,10,11,12,15,16,34,42,44,48,53,55,59,70,74,83,84];
TREEPARAMS.rand = 1;
TREEPARAMS.HIGHTH = 0.7;
TREEPARAMS.LOWTH = 0.4;
hosts = {'CGM-AYELLET-1',...
         'CGM7',...
         'CGM16',...
         'CGM22',...
         'CGM38',...
         'CGM41',...
         'CGM45',...
         'CGM46',...
         'CGM47'};
setup_videoSaliency;

% data storage configuration
CollectDataDst = fullfile('\\CGM10\D\Data_codev3new',['ob_res_',GENERALPARAMS.full_tree_ver]);
TreesDst = '\\CGM10\D\Learned_Trees\code_v3new';
FinalResultRoot = ['\\CGM10\D\Video_Saliency_Results\FinalResults3new\',GENERALPARAMS.full_tree_ver,'_results'];
visRoot = fullfileCreate(FinalResultRoot,'vis');
measures = {'chisq', 'auc'}; % {'chisq', 'auc', 'cc', 'nss'};
methods = {GENERALPARAMS.full_tree_ver,'self','PCA F+P','Dima'};
methods_paths = {'\\CGM10\D\Video_Saliency_Results\FinalResults2\PCA_Fusion_v8_2'};

%Prepare Data for tree
collect_data
% sync creation of trees untill all traindata is prepared.
while(1)
    if length(dir(fullfile(lockfiles_folder,'collect_train_sync_*')))==length(TREEPARAMS.trainset);
        break;
    end
    pause(60*5);
end


%Training
if ~exist(fullfile(TreesDst,[GENERALPARAMS.full_tree_ver,getComputerName(),'.mat']),'file');
    gaze_ensamble_learner;
    fidtrainfin = fopen(fullfile(lockfiles_folder,['train_sync_',getComputerName(),'.txt']),'wt');
    fprintf(fidtrainfin,'finish training'); fclose(fidtrainfin);
end
% Wait for Ayellet computer to finish writing the full tree
if strcmp(getComputerName(),'cgm-ayellet-1') && ~exist(fullfile(TreesDst,[GENERALPARAMS.full_tree_ver,'_fulltree.mat']),'file')
    while(1)
        numhostsfinished=length(dir(fullfile(lockfiles_folder,'train_sync_*')));
        if numhostsfinished==length(hosts)
            break;
        end
        pause(60);
    end
    buildfulltree;
    sync_file=fullfile(lockfiles_folder,'sync_file.mat');
    dummy=0;
    save(sync_file,'dummy');
else
    sync_file=fullfile(lockfiles_folder,'sync_file.mat');
    while(~exist(sync_file,'file'))
        pause(30);
    end
end

%Prediction
main_predict;

%Last computer to finish send me an Email
% [mail,ss]=myGmail('fuck you');
% SendmeEmail(mail,ss,subject,massege);