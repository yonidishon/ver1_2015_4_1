function [sDiffMap sAllMap out C A PP] = testDiff(I_RGB,I_RGBsmall)
global patchTotal
% I_RGB=I_RGBsmall;
patchTotal = patchTotal+1;
I_LAB = single(rgb2lab((I_RGB)));
I_LABsmall = single(rgb2lab((I_RGBsmall)));
imSize = size(I_LAB);
imSize(3)=[];
imSizesmall = size(I_LABsmall);
imSizesmall(3)=[];
% SEGMENTS = vl_slic(I_LAB, 16, 300,'MinRegionSize',16);
SEGMENTS = vl_slic(I_LAB, 16, 300,'MinRegionSize',16);
[~, ~, n] = unique(SEGMENTS); %Ensure no missing index
SEGMENTS = reshape(n,size(SEGMENTS)); %Ensure no missing index
numOfSegments = max(SEGMENTS(:));
STATS2 = regionprops(SEGMENTS,I_LAB(:,:,1).^2,'MeanIntensity','Centroid');
LEdges = linspace(0,100,16);
[L_SPM ] = segAvg(SEGMENTS,I_LAB(:,:,1),LEdges);
[sErrorL pD out C A PP] = structDifference(I_LAB(:,:,1)-mean2(I_LAB(:,:,1)),I_LABsmall(:,:,1)-mean2(I_LABsmall(:,:,1)),L_SPM,STATS2,SEGMENTS,numOfSegments,imSize,imSizesmall);
sErrorL = discardEdges(stableNormalize(sErrorL));
sErrorA = discardEdges(stableNormalize(pD));

reconError = sErrorL;
rErrorMap=min(reconError(:)) .* ones(imSize);
rErrorMap(5:(end-4),5:(end-4))=reconError(5:(end-4),5:(end-4));
sDiffMap = rErrorMap;
sDiffMap = sDiffMap- min(sDiffMap(:));
sDiffMap = sDiffMap./max(sDiffMap(:));


rErrorMap=min(sErrorA(:)) .* ones(imSizesmall);
rErrorMap(5:(end-4),5:(end-4))=sErrorA(5:(end-4),5:(end-4));
sAllMap = rErrorMap;
sAllMap = sAllMap - min(sAllMap(:));
sAllMap = sAllMap./max(sAllMap(:));



end

function [avg] = segAvg(SEGMENTS,map,hEdges)
STATS = regionprops(SEGMENTS,map,'MeanIntensity','PixelValues');
avg = [STATS.MeanIntensity];
% h = zeros(numel(avg),16);
% 
% for indx=1:numel(avg)
%     h(indx,:) = histc(STATS(indx).PixelValues,hEdges);
% end
% h = h./repmat(sum(h,2),[1 size(h,2)]);
end


function [sError pD out C A pVecL] = structDifference(L,Lsmall,L_SPM,STATS2,SEGMENTS,numOfSegments,imSize,imSizesmall)
global patchTime;
sPixelVar=[STATS2.MeanIntensity]-(L_SPM).^2; %Calc variance
[~,IX] = sort(sPixelVar,'descend');
% IX = (IX(1:round(numOfSegments/4)));
SOI = ismember(SEGMENTS, IX);
clear SEGMENTS;
IX = (find(SOI));
pVecL = im2col(padarray(L,[4 4],'replicate'),[9 9],'sliding')';
% pVecL = im2col(padarray(L,[8 8],'replicate'),[17 17],'sliding')';
pVecLsmall = im2col(padarray(Lsmall,[4 4],'replicate'),[9 9],'sliding')';

% pVecLsmall = im2col(padarray(Lsmall,[8 8],'replicate'),[17 17],'sliding')';
Lmsmall = repmat(mean(pVecLsmall,2),[1 size(pVecLsmall,2)]);

Lm = repmat(mean(pVecL,2),[1 size(pVecL,2)]);

% k=round(size(Lmsmall,1)/10);
Q = ((pVecLsmall-Lmsmall)');
params.algorithm = 'kdtree';
params.trees = 8;
params.checks = 64;
k=64;
tic
% perform the nearest-neighbor search
% [~, dists] = flann_search(Q,Q,64,params);

% [nnidx, dists] = annquery(Q,Q, 64);
% pD =reshape( sum(dists,1),imSizesmall);

% [IDX,D] = knnsearch(pVecLsmall-Lmsmall,pVecLsmall-Lmsmall,'K',k);
% pD =reshape( sum(D,2),imSizesmall);
pD =ones(imSizesmall);
tt=toc;
patchTime = patchTime+tt;
fprintf('\nPatch -- > %d',tt);
[sError out C A] =  projNrectmp(pVecL-Lm,IX,imSize);
pVecL = pVecL-Lm;
end