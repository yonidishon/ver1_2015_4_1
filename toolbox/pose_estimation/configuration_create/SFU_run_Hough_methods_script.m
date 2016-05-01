% Run detection MRF on some of detections and Eval scores on SFU

% Methods to be run (04/03/2016):
% Predictions:
% PCAmPCAsonlyCONF0_8, PCAmPCAsonlyCONF0_8_MRF, HOUGH_P_MRF
% Evalations: 
% PCAm , PCAs, 
clear all;close all;clc
%% DONE - Run Detections:

% 1. Prepare config files
data_fold = '\\cgm10\D\head_pose_estimation\SFUpng';
EXP_FOLD_NM = '22_02_2016_Pcas_only_subpatches_16_0_8conf';
hosts = {'CGM-AYELLET-1','CGM7','CGM16','CGM45','CGM46','CGM47'};
addpath(genpath('C:\Users\ydishon\Documents\Video_Saliency\toolbox\pose_estimation\configuration_create'))
func_Config_txt_CreateSFU(EXP_FOLD_NM,hosts)
% 2. Go to PS and change the lines config to
EXP_FOLD_NM
% 3. Change the HoughGaze...exe to the correct one.
% 04_03_2016_Pcas_only_subpatches_0_8_confSFU
%% Something isn't right with the PScripts

% So open cmd.exe on each hosts and run this:
% \\cgm10\Users\ydishon\Documents\Video_Saliency_HeadPoseEstimation\forest\x64\Freeze\ver\04_03_2016_Pcas_only_subpatches_0_8_confSFU\HoughForestGaze.exe
% 2
% \\cgm10\D\head_pose_estimation\config_files\config_22_02_2016_Pcas_only_subpatches_16_0_8conf_SFU_CGM
% NEED TO RUN ON CGM45 as it didn't connect
%% DONE - Run MRF model on results folder and create new folder for it

cd '\\cgm10\Users\ydishon\Documents\Video_Saliency\code_v5'
run distributed_main_headposepostSFU.m
%% DONE - Run the Eval scores of How many bits

cd '\\cgm10\Users\ydishon\Downloads\howManyBitsforSaliency\SOURCE_orig'
run x_EvalScores.m
%% Run the visualization 
cd '\\cgm10\Users\ydishon\Downloads\howManyBitsforSaliency\SOURCE_orig'
run x_FigScores.m

%% DONE - Run Again the MRF model on a diviation by 1/8 of the HOUGH forest - already updated 
cd '\\cgm10\Users\ydishon\Documents\Video_Saliency\code_v5'
run distributed_main_headposepostSFU.m

%% DONE counting number of frames in CRCNS
im_fold = 'D:\head_pose_estimation\CRCNSpng';
fold = dir(im_fold);fold = fold(3:end);
fold = extractfield(fold,'name');
frcnt =0;
for ii=1:numel(fold)
 frcnt=frcnt+numel(dir(fullfile('D:\head_pose_estimation\CRCNSpng',fold{ii},'*.png')));
 fprintf('%i\n',frcnt);
end