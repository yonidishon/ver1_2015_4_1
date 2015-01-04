% Working on bee in DIEM
% constructing Saliency_PCA and Motion_PCA
%%% params
addpath(genpath('OpticalFlow'));
alpha = 0.012;
ratio = 0.75;
minWidth = 20;
nOuterFPIterations = 7;
nInnerFPIterations = 1;
nSORIterations = 30;
para = [alpha,ratio,minWidth,nOuterFPIterations,nInnerFPIterations,nSORIterations];
%%% end params

addpath(genpath('.'));
vpath='\\CGM41\Users\gleifman\Documents\DimaCode\DIEM\video\advert_bbc4_bees_1024x576.mp4';
vr=VideoReader(vpath);
vw=VideoWriter('OF_bees_movie.mp4','MPEG-4');
open(vw);
for ii=1:vr.NumberOfFrames
    result = PCA_Saliency(read(vr,ii));
    tmp=ones(size(result));
    tmp(result<0.7)=0;
    STAT=regionprops(tmp,'BoundingBox');
    %imshow(tmp);
    rectangle('position',STAT.BoundingBox,'EdgeColor','y');
    [vx,vy,~] = Coarse2FineTwoFrames(read(vr,ii),read(vr,ii-1),para);
    clear flow;
    flow(:,:,1) = vx;
    flow(:,:,2) = vy;
    imflow = flowToColor(flow);
    writeVideo(vw,imflow);
    
end