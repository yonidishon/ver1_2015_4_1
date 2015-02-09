function [result resultD] = PCA_Motion_Saliency_Core_Batch(fx,fy,I_RGB)
% Yonatan Created 09/02/2015 - going to batch mode for scene PCA
UNKNOWN_FLOW_THRESH=1e9;
idxUnknown = (abs(fx)> UNKNOWN_FLOW_THRESH) | (abs(fy)> UNKNOWN_FLOW_THRESH) ;
fx(idxUnknown) = 0;
fy(idxUnknown) = 0;
r=sqrt(fx.^2+fy.^2);
fy(r<0.2) = 0;
fx(r<0.2) = 0;
resultD = globalDistinctness(fx,fy,I_RGB);
result=zeros(size(resultD));
for ii=1:size(resultD,3)
    C = zeros(11,2);
    Cw = zeros(11,1);
    idx=1;
    for th=1:-0.1:0.1
        bw = resultD(:,:,ii)>=th;
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
    W = reshape(pdf(gmdistribution(C,[300 300],Cw), [X(:) Y(:)]),size(resultD(:,:,ii)));
    W = W./max(W(:));
    result(:,:,ii) = stableNormalize(resultD(:,:,ii).*W);
    %result(:,:,ii) = stableNormalize(W);
    if max(reshape(result(:,:,ii),numel(result(:,:,ii)),1))==0 %black image input
        result(:,:,ii)=W;
    end
    resultD(:,:,ii) = stableNormalize(resultD(:,:,ii));
end
end

function [result] = globalDistinctness(fx,fy,I_RGB)

orgSize=size(I_RGB);
orgSize=orgSize(1:2);
numOfLevels=3;
stDistinc = zeros(orgSize(1),orgSize(2),numOfLevels*size(I_RGB,4));
Pyramid = I_RGB;

for pInd=1:numOfLevels
    ST  = globalDiff(fx,fy,Pyramid);
    stDistinc(:,:,1+(pInd-1)*size(I_RGB,4):(pInd)*size(I_RGB,4)) = imresize(ST,orgSize,'bicubic');
    Pyramid = impyramid(Pyramid, 'reduce');
end

stDistinc(stDistinc<0)=0;

baseWeight= (numOfLevels:-1:1);

baseWeight=baseWeight./sum(baseWeight);
% Making the weights to be multiply correctly with the stractural and Color
% Differences
weights=reshape(repmat(baseWeight,orgSize(1)*orgSize(2)*size(I_RGB,4),1),[orgSize(1) orgSize(2) numOfLevels*size(I_RGB,4)]);
sttmp=weights.*stDistinc;
clear stDistinc
result=zeros(orgSize(1),orgSize(2),size(I_RGB,4));
for ii=1:size(I_RGB,4)
    stResult = sum(reshape([sttmp(:,:,ii),sttmp(:,:,ii+size(I_RGB,4)),sttmp(:,:,ii+2*size(I_RGB,4))],orgSize(1),orgSize(2),numOfLevels),3);
    out = imfill(stResult);
    result(:,:,ii) = stableNormalize(out);
end
end

function [sDiffMap] = globalDiff(fx,fy,I_RGB)
I_LAB = single(rgb2lab(I_RGB));
imSize = size(I_LAB);
imSize=imSize(1:2);
SEGMENTS=zeros(imSize(1),imSize(2),size(I_LAB,4));
STATS2 = cell(size(I_LAB,4),1);
STATSA = cell(size(I_LAB,4),1);
L_SPM = cell(size(I_LAB,4),1);
A_SPM = cell(size(I_LAB,4),1);

for ii=1:size(I_LAB,4)
    SEGMENTS(:,:,ii) = vl_slic(I_LAB(:,:,:,ii), 16, 300,'MinRegionSize',16);
    [~, ~, n] = unique(SEGMENTS(:,:,ii)); %Ensure no missing index
    SEGMENTS(:,:,ii) = reshape(n,size(SEGMENTS(:,:,ii))); %Ensure no missing index
    % This is the same as PCA_Saliency_Core -> segAvg here does the same
    % regionprops MeanIntensity thing.
    STATS2{ii} = segAvg(SEGMENTS(:,:,ii),fx(:,:,ii).^2)';
    STATSA{ii} = segAvg(SEGMENTS(:,:,ii),fy(:,:,ii).^2)';
    L_SPM{ii} = segAvg(SEGMENTS(:,:,ii),I_LAB(:,:,1,ii))';
    A_SPM{ii}  = segAvg(SEGMENTS(:,:,ii),I_LAB(:,:,2,ii))';

    

end 

