clear all;
if (~exist('VL_SLIC.m','file'))
    oldFolder = cd('vlfeat-0.9.14\toolbox\');
    vl_setup();
    cd(oldFolder);
end
global pcaTime;
global patchTime;
global patchTotal;
addpath('flann-1.7.1-src\src\matlab\');

pcaTime = 0;
patchTime = 0;
patchTotal = 0;
close all;
% STATFILE = 'runTimeStatisticsWindows.mat';
OUT_DIR= 'D:\Output\newPattern\';

% OUT_DIR= '.\';
% OUT_DIR= './OUT/';
% IN_DIR = '..\Input\ImageB\images\2_74_74560.jpg';
% IN_DIR = './Descriptor/clutter.jpg';
% IN_DIR = 'H:\Study\Thesis\Input\HouDataSet\images\';
% IN_DIR = 'Z:\Documents\Dropbox\Study\Doctorate\Publications\Saliency\images\Struct\fork.png';
IN_DIR = 'H:\Study\Thesis\Input\Weizmann1\images\';
% IN_DIR = 'H:\Study\Thesis\Input\AchantaDataSet\images\';
% IN_DIR = 'H:\Study\Thesis\Input\ImageB\';
% IN_DIR = 'H:\Study\Thesis\Input\AchantaDataSet\images\';
% IN_DIR = '21.jpg';
% IN_DIR = '/Users/ranm/Documents/ComparisonData/Input/AchantaDataSet/images/0_0_77.jpg';

% IN_DIR = 'H:\Study\Thesis\Input\WeizmannDataSet\images\horse001.jpg';
STATFILE = [];
% 882s
calcDistinct(IN_DIR,OUT_DIR,STATFILE,1);

% calcDistinct(IN_DIR,OUT_DIR,STATFILE,1932);

fprintf('Done\n');
pcaT = pcaTime./patchTotal;
patchT = patchTime./patchTotal;
patchT./pcaT


return
%%

% I = repmat(rgb2gray(imread('..\Input\ImageB\images\2_77_77162.jpg')),[1 1 3]);
% figure;imshow(I)

% I = repmat(rgb2gray(imread('square.jpg')),[1 1 3]);
% I = imresize(I,1/5);

clear all;
% I = repmat(rgb2gray(imread('hotel.jpg')),[1 1 3]);
% I = repmat(rgb2gray(imread('grassNew.png')),[1 1 3]);
% I = repmat(rgb2gray(imread('..\Input\ImageB\images\0_0_147.jpg')),[1 1 3]);
% I = repmat(rgb2gray(imread('pattern.png')),[1 1 3]);
I = repmat((imread('pattern.png')),[1 1 3]);

Is= I;
% Is = imresize(I,1/2);

figure;imshow(Is);
[sDiffMap sAllMap out C A c] = testDiff(Is,Is);
A =A(1,:);
figure;imshow(sDiffMap);
figure;imshow(sAllMap);
% imwrite(sDiffMap,'patternResult.png','png')
dI = sub2ind(size(sDiffMap),120,297);
ndI = sub2ind(size(sDiffMap),135,92);
[R G B] = deal(I(:,:,1));
R(dI) = 255; G(dI) = 0; B(dI) = 0;
R(ndI) = 0; G(ndI) = 255; B(ndI) = 0;
RGB = cat(3,R,G,B);
figure;imshow(RGB)
imwrite(RGB,'marked.png','png');
c = im2col(padarray(im2double(I),[4 4],'replicate'),[9 9],'sliding')';
p1 = kron(reshape(c(dI,:),[9 9]),(ones(50)));
p2 = kron(reshape(c(ndI,:),[9 9]),(ones(50)));
pA = kron(reshape(mean(c,1),[9 9]),(ones(50)));

pD = p1-pA;
figure;imshow(pA+0.1*pD);

vv = linspace(0,1,6);
for pIdx=1:6
    p = pA+vv(pIdx)*pD;
    imwrite(p,['L2pattern' num2str(pIdx) '.png'],'png');
end

figure;imshow(p1)
% p1 = (abs(p1))/100;
% p2 = (p2)/100;
% pA = (pA)/100;
imwrite(p1,'dpattern.png','png');
imwrite(p2,'ndpattern.png','png');
imwrite(pA,'apattern.png','png');

ind = dI;
patches=zeros(9,9,6);
[b inx] = sort(abs(out(ind,:)),'descend');
for pIdx=1:26
    patches(:,:,pIdx)=reshape(C(:,inx(pIdx)).*out(ind,inx(pIdx)),[9 9]);
end
% figure
% for pIdx=1:6
%     subplot(5,4,pIdx);imagesc(abs(patches(:,:,pIdx)),[0 25]); colormap(gray); axis image;
%     title(num2str(pIdx));
% end

for pIdx=1:6
    p = kron(patches(:,:,pIdx),ones(50));
    p = abs(p)/25;
%     p = p./max(p(:));
    imwrite(p,['dpattern' num2str(pIdx) '.png'],'png');
end

%%
Ctmp = C(:,1:20);
salIdx = sub2ind(size(sDiffMap),106,134);
R = out(salIdx,:)*Ctmp;
T = Ctmp.*repmat(R,[289 1 ]);
Y = col2im(T,[17 17],[85 68 ],'distinct');
figure;imagesc(Y);axis image;colormap(gray);


nsalIdx = sub2ind(size(sDiffMap),108,167);
R = out(nsalIdx,:)*Ctmp;
T = Ctmp.*repmat(R,[289 1 ]);
Y = col2im(T,[17 17],[85 68 ],'distinct');
figure;imagesc(Y);axis image;colormap(gray);

