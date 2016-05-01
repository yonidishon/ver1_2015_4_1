function []=func_Config_txt_CreateSFU(EXP_FOLD_NM,hosts)
pose_path = '\\cgm10\D\head_pose_estimation';
config_path = fullfile(pose_path,'config_files');
% Configuration Options:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
test_fnm_suf ='test';%'test_post';%'test';
resultFoldforPost ='SFUpng176x144';%'origandPCAmPCAs_15_float'; %'origandPCAmPCAs_15';
resultFoldforHard = '';
FORESTSZ = 10;%8;%15;%10
% calculation of the workload per host
PATCHSZ = 16;
FEATURES = 1; % NOT USED
SCALES = 1; %can be a vector of 1xn
RATIOS = 1; %can be a vector of 1xn
SCALE_FC_IM = 2^16-1; % scale factor for final prediction map (TODO -needs to see if it is nessecary)
POSSUBSET = -1; %Subset of positive images -1: all images
POSPERLN = 10; % Sample patches from pos. examples (each line in posexamplefile)
NEGSUBSET = -1;%Subset of negative images -1: all images
NEGPERLN = 1;% Sample patches from neg. examples (each line in negexamplefile)
HARDNEGPERFRAME = 20; % HARD NEGATIVE
phase ={'test'};
% Path to data etc.:
path_treetable = fullfile(pose_path,'trees',['trees_','22_02_2016_Pcas_only_subpatches_16_0_8conf','\']);
% path_treetable = fullfile(pose_path,'trees',['treetable_','origandPCAmPCAs_15']); % TODO!!!
path_images_from_movies = fullfile(pose_path,resultFoldforPost);
%outputpath = fullfile(pose_path,sprintf('pred_%s',EXP_FOLD_NM)); %TODO change of mining
outputpath = fullfile('\\cgm10\D\head_pose_estimation\PredictionsSFU',sprintf('pred_%s',EXP_FOLD_NM));
posexamplepath = fullfile(pose_path,'DIEMpng'); % only test so it doesn't matter really
posexamplefile = fullfile(pose_path,'Predictions',EXP_FOLD_NM,'train_pos.txt'); % TODO
negexamplepath = fullfile(pose_path,'DIEMpng'); % only test so it doesn't matter really
negexamplefile = fullfile(pose_path,'Predictions',EXP_FOLD_NM,'train_neg.txt'); % TODO
% foreach host
for ii=1:length(hosts)
    for jj=1:length(phase)
    fid=fopen(fullfile(config_path,sprintf('config_%s_%s_%s%s.txt',EXP_FOLD_NM,'SFU',hosts{ii},phase{jj})),'w');
    fprintf(fid,'# Path to trees + prefix ''treetable/''\n%s\n',path_treetable);
    if strcmp(phase{jj},'train')
        fprintf(fid,'# Number of trees\n%d\n',TREESPERHOST(ii));
    else
        fprintf(fid,'# Number of trees\n%d\n',FORESTSZ);
    end
    fprintf(fid,'# Patch width\n%d\n# Patch height\n%d\n',PATCHSZ,PATCHSZ);
    fprintf(fid,'# Path to images\n%s\n',path_images_from_movies);
    fprintf(fid,'# File with names of images\n%s\n',...
        fullfile('\\cgm10\D\head_pose_estimation\PredictionsSFU',...
        sprintf('%s_SFU%s.txt',hosts{ii},test_fnm_suf)));
    fprintf(fid,'# Extract features\n%d\n',FEATURES);
    fprintf(fid,'# Scales (Number of scales - Scales)\n%d %d\n',length(SCALES),SCALES);
    fprintf(fid,'# Ratios (Number of ratios - ratio)\n%d %d\n',length(RATIOS),RATIOS);
    fprintf(fid,'# Output path\n%s\n',outputpath);
    fprintf(fid,'# Scale factor for output image (default: 128)\n%d\n',SCALE_FC_IM);
    fprintf(fid,'# Path to positive examples\n%s\n',posexamplepath);
    fprintf(fid,'# File with postive examples\n%s\n',posexamplefile);
    fprintf(fid,'# Subset of positive images -1: all images\n%d\n',POSSUBSET);
    fprintf(fid,'# Sample patches from pos. examples\n%d\n',POSPERLN);
    fprintf(fid,'# Path to negative examples\n%s\n',negexamplepath);
    fprintf(fid,'# File with negative examples\n%s\n',negexamplefile);
    fprintf(fid,'# Subset of negative images -1: all images\n%d\n',NEGSUBSET);
    fprintf(fid,'# Sample patches from neg. examples\n%d\n',NEGPERLN);
%   fprintf(fid,'# Subset of training to do tection on\n%s%s.txt\n',train_sub,hosts{ii});%TODO HARDNEG
%     fprintf(fid,'# Maximum Hard Negatives per image\n%i\n',HARDNEGPERFRAME);%TODO HARDNEG
    fclose(fid);
    end
end
fprintf('Finished manufacturing the config_<host>.txt files\n');