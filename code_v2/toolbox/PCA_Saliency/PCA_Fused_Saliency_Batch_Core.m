function [result, resultD] = PCA_Fused_Saliency_Batch_Core(fx,fy,I_RGB)
% Yonatan Created 14/02/2015
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
    % result = stableNormalize(resultD(:,:,ii).*W);
    result(:,:,ii) = stableNormalize(W);
    if max(reshape(result(:,:,ii),numel(result(:,:,ii)),1))==0 %black image input
        result(:,:,ii)=ones(size(result(:,:,ii)));
    end
    resultD(:,:,ii) = stableNormalize(resultD(:,:,ii));
end
end

function [result] = globalDistinctness(a,rad,I_RGB)

orgSize=size(I_RGB);
orgSize=orgSize(1:2);
numOfLevels=3;
stDistinc = zeros(orgSize(1),orgSize(2),numOfLevels*size(I_RGB,4));
st1Distinc = stDistinc;
clDistinc = stDistinc;
Pyramid = I_RGB;

for pInd=1:numOfLevels
    [ST]  = globalDiff(a,rad,Pyramid);
    [ST1 CL]  = globalDiff1(Pyramid);
    stDistinc(:,:,1+(pInd-1)*size(I_RGB,4):(pInd)*size(I_RGB,4)) = imresize(ST,orgSize,'bicubic');
    st1Distinc(:,:,1+(pInd-1)*size(I_RGB,4):(pInd)*size(I_RGB,4)) = imresize(ST1,orgSize,'bicubic');
    %clDistinc(:,:,1+(pInd-1)*size(I_RGB,4):(pInd)*size(I_RGB,4)) = imresize(CL,orgSize,'bicubic');
    Pyramid = impyramid(Pyramid, 'reduce');
    a = impyramid(a, 'reduce');
    rad = impyramid(rad, 'reduce');
end

stDistinc(stDistinc<0)=0;
st1Distinc(stDistinc<0)=0;
%clDistinc(clDistinc<0)=0;

baseWeight= (numOfLevels:-1:1);

baseWeight=baseWeight./sum(baseWeight);
weights=reshape(repmat(baseWeight,orgSize(1)*orgSize(2)*size(I_RGB,4),1),[orgSize(1) orgSize(2) numOfLevels*size(I_RGB,4)]);
sttmp=weights.*stDistinc;
st1tmp=weights.*st1Distinc;
%cltmp=weights.*clDistinc;
clear stDistinc st1Distinc clDistinc
result=zeros(orgSize(1),orgSize(2),size(I_RGB,4));
for ii=1:size(I_RGB,4)
    stResult = sum(reshape([sttmp(:,:,ii),sttmp(:,:,ii+size(I_RGB,4)),sttmp(:,:,ii+2*size(I_RGB,4))],orgSize(1),orgSize(2),numOfLevels),3);
    st1Result = sum(reshape([st1tmp(:,:,ii),st1tmp(:,:,ii+size(I_RGB,4)),st1tmp(:,:,ii+2*size(I_RGB,4))],orgSize(1),orgSize(2),numOfLevels),3);
    %clResult = sum(reshape([cltmp(:,:,ii),cltmp(:,:,ii+size(I_RGB,4)),cltmp(:,:,ii+2*size(I_RGB,4))],orgSize(1),orgSize(2),numOfLevels),3);
    out = imfill(stResult);
    out1 = imfill(st1Result);
    %result(:,:,ii) = stableNormalize(stableNormalize(clResult.*out).*stableNormalize(out1));
    result(:,:,ii) = stableNormalize(stableNormalize(out).*stableNormalize(out1));
end
end

function [sDiffMap] = globalDiff(a,rad,I_RGB)
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
    SEGMENTS(:,:,ii) = reshape(n,size(SEGMENTS(:,:,ii)));
    numOfSegments = max(SEGMENTS(:));
    STATS2{ii} = segAvg(SEGMENTS(:,:,ii),a(:,:,ii).^2);
    STATSA{ii} = segAvg(SEGMENTS(:,:,ii),rad(:,:,ii).^2);  
    L_SPM{ii} = segAvg(SEGMENTS(:,:,ii),a(:,:,ii));
    A_SPM{ii} = segAvg(SEGMENTS(:,:,ii),rad(:,:,ii));
end
numOfSegments = squeeze(max(max(SEGMENTS,[],1),[],2));
centeredtmp=a-repmat(reshape(mean(reshape(a,imSize(1)*imSize(2),size(I_LAB,4))),1,1,size(I_LAB,4)),imSize(1),imSize(2),1);
sErrorL_fx=structDifference1(centeredtmp,L_SPM,STATS2,SEGMENTS,numOfSegments,size(SEGMENTS));
sErrorL_fx = discardEdges(stableNormalize(sErrorL_fx));
centeredtmp=rad-repmat(reshape(mean(reshape(rad,imSize(1)*imSize(2),size(I_LAB,4))),1,1,size(I_LAB,4)),imSize(1),imSize(2),1);
sErrorA_fy = structDifference1(centeredtmp,A_SPM,STATSA,SEGMENTS,numOfSegments,size(SEGMENTS));
sErrorA_fy = discardEdges(stableNormalize(sErrorA_fy));

