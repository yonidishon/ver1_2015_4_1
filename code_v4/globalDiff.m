function [sDiffMap cDiffMap] = globalDiff(I_RGB,Glvl)


if (Glvl)
    I_LAB = single(I_RGB); %only gray
else
    I_LAB = single(rgb2lab(I_RGB));
end

imSize = size(I_LAB);
imSize=imSize(1:2);
SEGMENTS = vl_slic(I_LAB, 16, 300,'MinRegionSize',16);
% figure;imagesc(SEGMENTS);colormap(rand(max(SEGMENTS(:)),3));axis image;
[~, ~, n] = unique(SEGMENTS); %Ensure no missing index
SEGMENTS = reshape(n,size(SEGMENTS)); %Ensure no missing index
numOfSegments = max(SEGMENTS(:));
STATS2 = regionprops(SEGMENTS,I_LAB(:,:,1).^2,'MeanIntensity','Centroid');
[L_SPM ] = segAvg(SEGMENTS,I_LAB(:,:,1));
if (~Glvl)
[A_SPM ] = segAvg(SEGMENTS,I_LAB(:,:,2));
A_SPM = A_SPM';
[B_SPM ] = segAvg(SEGMENTS,I_LAB(:,:,3));
B_SPM = B_SPM';
% Hvec = [L_H A_H B_H];
spm = [L_SPM' A_SPM B_SPM];
STATSA = regionprops(SEGMENTS,I_LAB(:,:,2).^2,'MeanIntensity');
STATSB = regionprops(SEGMENTS,I_LAB(:,:,3).^2,'MeanIntensity');
sErrorA = discardEdges(stableNormalize(structDifference(I_LAB(:,:,2)-mean2(I_LAB(:,:,2)),A_SPM',STATSA,SEGMENTS,numOfSegments,imSize)));
sErrorB = discardEdges(stableNormalize(structDifference(I_LAB(:,:,3)-mean2(I_LAB(:,:,3)),B_SPM',STATSB,SEGMENTS,numOfSegments,imSize)));
clear STATSA STATSB;
else
    spm = L_SPM';
    sErrorA = 0;
    sErrorB = 0;
end
sErrorL = discardEdges(stableNormalize(structDifference(I_LAB(:,:,1)-mean2(I_LAB(:,:,1)),L_SPM,STATS2,SEGMENTS,numOfSegments,imSize)));


reconError = sErrorL+sErrorA+sErrorB;
rErrorMap=min(reconError(:)) .* ones(imSize);
rErrorMap(5:(end-4),5:(end-4))=reconError(5:(end-4),5:(end-4));
% rErrorMap(9:(end-8),9:(end-8))=reconError(9:(end-8),9:(end-8));

sDiffMap = rErrorMap;

dd = squareform(pdist(spm));
T = mean(abs(dd));
[cDiffMap] = deal(zeros(imSize));
for seg=1:numOfSegments
    cDiffMap(ismember(SEGMENTS,seg)) = T(seg);
end




end

function [avg] = segAvg(SEGMENTS,map)
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
% pVecL = im2col(padarray(L,[4 4],'replicate'),[9 9],'sliding')';
pVecL = im2colstep(padarray(double(L),[4 4],'replicate'),[9 9])';
Lm = repmat(mean(pVecL,2),[1 size(pVecL,2)]);
sError =  (projNrec(pVecL-Lm,IX,imSize));

end