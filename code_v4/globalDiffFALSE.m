function [sDiffMap cDiffMap] = globalDiffFALSE(I_RGB)
I_LAB = single(rgb2lab(I_RGB));
imSize = size(I_LAB);
imSize(3)=[];
SEGMENTS = vl_slic(I_LAB, 16, 300,'MinRegionSize',16);



[~, ~, n] = unique(SEGMENTS); %Ensure no missing index
SEGMENTS = reshape(n,size(SEGMENTS)); %Ensure no missing index
numOfSegments = max(SEGMENTS(:));
STATS2 = regionprops(SEGMENTS,I_LAB(:,:,1).^2,'MeanIntensity','Centroid');
LEdges = linspace(0,100,16);
[L_SPM ] = segAvg(SEGMENTS,I_LAB(:,:,1),LEdges);
CEdges = linspace(-128,127,16);
[A_SPM ] = segAvg(SEGMENTS,I_LAB(:,:,2),CEdges);
A_SPM = A_SPM';
[B_SPM ] = segAvg(SEGMENTS,I_LAB(:,:,3),CEdges);
B_SPM = B_SPM';
% Hvec = [L_H A_H B_H];
spm = [L_SPM' A_SPM B_SPM];
% figure;scatter3(L_SPM, A_SPM, B_SPM);
% Cntr = reshape([STATS2.Centroid],2,[])';
% clear A_SPM B_SPM;
sErrorL = discardEdges(stableNormalize(structDifference(I_LAB(:,:,1)-mean2(I_LAB(:,:,1)),L_SPM,STATS2,SEGMENTS,numOfSegments,imSize)));
STATS = regionprops(SEGMENTS,I_LAB(:,:,2).^2,'MeanIntensity');
sErrorA = discardEdges(stableNormalize(structDifference(I_LAB(:,:,2)-mean2(I_LAB(:,:,2)),A_SPM',STATS,SEGMENTS,numOfSegments,imSize)));
STATS = regionprops(SEGMENTS,I_LAB(:,:,3).^2,'MeanIntensity');
sErrorB = discardEdges(stableNormalize(structDifference(I_LAB(:,:,3)-mean2(I_LAB(:,:,3)),B_SPM',STATS,SEGMENTS,numOfSegments,imSize)));
clear STATS;

sError = sErrorL+sErrorA+sErrorB;

reconError = sError;
rErrorMap=min(reconError(:)) .* ones(imSize);
rErrorMap(5:(end-4),5:(end-4))=reconError(5:(end-4),5:(end-4));
sDiffMap = rErrorMap;

dd = squareform(pdist(spm));
% 
% ddC = squareform(pdist(Hvec,@quadDist));
% tic
% ddC2 = squareform(pdist(Hvec,@EMDDist));
% toc
% 
% LCntr = [0.5*(LEdges(1:end-1)+LEdges(2:end)) LEdges(end)]';
% CCntr = [0.5*(CEdges(1:end-1)+CEdges(2:end)) CEdges(end)]';
% Lc = squareform(pdist(LCntr));
% Lc = 100-Lc;
% Lc = Lc./repmat(sum(Lc),size(Lc,1),1);
% Cc = squareform(pdist(CCntr));
% Cc = 255-Cc;
% Cc = Cc./repmat(sum(Cc),size(Cc,1),1);
% save('simMat.mat','Lc','Cc');


% cd = squareform(pdist(Cntr));

T = mean(abs(dd));
% T = stableNormalize(mean(abs(ddC))).*stableNormalize(mean(abs(dd)));
% T = mean(abs(ddC)./(1+abs(cd)));
[cDiffMap] = deal(zeros(imSize));
% STATS = regionprops(SEGMENTS,sError,'MeanIntensity');
for seg=1:numOfSegments
cDiffMap(ismember(SEGMENTS,seg)) = T(seg);
% reconError(ismember(SEGMENTS,seg)) = STATS(seg).MeanIntensity;
end
% figure;imagesc(cDiffMap);axis image




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


function sError = structDifference(L,L_SPM,STATS2,SEGMENTS,numOfSegments,imSize)
sPixelVar=[STATS2.MeanIntensity]-(L_SPM).^2; %Calc variance
[~,IX] = sort(sPixelVar,'descend');
IX = (IX(1:round(numOfSegments/4)));
SOI = ismember(SEGMENTS, IX);
clear SEGMENTS;
IX = (find(SOI));
pVecL = im2col(padarray(L,[4 4],'replicate'),[9 9],'sliding')';
Lm = repmat(mean(pVecL,2),[1 size(pVecL,2)]);
sError =  projNrecFALSE(pVecL-Lm,IX,imSize);
end