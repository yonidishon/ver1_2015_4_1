function [result resultD] = PCA_Saliency_Core(I_RGB)
% Yonatan - Modified 08/01/2015 - enforce Gaussian if image is black
resultD = globalDistinctness(I_RGB);
C = zeros(11,2);
Cw = zeros(11,1);
idx=1;
for th=1:-0.1:0.1
    bw = resultD>=th;
    STATS =regionprops(uint8(bw),'centroid','Area');
    if isempty(STATS) % no objects in the image
        % best guess is a center-bias
        C(idx,:)=round([size(resultD,2)/2 size(resultD,1)/2]);
        Cw(idx)=th;
        idx=idx+1;
        continue;
    end
    C(idx,:) = round(reshape([STATS.Centroid],2,[])');
    Cw(idx) = th;
    idx=idx+1;
end

C(11,:) = round([size(resultD,2)/2 size(resultD,1)/2]);
Cw(11) = 5;
[X Y] = meshgrid(1:size(resultD,2),1:size(resultD,1));
%W = reshape(pdf(gmdistribution(C,[10000 10000],Cw), [X(:) Y(:)]),size(resultD));
W = reshape(pdf(gmdistribution(C,[300 300],Cw), [X(:) Y(:)]),size(resultD));
W = W./max(W(:));
result = stableNormalize(resultD.*W);
if max(result(:))==0 %black image input
    result=W;
end
resultD = stableNormalize(resultD);
end

function [result] = globalDistinctness(I_RGB)

orgSize=size(I_RGB);
orgSize=orgSize(1:2);
numOfLevels=3;
stDistinc = zeros(orgSize(1),orgSize(2),numOfLevels);
clDistinc = stDistinc;
Pyramid = I_RGB;

for pInd=1:numOfLevels
    [ST CL]  = globalDiff(Pyramid);
    stDistinc(:,:,pInd) = imresize(ST,orgSize,'bicubic');
    clDistinc(:,:,pInd) = imresize(CL,orgSize,'bicubic');
    Pyramid = impyramid(Pyramid, 'reduce');
end

stDistinc(stDistinc<0)=0;
clDistinc(clDistinc<0)=0;

baseWeight= (numOfLevels:-1:1);

baseWeight=baseWeight./sum(baseWeight);
weights=repmat(permute(baseWeight,[3 1 2]),[orgSize(1) orgSize(2) 1]);
stResult = sum(weights.*stDistinc,3);
clResult = sum(weights.*clDistinc,3);
out = imfill(stResult);
result = stableNormalize(clResult.*out);
end
function [sDiffMap cDiffMap] = globalDiff(I_RGB)
I_LAB = single(rgb2lab(I_RGB));
imSize = size(I_LAB);
imSize=imSize(1:2);
SEGMENTS = vl_slic(I_LAB, 16, 300,'MinRegionSize',16);
[~, ~, n] = unique(SEGMENTS); %Ensure no missing index
SEGMENTS = reshape(n,size(SEGMENTS)); %Ensure no missing index
numOfSegments = max(SEGMENTS(:));
STATS2 = regionprops(SEGMENTS,I_LAB(:,:,1).^2,'MeanIntensity','Centroid');

[L_SPM ] = segAvg(SEGMENTS,I_LAB(:,:,1));
[A_SPM ] = segAvg(SEGMENTS,I_LAB(:,:,2));

A_SPM = A_SPM';
[B_SPM ] = segAvg(SEGMENTS,I_LAB(:,:,3));


B_SPM = B_SPM';
spm = [L_SPM' A_SPM B_SPM];
STATSA = regionprops(SEGMENTS,I_LAB(:,:,2).^2,'MeanIntensity');
STATSB = regionprops(SEGMENTS,I_LAB(:,:,3).^2,'MeanIntensity');

sErrorL = discardEdges(stableNormalize(structDifference(I_LAB(:,:,1)-mean2(I_LAB(:,:,1)),L_SPM,STATS2,SEGMENTS,numOfSegments,imSize)));
sErrorA = discardEdges(stableNormalize(structDifference(I_LAB(:,:,2)-mean2(I_LAB(:,:,2)),A_SPM',STATSA,SEGMENTS,numOfSegments,imSize)));
sErrorB = discardEdges(stableNormalize(structDifference(I_LAB(:,:,3)-mean2(I_LAB(:,:,3)),B_SPM',STATSB,SEGMENTS,numOfSegments,imSize)));

clear STATSA STATSB;
reconError = sErrorL+sErrorA+sErrorB;
rErrorMap=min(reconError(:)) .* ones(imSize);
rErrorMap(5:(end-4),5:(end-4))=reconError(5:(end-4),5:(end-4));

sDiffMap = rErrorMap;

dd = squareform(pdist(spm));
T = mean(abs(dd));
[cDiffMap] = deal(zeros(imSize));
for seg=1:numOfSegments
    cDiffMap(ismember(SEGMENTS,seg)) = T(seg);
end





end

function result = discardEdges(map)
result=min(map(:)) .* ones(size(map));
result(5:(end-4),5:(end-4))=map(5:(end-4),5:(end-4));
end
function [avg] = segAvg(SEGMENTS,map)
STATS = regionprops(SEGMENTS,map,'MeanIntensity','PixelValues');
avg = [STATS.MeanIntensity];
end


function sError = structDifference(L,L_SPM,STATS2,SEGMENTS,numOfSegments,imSize)
sPixelVar=[STATS2.MeanIntensity]-(L_SPM).^2; %Calc variance
[~,IX] = sort(sPixelVar,'descend');
IX = (IX(1:round(numOfSegments/4)));
SOI = ismember(SEGMENTS, IX);
clear SEGMENTS;
IX = (find(SOI));
if (~strcmp(mexext,'mexw64'))
    pVecL = im2col(padarray(double(L),[4 4],'replicate'),[9 9],'sliding')';
else
    pVecL = im2colstep(padarray(double(L),[4 4],'replicate'),[9 9])';
end
Lm = repmat(mean(pVecL,2),[1 size(pVecL,2)]);
sError =  (projNrec(pVecL-Lm,IX,imSize));

end




function [reconError] =  projNrec(pVec,IX,imSize)
poiVec = pVec(IX,:);
Lm = repmat(mean(poiVec,1),[size(poiVec,1) 1]);
[COEFF,jnk] = princomp(poiVec-Lm);
reconError = sum(abs((pVec*COEFF)),2);
reconError = reshape(reconError,imSize);
end
function LAB = rgb2lab(RGB)
dRGB=im2double(RGB);
C=makecform('srgb2lab');
LAB=lab2double(applycform(dRGB,C));
gfilt = fspecial('gaussian',9,4);
LAB(:,:,2) = imfilter(LAB(:,:,2),gfilt);
LAB(:,:,3) = imfilter(LAB(:,:,3),gfilt);
end


function valueMap = stableNormalize(valueMap)
    sortVMap = sort(valueMap(:),'descend');
    sortVMap(isnan(sortVMap))=[];
    if max(sortVMap) == 0 && min(sortVMap)==0
        valueMap=zeros(size(valueMap));
        return
    end
    valueMap = valueMap./mean(sortVMap(1:max(round(numel(sortVMap)*.01),1)));
    valueMap(valueMap>1)=1;
end