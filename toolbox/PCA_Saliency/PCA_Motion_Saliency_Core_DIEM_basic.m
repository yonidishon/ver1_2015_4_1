function [result, resultD] = PCA_Motion_Saliency_Core_DIEM_basic(fx,fy,I_RGB)
% Yonatan Modified 08/01/2015 - if no motion - > fx,fy == 0 then return
%                               matrix of ones
% Yonatan Modified 19/01/2015 - return only the Gaussians
% Yonatan Modified 22/01/2015 - Thershold for rad and alpha , Strength of
%                               Prior reduced to 2 (from 5)
% Yonatan Modified 13/05/2015 - Based on PCA_Motion_Saliency_Core.m
% -> Trigger for modification is baseline vs HOWMANYBITS
% List of changes:
% 1. return Guassians with result.
% 2. No Middle prior when the information is there.
UNKNOWN_FLOW_THRESH=1e9;
idxUnknown = (abs(fx)> UNKNOWN_FLOW_THRESH) | (abs(fy)> UNKNOWN_FLOW_THRESH) ;
fx(idxUnknown) = 0;
fy(idxUnknown) = 0;
% rad = sqrt(fx.^2+fy.^2); 
% alpha = atan2(fy,fx)/pi;
% removing noise
fx(fx<0.2)=0;
fy(fy<0.2)=0;
resultD = globalDistinctness(fx,fy,I_RGB);
C = zeros(10,2);
Cw = zeros(10,1);
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

% C(11,:) = round([size(resultD,2)/2 size(resultD,1)/2]);
% Cw(11) = 5;
[X Y] = meshgrid(1:size(resultD,2),1:size(resultD,1));
%W = reshape(pdf(gmdistribution(C,[10000 10000],Cw), [X(:) Y(:)]),size(resultD));
W = reshape(pdf(gmdistribution(C,[300 300],Cw), [X(:) Y(:)]),size(resultD));
W = W./max(W(:));
result = stableNormalize(resultD.*W);
%result = stableNormalize(W);
if max(result(:))==0
%     result=ones(size(result));
    result = W;
end
resultD = stableNormalize(resultD);
end

function [result] = globalDistinctness(a,rad,I_RGB)
orgSize=size(I_RGB);
orgSize=orgSize(1:2);
numOfLevels=3;
stDistinc = zeros(orgSize(1),orgSize(2),numOfLevels);
%clDistinc = stDistinc;
Pyramid = I_RGB;

for pInd=1:numOfLevels
    ST  = globalDiff(a,rad,Pyramid);
    stDistinc(:,:,pInd) = imresize(ST,orgSize,'bicubic');
    %clDistinc(:,:,pInd) = imresize(CL,orgSize,'bicubic');
    Pyramid = impyramid(Pyramid, 'reduce');
    a = impyramid(a, 'reduce');
    rad = impyramid(rad, 'reduce');
end

stDistinc(stDistinc<0)=0;
%clDistinc(clDistinc<0)=0;

baseWeight= (numOfLevels:-1:1);

baseWeight=baseWeight./sum(baseWeight);
weights=repmat(permute(baseWeight,[3 1 2]),[orgSize(1) orgSize(2) 1]);
stResult = sum(weights.*stDistinc,3);
%clResult = sum(weights.*clDistinc,3);
out = imfill(stResult);
%result = stableNormalize(clResult.*out);
result = stableNormalize(out);
end
function [sDiffMap] = globalDiff(a,rad,I_RGB)
I_LAB = single(rgb2lab(I_RGB));
imSize = size(I_LAB);
imSize=imSize(1:2);
SEGMENTS = vl_slic(I_LAB, 16, 300,'MinRegionSize',16);
[~, ~, n] = unique(SEGMENTS); %Ensure no missing index
SEGMENTS = reshape(n,size(SEGMENTS)); %Ensure no missing index
numOfSegments = max(SEGMENTS(:));
STATS2 = regionprops(SEGMENTS,I_LAB(:,:,1).^2,'MeanIntensity','Centroid');

[L_SPM ] = segAvg(SEGMENTS,I_LAB(:,:,1));

[sErrorL]=structDifference(a,rad,L_SPM,STATS2,SEGMENTS,numOfSegments,imSize);
sErrorL = discardEdges(stableNormalize(sErrorL));

reconError = sErrorL;
rErrorMap=min(reconError(:)) .* ones(imSize);
rErrorMap(5:(end-4),5:(end-4))=reconError(5:(end-4),5:(end-4));
sDiffMap = rErrorMap;

end

function result = discardEdges(map)
result=min(map(:)) .* ones(size(map));
result(4:(end-3),4:(end-3))=map(4:(end-3),4:(end-3));
end

function [avg] = segAvg(SEGMENTS,map)
STATS = regionprops(SEGMENTS,map,'MeanIntensity','PixelValues');
avg = [STATS.MeanIntensity];
end

function [sError] = structDifference(a,rad,L_SPM,STATS2,SEGMENTS,numOfSegments,imSize)
sPixelVar=[STATS2.MeanIntensity]-(L_SPM).^2; %Calc variance
[~,IX] = sort(sPixelVar,'descend'); % getting indices of pixels in variance in descending order
IX = (IX(1:round(numOfSegments/4))); % narrow to highest 25% indices
SOI = ismember(SEGMENTS, IX);
clear SEGMENTS;
IX = (find(SOI));
if (~strcmp(mexext,'mexw64'))
     pVecL_fx = im2col(padarray(double(a),[4 4],'replicate'),[9 9],'sliding')';
     pVecL_fy = im2col(padarray(double(rad),[4 4],'replicate'),[9 9],'sliding')';
else
    pVecL_fx = im2colstep(padarray(double(a),[4 4],'replicate'),[9 9])';
    pVecL_fy = im2colstep(padarray(double(rad),[4 4],'replicate'),[9 9])';
end
% Lm_fx = repmat(mean(pVecL_fx,2),[1 size(pVecL_fx,2)]);
% Lm_fy = repmat(mean(pVecL_fy,2),[1 size(pVecL_fy,2)]);
sError =  (projNrec([pVecL_fx,pVecL_fy] ,IX,imSize));
% sError_fy =  (projNrec(pVecL_fy,IX,imSize));
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
        return;
    end
    valueMap = valueMap./mean(sortVMap(1:max(round(numel(sortVMap)*.01),1)));
    valueMap(valueMap>1)=1;
end