clear centeredtmp STATSA STATS2;
reconError = sErrorL_fx+sErrorA_fy;
rErrorMap=zeros(size(reconError));
for ii=1:size(reconError,3)
    tmp=reconError(:,:,ii);
    rErrorMap(:,:,ii)=min(tmp(:)) .* ones(imSize);
    rErrorMap(5:(end-4),5:(end-4),ii)=tmp(5:(end-4),5:(end-4));
end
sDiffMap = rErrorMap;
end

function [sDiffMap cDiffMap] = globalDiff1(I_RGB)
I_LAB = single(rgb2lab(I_RGB));
imSize = size(I_LAB);
imSize=imSize(1:2);
SEGMENTS=zeros(imSize(1),imSize(2),size(I_LAB,4));
STATS2 = cell(size(I_LAB,4),1);
STATSA = cell(size(I_LAB,4),1);
STATSB = cell(size(I_LAB,4),1);
L_SPM = cell(size(I_LAB,4),1);
A_SPM = cell(size(I_LAB,4),1);
B_SPM = cell(size(I_LAB,4),1);
cDiffMap = zeros(imSize(1),imSize(2),size(I_LAB,4));
for ii=1:size(I_LAB,4)
    SEGMENTS(:,:,ii) = vl_slic(I_LAB(:,:,:,ii), 16, 300,'MinRegionSize',16);
    [~, ~, n] = unique(SEGMENTS(:,:,ii)); %Ensure no missing index
    SEGMENTS(:,:,ii) = reshape(n,size(SEGMENTS(:,:,ii))); %Ensure no missing index
    % This is the same as PCA_Saliency_Core -> segAvg here does the same
    % regionprops MeanIntensity thing.
    STATS2{ii} = segAvg(SEGMENTS(:,:,ii),I_LAB(:,:,1,ii).^2)';
    
    L_SPM{ii} = segAvg(SEGMENTS(:,:,ii),I_LAB(:,:,1,ii))';
    A_SPM{ii}  = segAvg(SEGMENTS(:,:,ii),I_LAB(:,:,2,ii));
    A_SPM{ii} = A_SPM{ii}';
    
    B_SPM{ii}  = segAvg(SEGMENTS(:,:,ii),I_LAB(:,:,3,ii));
    B_SPM{ii} = B_SPM{ii}';
    
    spm = [L_SPM{ii} A_SPM{ii} B_SPM{ii}];
    STATSA{ii} = segAvg(SEGMENTS(:,:,ii),I_LAB(:,:,2,ii))';
    STATSB{ii} = segAvg(SEGMENTS(:,:,ii),I_LAB(:,:,3,ii))';
    dd = squareform(pdist(spm));
    T = mean(abs(dd));
    numOfSegments = max(max(SEGMENTS(:,:,ii)));
    tmp=zeros(imSize);
    for seg=1:numOfSegments
        subs=ismember(SEGMENTS(:,:,ii),seg);
        tmp(subs)=T(seg);
    end
    cDiffMap(:,:,ii) = tmp;
end 

numOfSegments = squeeze(max(max(SEGMENTS,[],1),[],2));
centeredtmp=squeeze(I_LAB(:,:,1,:))-repmat(reshape(mean(reshape(squeeze(I_LAB(:,:,1,:)),imSize(1)*imSize(2),size(I_LAB,4))),1,1,size(I_LAB,4)),imSize(1),imSize(2),1);
sErrorL = discardEdges(stableNormalize(structDifference1(centeredtmp,L_SPM,STATS2,SEGMENTS,numOfSegments,size(SEGMENTS))));
centeredtmp=squeeze(I_LAB(:,:,2,:))-repmat(reshape(mean(reshape(squeeze(I_LAB(:,:,2,:)),imSize(1)*imSize(2),size(I_LAB,4))),1,1,size(I_LAB,4)),imSize(1),imSize(2),1);
sErrorA = discardEdges(stableNormalize(structDifference1(centeredtmp,A_SPM,STATSA,SEGMENTS,numOfSegments,size(SEGMENTS))));
centeredtmp=squeeze(I_LAB(:,:,3,:))-repmat(reshape(mean(reshape(squeeze(I_LAB(:,:,3,:)),imSize(1)*imSize(2),size(I_LAB,4))),1,1,size(I_LAB,4)),imSize(1),imSize(2),1);
sErrorB = discardEdges(stableNormalize(structDifference1(centeredtmp,B_SPM,STATSB,SEGMENTS,numOfSegments,size(SEGMENTS))));

