function [sDiffMap cDiffMap] = globalTempDiff(frames)


    F = single(im2double(frames)); %only gray
    

imSize = size(F);
imSize=imSize(1:2);
SEGMENTS = vl_slic(F(:,:,1), 16, 300,'MinRegionSize',16);
% figure;imagesc(SEGMENTS);colormap(rand(max(SEGMENTS(:)),3));axis image;
[~, ~, n] = unique(SEGMENTS); %Ensure no missing index
SEGMENTS = reshape(n,size(SEGMENTS)); %Ensure no missing index
numOfSegments = max(SEGMENTS(:));

STATS2 = regionprops(SEGMENTS,F(:,:,1).^2,'MeanIntensity','Centroid');
[L_SPM ] = segAvg(SEGMENTS,F(:,:,1));
    spm = L_SPM';
reconError = discardEdges(stableNormalize(structDifference(F,L_SPM,STATS2,SEGMENTS,numOfSegments,imSize)));

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


function sError = structDifference(F,L_SPM,STATS2,SEGMENTS,numOfSegments,imSize)
sPixelVar=[STATS2.MeanIntensity]-(L_SPM).^2; %Calc variance
[~,IX] = sort(sPixelVar,'descend');
IX = (IX(1:round(numOfSegments/4)));
SOI = ismember(SEGMENTS, IX);
clear SEGMENTS;
IX = (find(SOI));

F = F-repmat(sum(sum(F,1),2)./prod(imSize(1:2)),[imSize 1]); %Remove mean vals
% pVecL = im2col(padarray(L,[4 4],'replicate'),[9 9],'sliding')';
pVecL = im2colstep(padarray(double(F(:,:,1)),[4 4],'replicate'),[9 9])';
Lm = repmat(mean(pVecL,2),[1 size(pVecL,2)]);
pVecL = pVecL-Lm;
for ind=2:size(F,3)
    
pTmp= im2colstep(padarray(double(F(:,:,1)),[4 4],'replicate'),[9 9])';
Lm = repmat(mean(pTmp,2),[1 size(pTmp,2)]);
pTmp = pTmp-Lm;
pVecL = [pVecL pTmp];
end


sError =  (projNrec(pVecL,IX,imSize));

end