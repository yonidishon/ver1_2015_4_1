function result = structuralEnergy(I_LAB)

numOfLevels=1+ceil(log2(max(size(I_LAB))/50));
sEnergy = zeros(size(I_LAB,1),size(I_LAB,2),numOfLevels);

orgSize = size(I_LAB(:,:,1));
[currPyramid prevPyramid] = deal(I_LAB);
for pInd=1:numOfLevels
    sEnergyT = strctEng(currPyramid);
    sEnergy(:,:,pInd) = imresize(sEnergyT,orgSize,'bicubic');
    currPyramid= impyramid(prevPyramid, 'reduce');
    prevPyramid=currPyramid;
end
sEnergy(sEnergy<0)=0;
baseWeight= 2*(1:numOfLevels);
baseWeight=baseWeight./sum(baseWeight);
weights=repmat(permute(baseWeight,[3 1 2]),[orgSize(1) orgSize(2) 1]);
result = stableNormalize(sum(weights.*sEnergy,3));
end