numOfSegments = squeeze(max(max(SEGMENTS,[],1),[],2));
centeredtmp=fx-repmat(reshape(mean(reshape(fx,imSize(1)*imSize(2),size(I_LAB,4))),1,1,size(I_LAB,4)),imSize(1),imSize(2),1);
sErrorfx = discardEdges(stableNormalize(structDifference(centeredtmp,L_SPM,STATS2,SEGMENTS,numOfSegments,size(SEGMENTS))));
centeredtmp=fy-repmat(reshape(mean(reshape(fy,imSize(1)*imSize(2),size(I_LAB,4))),1,1,size(I_LAB,4)),imSize(1),imSize(2),1);
sErrorfy = discardEdges(stableNormalize(structDifference(centeredtmp,A_SPM,STATSA,SEGMENTS,numOfSegments,size(SEGMENTS))));


clear centeredtmp STATSA STATS2;
reconError = sErrorfx+sErrorfy;
rErrorMap=zeros(size(reconError));
for ii=1:size(reconError,3)
    tmp=reconError(:,:,ii);
    rErrorMap(:,:,ii)=min(tmp(:)) .* ones(imSize);
    rErrorMap(5:(end-4),5:(end-4),ii)=tmp(5:(end-4),5:(end-4));
end

sDiffMap = rErrorMap;
end

function result = discardEdges(map)
result=zeros(size(map));
for ii=1:size(map,3)
    tmp=map(:,:,ii);
    result(:,:,ii)=min(tmp(:)) .* ones(size(tmp));
    result(5:(end-4),5:(end-4),ii)=tmp(5:(end-4),5:(end-4));
end
end

function [avg] = segAvg(SEGMENTS,map)
STATS = regionprops(SEGMENTS,map,'MeanIntensity');
avg = [STATS.MeanIntensity];
end

function sError = structDifference(L,L_SPM,STATS2,SEGMENTS,numOfSegments,SceneSize)
sPixelVar=cellfun(@minus,STATS2,cellfun(@(x)x.^2,L_SPM,'UniformOutput',false),'UniformOutput',false); %Calc variance
%[~,IX] = sort(sPixelVar,'descend');
%IX = (IX(1:round(numOfSegments/4)));
%SOI = ismember(SEGMENTS, IX);
%[~,IX]=cellfun(@(x)sort(x,'descend'),sPixelVar,'UniformOutput',false);
[~,IX]=cellfun(@(x)sort(x,'ascend'),sPixelVar,'UniformOutput',false);
SOI=cellfun(@ismember,squeeze(mat2cell(SEGMENTS,size(SEGMENTS,1),size(SEGMENTS,2),ones(size(SEGMENTS,3),1)))...
   ,cellfun(@(x,y)x(1:y),IX,mat2cell(round(numOfSegments/4),ones(length(numOfSegments),1)),'UniformOutput',false),'UniformOutput',false);
clear SEGMENTS;
%IX = (find(SOI));
IX=cellfun(@find,SOI,'UniformOutput',false);
pVecL=[];
poiVec=[];
for ii=1:size(L,3)
    if (~strcmp(mexext,'mexw64'))
        tmp=im2col(padarray(double(L(:,:,ii)),[4 4],'replicate'),[9 9],'sliding')';
        pVecL = [pVecL;tmp];
        poiVec = [poiVec;tmp(IX{ii},:)];
    else
        tmp =im2colstep(padarray(double(L(:,:,ii)),[4 4],'replicate'),[9 9])';
        pVecL = [pVecL;tmp];
        poiVec = [poiVec;tmp(IX{ii},:)];
    end
end
Lm = repmat(mean(pVecL,2),[1 size(pVecL,2)]);
sError =  (projNrec(pVecL-Lm,poiVec,SceneSize));

end

function [reconError] =  projNrec(pVec,poiVec,SceneSize)
Lm = repmat(mean(poiVec,1),[size(poiVec,1) 1]);
[COEFF,jnk] = princomp(poiVec-Lm);
reconError = sum(abs((pVec*COEFF)),2);
reconError = reshape(reconError,SceneSize);
end

function LAB = rgb2lab(RGB)
dRGB=im2double(RGB);
C=makecform('srgb2lab');
LAB=zeros(size(dRGB));
for ii=1:size(RGB,4)
    LAB(:,:,:,ii)=...
    lab2double(applycform(dRGB(:,:,:,ii),C));
    gfilt = fspecial('gaussian',9,4);
    LAB(:,:,2,ii) = imfilter(LAB(:,:,2,ii),gfilt);
    LAB(:,:,3,ii) = imfilter(LAB(:,:,3,ii),gfilt);
end
end

function valueMap = stableNormalize(valueMap)
for ii=1:size(valueMap,3)    
    tmp=valueMap(:,:,ii);
    stmp = sort(tmp(:),'descend');
    stmp(isnan(stmp))=[];
    
    if max(stmp) == 0 && min(stmp)==0
        valueMap(:,:,ii)=zeros(size(tmp));
        continue
    end
    tmp = tmp./mean(stmp(1:max(round(numel(stmp)*.01),1)));
    tmp(tmp>1)=1;
    valueMap(:,:,ii)=tmp;
end
end