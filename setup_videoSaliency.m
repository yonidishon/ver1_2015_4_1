% setup_videoSaliency.m 28/12/2014
%% directories
global dropbox;
global gdrive;
dropbox = 'C:\Users\ydishon\Documents\MATLAB\Video_Saliency\Dimarudoy_saliency\Dropbox';
gdrive = 'C:\Users\ydishon\Documents\MATLAB\Video_Saliency\Dimarudoy_saliency\GDrive';
% dataRoot = 'C:\Users\dmitryr\Documents\Dima Adobe\mturk\results';
% frameRoot = 'C:\Users\dmitryr\Documents\Dima Adobe\DIEM\frames';
% saveRoot = 'C:\Users\dmitryr\Documents\Dima Adobe\mturk\save';
diemDataRoot = '\\CGM41\Users\gleifman\Documents\DimaCode\DIEM';%'Z:\RGB-D\DimaCode\DIEM'; % TODO current on external drive
saveRoot = 'C:\Users\ydishon\Documents\MATLAB\Video_Saliency\Results_v0';
%depthDataRoot = 'C:\Users\gleifman\My Documents\DimaCode\DepthDB';%'Z:\RGB-D\DimaCode\DIEM'; % TODO current on external drive
%crcnsRoot = 'C:\Users\Dmitry\Documents\Phd\Datasets\CRCNS-eye\CRCNS-DataShare';  % TODO current on external drive
% youtubeRoot = 'C:\Users\dmitryr\Documents\Dima Adobe\YouTube';
% diemRoot = 'C:\Users\dmitryr\Documents\Dima Adobe\DIEM\';

%crcnsOrigRoot = fullfile(crcnsRoot, 'Dima_ORIG');
%crcnsMtvRoot = fullfile(crcnsRoot, 'Dima_MTV');

%---------------change these lines when moving to other versions----------%
proj_dir='C:\Users\ydishon\Documents\MATLAB\Video_Saliency\code_v0';
saliency_dir='C:\Users\ydishon\Documents\MATLAB\Video_Saliency';
result_dir = 'C:\Users\ydishon\Documents\MATLAB\Video_Saliency\Results_v0\cache';

% Finish up cache files on host and collect results in CGM10 
lockfiles_folder='Y:\Users\ydishon\Documents\Video_Saliency\lockfiles\2015_01_12';
%lockfiles_folder='Y:\Users\ydishon\Documents\Video_Saliency\lockfiles\2015_01_11';
%lockfiles_folder='Y:\Users\ydishon\Documents\Video_Saliency\lockfiles\2015_01_9'; % Y:\ is CGM10
%lockfiles_folder='Y:\Users\ydishon\Documents\Video_Saliency\lockfiles\2015_01_08_4'; % Y:\ is CGM10
%lockfiles_folder='Y:\Users\ydishon\Documents\Video_Saliency\lockfiles\2015_01_08_3'; % Y:\ is CGM10
%lockfiles_folder='Y:\Users\ydishon\Documents\Video_Saliency\lockfiles\2015_01_08_2'; % Y:\ is CGM10
%lockfiles_folder='Y:\Users\ydishon\Documents\Video_Saliency\lockfiles\2015_01_04'; % Y:\ is CGM10
%lockfiles_folder='Y:\Users\ydishon\Documents\Video_Saliency\lockfiles\2014_12_31'; % Y:\ is CGM10
%-------------------------------------------------------------------------%

% Local Folders creation
if ~exist(proj_dir,'dir')
    mkdir(proj_dir);
end
if ~exist(result_dir,'dir')
    mkdir(result_dir);
end
if ~exist(saveRoot,'dir')
    mkdir(saveRoot);
end

addpath(proj_dir);

%% path
% external code for Judd's method
% addpath(genpath('C:\Users\dmitryr\Dropbox\Research\Dima Adobe - Code - License\MATLAB\code_judd\'));

%% basic toolboxes
addpath(genpath(fullfile(gdrive, 'Software', 'dollar_261')));

%% toolboxes
addpath(genpath(fullfile(proj_dir,'toolbox', 'objectness'))); % objectness
addpath(genpath(fullfile(proj_dir,'toolbox','PCA_Saliency'))); % PCA saliency
addpath(fullfile(gdrive, 'Software', 'OpticalFlow')); % optical flow
addpath(fullfile(gdrive, 'Software', 'OpticalFlow\mex'));
% addpath(fullfile(gdrive, 'Software', 'randomforest-matlab', 'RF_Class_C')); % random forests
% addpath(fullfile(gdrive, 'Software', 'randomforest-matlab', 'RF_Reg_C'));
% addpath('C:\Users\dmitryr\Dropbox\Research\Dima Adobe - Code - License\MATLAB\toolbox\');
% addpath('C:\Users\dmitryr\Dropbox\Research\Dima Adobe - Code - License\MATLAB\toolbox\kmeans');
% addpath('C:\Users\dmitryr\Dropbox\Research\Dima Adobe - Code - License\MATLAB\toolbox\kstest_2s_2d');
% % addpath('C:\Users\dmitryr\Dropbox\Research\Dima Adobe - Code - License\MATLAB\toolbox\GMM-GMR-v2.0');
% addpath('C:\Users\dmitryr\Dropbox\Research\Dima Adobe - Code - License\MATLAB\toolbox\kde2d');
% addpath('C:\Users\dmitryr\Dropbox\Research\Dima Adobe - Code - License\MATLAB\toolbox\gnumex');
% addpath('C:\Users\dmitryr\Dropbox\Research\Dima Adobe - Code - License\MATLAB\toolbox\kde');
% addpath('C:\Users\dmitryr\Dropbox\Research\Dima Adobe - Code - License\MATLAB\toolbox\SpaceTimeSaliencyDetection');
% addpath('C:\Users\dmitryr\Dropbox\Research\Dima Adobe - Code - License\MATLAB\toolbox\spectral_saliency');
% addpath('C:\Users\dmitryr\Dropbox\Research\Dima Adobe - Code - License\MATLAB\toolbox\FastEMD');
% addpath('C:\Users\dmitryr\Dropbox\Research\Dima Adobe - Code - License\MATLAB\toolbox\skindetector');


% addpath(fullfile(gdrive, 'Software', 'Tracking', 'L1Track', 'L1_Tracking_v4_release')); % L1 tracking
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
% addpath('C:\Users\dmitryr\Dropbox\Research\Dima Adobe - Code - License\MATLAB\xml');
% addpath('C:\Users\dmitryr\Dropbox\Research\Dima Adobe - Code - License\MATLAB\youtube');

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

%%% NA RGBD saliency code code
% addpath(fullfile(dropbox, 'Software', 'RGBD salient object detection'));
% addpath(fullfile(dropbox, 'Software', 'RGBD salient object detection\dependencies'));
