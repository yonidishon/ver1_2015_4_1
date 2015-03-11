% clear all;
clear global;
if (~exist('VL_SLIC.m','file'))
    oldFolder = cd('vlfeat-0.9.14\toolbox\');
    vl_setup();
    cd(oldFolder);
end

close all;
% global totTime;
% totTime=0;
% STATFILE = 'runTimeStatisticsWindows.mat';
% OUT_DIR= 'D:\Output\OURS/dump';
OUT_DIR = './';
% OUT_DIR= './OUT/';
% IN_DIR = 'Z:\Documents\Dropbox\Study\Doctorate\Publications\Saliency\images\test\test.jpg';
% IN_DIR = '4_129_129095.jpg';
% IN_DIR = './Descriptor/clutter.jpg';
% IN_DIR = 'H:\Study\Thesis\Input\HouDataSet\images\';
% IN_DIR = 'Z:\Documents\Dropbox\Study\Doctorate\Publications\Saliency\images\Struct\fork.png';
IN_DIR = 'Ucolor.png';
% IN_DIR = 'H:\Study\Thesis\Input\AchantaDataSet\images\';
% IN_DIR = 'H:\Study\Thesis\Input\ImageB\';
% IN_DIR = 'H:\Study\Thesis\Input\AchantaDataSet\images\';
% IN_DIR = '21.jpg';
% IN_DIR = '/Users/ranm/Documents/ComparisonData/Input/AchantaDataSet/images/0_0_77.jpg';

% IN_DIR = 'H:\Study\Thesis\Input\WeizmannDataSet\images\horse001.jpg';
STATFILE = [];
% 882s
calcSaliency(IN_DIR,OUT_DIR,STATFILE,1);

fprintf('Done\n');
% load(STATFILE);
% fprintf('Current average run time: %f per VGA Image (640x480)  based on %i images\n',640*480*averageTime,numOfImages);