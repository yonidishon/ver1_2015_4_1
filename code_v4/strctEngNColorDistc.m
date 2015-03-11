function [sEnerg cDistinc] = strctEngNColorDistc(I_LAB)
%Calculates Structural Energy and Color Distinctness
imSize = size(I_LAB);
paddedL=[I_LAB(:,:,1) zeros(imSize(1),1)];
paddedA=[I_LAB(:,:,2) zeros(imSize(1),1)];
paddedB=[I_LAB(:,:,3) zeros(imSize(1),1)];
bigPatchI = reshape(1:49,7,7);
currentPatchI = bigPatchI(3:5,3:5);
surroundingPatchI =  setdiff(bigPatchI(:), currentPatchI(:)) ;

indexMap = reshape(1:(prod(imSize(1:2))),imSize(1:2));
cDistincTMP = nan(size(indexMap));
sEnrgL = nan(size(indexMap));
sEnrgA = nan(size(indexMap));
sEnrgB = nan(size(indexMap));

%Calculates the color difference between the out surrounding box and inner

%patch
    function colorDistinctness(indiciesPatch)
        innerPatch = indiciesPatch(currentPatchI,:);
        surroundingPatch = indiciesPatch(surroundingPatchI,:);
        jumbledL = mean(paddedL(innerPatch));      
        jumbledA = mean(paddedA(innerPatch));
        jumbledB = mean(paddedB(innerPatch));
        sampledL = mean(paddedL(surroundingPatch));
        sampledA = mean(paddedA(surroundingPatch));
        sampledB = mean(paddedB(surroundingPatch));
%         localCDistinc = min(sum((jumbledL-sampledL).^2+(jumbledA-sampledA).^2 + (jumbledB-sampledB).^2),10);
        localCDistinc = ((abs(jumbledL-sampledL)+0.5*abs(jumbledA-sampledA) + 0.5*abs(jumbledB-sampledB)));

        centerIndicies = indiciesPatch(bigPatchI(4,4),:);
        %Discard border pixels
        localCDistinc(centerIndicies==numel(paddedA))=[];
        centerIndicies(centerIndicies==numel(paddedA))=[];
        
        cDistincTMP(centerIndicies) = localCDistinc;
    end



    function sEnergy = structuralEnergy(patch)
        [~,row] = sort(rand(size(patch,1),size(patch,2)));
        jumbledPatch=zeros(size(patch));
        col=repmat(1:size(patch,2),[size(jumbledPatch,1) 1]);
        pIndex = sub2ind(size(patch),row,col);
        jumbledPatch(pIndex)=patch;
        sEnergy = mean(abs(jumbledPatch-patch));
    end

    function result = structNColor(indiciesPatch)
        indiciesPatch(indiciesPatch==0)=numel(paddedL);

        colorDistinctness(indiciesPatch);

        lSE = structuralEnergy(paddedL(indiciesPatch));
%          = lSE;
        aSE = structuralEnergy(paddedA(indiciesPatch));
        bSE = structuralEnergy(paddedB(indiciesPatch));
        result = (lSE+aSE+bSE)/3;

        
        
%         centerIndicies = indiciesPatch(bigPatchI(4,4),:);
%         %Discard border pixels
%         lSE(centerIndicies==numel(paddedA))=[];
%         aSE(centerIndicies==numel(paddedA))=[];
%         bSE(centerIndicies==numel(paddedA))=[];
%         centerIndicies(centerIndicies==numel(paddedA))=[];
%         
%         sEnrgL(centerIndicies) = lSE;
%         sEnrgA(centerIndicies) = aSE;
%         sEnrgB(centerIndicies) = bSE;
        
    end


% tmp= colfilt(I_LAB(:,:,1),[5 5],'sliding',@structuralEnergy);
% sEnerg1=zeros(size(tmp));
% sEnerg1(3:(end-2),3:(end-2))=tmp(3:(end-2),3:(end-2));
% clear tmp;

tmp= colfilt(indexMap,[7 7],'sliding',@structNColor);
sEnerg=zeros(size(tmp));
sEnerg(4:(end-3),4:(end-3))=tmp(4:(end-3),4:(end-3));

% figure;imagesc(sEnerg);axis image;colormap(hot);


if (any(isnan(cDistincTMP)))
    error('Not all patches were calculated');
end

cDistinc=min(cDistincTMP(:))*ones(size(cDistincTMP));
cDistinc(4:(end-3),4:(end-3))=cDistincTMP(4:(end-3),4:(end-3));
cDistinc=imfilter(cDistinc,fspecial('gaussian',4,2));
clear cDistincTMP;


end