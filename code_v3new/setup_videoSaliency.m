% setup_videoSaliency.m 08/07/2015
%% directories
global dropbox;
global gdrive;
dropbox = 'C:\Users\ydishon\Documents\MATLAB\Video_Saliency\Dimarudoy_saliency\Dropbox';
gdrive = 'C:\Users\ydishon\Documents\MATLAB\Video_Saliency\Dimarudoy_saliency\GDrive';
DataRoot = '\\CGM10\D\DIEM';
cacheRoot = '\\CGM10\D\Video_Saliency_cache_Backup';

%---------------change these lines when moving to other versions----------%
proj_dir= 'C:\Users\ydishon\Documents\MATLAB\Video_Saliency\code_v3new';
saliency_dir='C:\Users\ydishon\Documents\MATLAB\Video_Saliency';

% Finish up cache files on host and collect results in CGM10 
lockfiles_folder=['\\cgm10\Users\ydishon\Documents\Video_Saliency\lockfiles',GENERALPARAMS.lockfile_prefix];
if ~exist(lockfiles_folder,'dir');
    mkdir(lockfiles_folder);
end
%-------------------------------------------------------------------------%
addpath(proj_dir);

%% path
% external code for Judd's method
% addpath(genpath('C:\Users\dmitryr\Dropbox\Research\Dima Adobe - Code - License\MATLAB\code_judd\'));

%% basic toolboxes
addpath(genpath(fullfile(gdrive, 'Software', 'dollar_261')));

%% toolboxes
addpath(genpath(fullfile(proj_dir,'toolbox','PCA_Saliency'))); % PCA saliency
addpath(fullfile(gdrive, 'Software', 'OpticalFlow')); % optical flow
addpath(fullfile(gdrive, 'Software', 'OpticalFlow\mex'));
addpath(genpath(fullfile(proj_dir,'toolbox', 'NMS_BB')));% Non-Maximal Suppression Bounding Boxes
addpath(genpath(fullfile(gdrive, 'Software', 'Tracking', 'LOT', 'LOT_Source', 'Source'))); % LOT tracking
addpath(genpath(fullfile(gdrive, 'Software', 'Saliency', 'gbvs'))); % GBVS saliency
addpath(genpath(fullfile(dropbox, 'Software', 'poselets', 'code'))); % poselets
addpath(genpath(fullfile(dropbox, 'toolbox', 'SVM-KM'))); % SVM-KM toolbox
addpath(fullfile(gdrive, 'Software', 'gmmtbx')); % GMM toolbox
addpath(fullfile(gdrive, 'Software', 'MeanShift')); % mean shift
addpath(fullfile(gdrive, 'Software', 'FitFunc')); % Gaussian fitting
addpath(fullfile(gdrive, 'Software', 'misc')); % different small codes

% Adobe code
addpath(fullfile(dropbox, 'Research', 'Dima Adobe - Code - License', 'MATLAB'));

%% other saliency
addpath(genpath(fullfile(gdrive, 'Software', 'Saliency', 'qtfm'))); % Quaternion
addpath(fullfile(dropbox, 'Matlab', 'video_attention', 'compare', 'PQFT_2')); % PQFT
addpath(fullfile(dropbox, 'Matlab', 'video_attention', 'compare', 'BorjiMetrics')); % measures
addpath(genpath(fullfile(gdrive, 'Software', 'Saliency', 'Hou2008'))); % Hou, 2008

%% research code
addpath(fullfile(dropbox, 'Matlab'));
addpath(fullfile(dropbox, 'Matlab', 'video_attention'));
addpath(fullfile(dropbox, 'Matlab', 'video_attention', 'CRCNS'));
addpath(fullfile(dropbox, 'Matlab', 'video_attention', 'xml'));
