% clear all;
close all;
STATFILE = 'runTimeStatisticsWindows.mat';
% OUT_DIR= './Retrieve/im/sal';
% OUT_DIR= 'H:\Study\Thesis\Input\OurResults\CVPR2012\Judd';

if (ismac)
    OUT_DIR= '../../out/New/'; %mac
    STATFILE = 'runTimeStatistics.mat';
end


% IN_DIR = './Retrieve/im/dog.jpg';
% IN_DIR = 'H:\Study\Thesis\Input\JuddDataSet\images';
IN_DIR='/Users/ranm/Documents/ComparisonData/Input/AchantaDataSet/images/0_0_272.jpg';

STATFILE = [];
calcSaliency(IN_DIR,OUT_DIR,STATFILE);

fprintf('Done\n');
load(STATFILE);
fprintf('Current average run time: %f per VGA Image (640x480)  based on %i images\n',640*480*averageTime,numOfImages);

%%
% I_RGB = im2double(imread(IN_DIR));
% 
% patch = I_RGB(:,:,1);
% imSize = size(I_RGB(:,:,1));
% patch = patch(:);
% % %for paper
%      [~,row] = sort(rand(size(patch,1),size(patch,2)));
%         jumbledPatch=zeros(size(patch));
%         col=repmat(1:size(patch,2),[size(jumbledPatch,1) 1]);
%         pIndex = sub2ind(size(patch),row,col);
%         jumbledPatchR(pIndex)=I_RGB(:,:,1);
%         jumbledPatchG(pIndex)=I_RGB(:,:,2);
%         jumbledPatchB(pIndex)=I_RGB(:,:,3);
%       
%         jumbledPatch = cat(3,reshape(jumbledPatchR,imSize),reshape(jumbledPatchG,imSize),reshape(jumbledPatchB,imSize));
%         sEnergy = sum(abs(jumbledPatch-I_RGB),3);
% figure;imshow(jumbledPatch)
% % figure;imagesc(sEnergy);axis image;colormap(hot);
% imwrite(jumbledPatch, ['B:/Study/Dropbox/Study/Thesis/talk/3/' 'jPatch.png'],'png');
% imwrite(sEnergy, ['B:/Study/Dropbox/Study/Thesis/talk/3/' 'sDiff.png'],'jpg');