clear centeredtmp STATSA STATSB;
reconError = sErrorL+sErrorA+sErrorB;
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
    result(4:(end-3),4:(end-3),ii)=tmp(4:(end-3),4:(end-3));
end
end

function [avg] = segAvg(SEGMENTS,map)
STATS = regionprops(SEGMENTS,map,'MeanIntensity','PixelValues');
avg = [STATS.MeanIntensity];
end

function [sError_fx] = structDifference(a,L_SPM,STATS2,SEGMENTS,numOfSegments,imSize)
sPixelVar=cellfun(@minus,STATS2,cellfun(@(x)x.^2,L_SPM,'UniformOutput',false),'UniformOutput',false); %Calc variance
[~,IX]=cellfun(@(x)sort(x,'ascend'),sPixelVar,'UniformOutput',false);
SOI=cellfun(@ismember,squeeze(mat2cell(SEGMENTS,size(SEGMENTS,1),size(SEGMENTS,2),ones(size(SEGMENTS,3),1)))...
   ,cellfun(@(x,y)x(1:y),IX,mat2cell(round(numOfSegments/4),ones(length(numOfSegments),1)),'UniformOutput',false),'UniformOutput',false);
clear SEGMENTS;
IX=cellfun(@find,SOI,'UniformOutput',false);
if (~strcmp(mexext,'mexw64'))
    tmp = im2col(padarray(double(a),[3 3],'replicate'),[7 7],'sliding')';
    pVecL = [pVecL;tmp];
    poiVec = [poiVec;tmp(IX{ii},:)];
else
    tmp = im2colstep(padarray(double(a),[3 3],'replicate'),[7 7])';
    pVecL = [pVecL;tmp];
    poiVec = [poiVec;tmp(IX{ii},:)];
end
Lm_fx = repmat(mean(pVecL_fx,2),[1 size(pVecL_fx,2)]);
%Lm_fy = repmat(mean(pVecL_fy,2),[1 size(pVecL_fy,2)]);
sError_fx =  (projNrec(pVecL_fx-Lm_fx,poiVec,imSize));
%sError_fy =  (projNrec(pVecL_fy-Lm_fy,IX,imSize));
end

function sError = structDifference1(L,L_SPM,STATS2,SEGMENTS,numOfSegments,imSize)
sPixelVar=cellfun(@minus,STATS2,cellfun(@(x)x.^2,L_SPM,'UniformOutput',false),'UniformOutput',false); %Calc variance
[~,IX]=cellfun(@(x)sort(x,'ascend'),sPixelVar,'UniformOutput',false);
SOI=cellfun(@ismember,squeeze(mat2cell(SEGMENTS,size(SEGMENTS,1),size(SEGMENTS,2),ones(size(SEGMENTS,3),1)))...
   ,cellfun(@(x,y)x(1:y),IX,mat2cell(round(numOfSegments/4),ones(length(numOfSegments),1)),'UniformOutput',false),'UniformOutput',false);clear SEGMENTS;
clear SEGMENTS;
IX=cellfun(@find,SOI,'UniformOutput',false);
pVecL=[];
poiVec=[];
for ii=1:size(L,3)
    
    if (~strcmp(mexext,'mexw64'))
        tmp = im2col(padarray(double(L(:,:,ii)),[4 4],'replicate'),[9 9],'sliding')';
        pVecL = [pVecL;tmp];
        poiVec = [poiVec;tmp(IX{ii},:)];
    else
        tmp =im2colstep(padarray(double(L(:,:,ii)),[4 4],'replicate'),[9 9])';
        pVecL = [pVecL;tmp];
        poiVec = [poiVec;tmp(IX{ii},:)];
    end
end
Lm = repmat(mean(pVecL,2),[1 size(pVecL,2)]);
sError =  (projNrec(pVecL-Lm,poiVec,imSize));
end

function [reconError] =  projNrec(pVec,poiVec,imSize)
Lm = repmat(mean(poiVec,1),[size(poiVec,1) 1]);
[COEFF,jnk] = princomp(poiVec-Lm);
reconError = sum(abs((pVec*COEFF)),2);
reconError = reshape(reconError,imSize);
end

function LAB = rgb2lab(RGB)
dRGB=im2double(RGB);
C=makecform('srgb2lab');
for ii=1:size(RGB,4)
    LAB(:,:,:,ii)=lab2double(applycform(dRGB(:,:,:,ii),C));
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
        return;
    end
    tmp = tmp./mean(stmp(1:max(round(numel(stmp)*.01),1)));
    tmp(tmp>1)=1;
    valueMap(:,:,ii)=tmp;
end
end



