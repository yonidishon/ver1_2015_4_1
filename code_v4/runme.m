clear all;
clear global;
if (~exist('VL_SLIC.m','file'))
    oldFolder = cd('vlfeat-0.9.14\toolbox\');
    vl_setup();
    cd(oldFolder);
    path(path,'Optical');
    path(path,'Z:\Documents\From DropBox 2-10-12\Input\DIEM\video_attention\')
%     matlabpool(2)
end

close all;
global totTime;
totTime=0;
% STATFILE = 'runTimeStatisticsWindows.mat';
% OUT_DIR= 'D:\Output\newPattern/';

% vidName = 'cyclists';
% vidName = 'flock';
OUT_DIR= ['\\CGM10\D\Video_Saliency_Results\FinalResults2\PCA_Fusion_v2_mahalRan'];
%OUT_DIR= ['D:\Output\Diem2\'];
% IN_DIR = 'D:\Output\tmp\';
% IN_DIR = 'Z:\Documents\Dropbox\Study\Doctorate\Publications\Saliency\images\test\test.jpg';
% IN_DIR = '4_129_129095.jpg';
% IN_DIR = './Descriptor/clutter.jpg';
% IN_DIR = 'H:\Study\Thesis\Input\HouDataSet\images\';
% IN_DIR = 'Z:\Documents\Dropbox\Study\Doctorate\Publications\Saliency\images\Struct\fork.png';
% IN_DIR = 'H:\Study\Thesis\Input\Weizmann1\images\';
% IN_DIR = 'H:\Study\Thesis\Input\AchantaDataSet\images\';
% IN_DIR = 'Z:\Documents\Dropbox\Study\Doctorate\Publications\Saliency\images\resolution\0_0_147.jpg';
% IN_DIR = ['Z:\Documents\Dropbox\Study\Doctorate\Research\Input\JPEGS\' vidName '\'];


%diemDataRoot = 'Z:\Documents\From DropBox 2-10-12\Input\DIEM';
diemDataRoot='\\CGM41\Users\gleifman\Documents\DimaCode\DIEM';

% IN_DIR = '21.jpg';
% IN_DIR = '/Users/ranm/Documents/ComparisonData/Input/AchantaDataSet/images/0_0_147.jpg';


testIdx = [6,8,10,11,12,14,15,16,34,42,44,48,53,54,55,59,70,74,83,84]; % used by Borji


for ti=1:numel(testIdx)
calcVideoSaliency(diemDataRoot,OUT_DIR,testIdx(ti));
end

fprintf('Done\n');
% load(STATFILE);
% fprintf('Current average run time: %f per VGA Image (640x480)  based on %i images\n',640*480*averageTime,numOfImages);