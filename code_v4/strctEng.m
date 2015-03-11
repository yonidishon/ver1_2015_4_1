function sEnerg = strctEng(I_LAB)
%Calculates Structural Energy and Color Distinctness
imSize = size(I_LAB);
paddedL=[I_LAB(:,:,1) zeros(imSize(1),1)];
paddedA=[I_LAB(:,:,2) zeros(imSize(1),1)];
paddedB=[I_LAB(:,:,3) zeros(imSize(1),1)];

indexMap = reshape(1:(prod(imSize(1:2))),imSize(1:2));

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

        lSE = structuralEnergy(paddedL(indiciesPatch));
        aSE = structuralEnergy(paddedA(indiciesPatch));
        bSE = structuralEnergy(paddedB(indiciesPatch));
        result = (lSE+aSE+bSE)/3;
    end


tmp= colfilt(indexMap,[7 7],'sliding',@structNColor);
sEnerg=zeros(size(tmp));
sEnerg(4:(end-3),4:(end-3))=tmp(4:(end-3),4:(end-3));


end