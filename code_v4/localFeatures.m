function result = localFeatures(I_LAB)

numOfLevels=1+ceil(log2(max(size(I_LAB))/50));
sEnergy = zeros(size(I_LAB,1),size(I_LAB,2),numOfLevels);
cDistinc = zeros(size(I_LAB,1),size(I_LAB,2),numOfLevels);

orgSize = size(I_LAB(:,:,1));
[currPyramid prevPyramid] = deal(I_LAB);
for pInd=1:numOfLevels
    [sEnergyT cDistincT] = strctEngNColorDistc(currPyramid);
    sEnergy(:,:,pInd) = imresize(sEnergyT,orgSize,'bicubic');
    cDistinc(:,:,pInd) = imresize(cDistincT,orgSize,'bicubic');

    
    currPyramid= impyramid(prevPyramid, 'reduce');
    prevPyramid=currPyramid;
end
sEnergy(sEnergy<0)=0;
cDistinc(cDistinc<0)=0;
% baseWeight= 2*(numOfLevels:-1:1);
baseWeight= 2*(1:numOfLevels);
% baseWeight= zeros(1,numOfLevels);
% baseWeight(1) = 1;

baseWeight=baseWeight./sum(baseWeight);
weights=repmat(permute(baseWeight,[3 1 2]),[orgSize(1) orgSize(2) 1]);

totalSEnergy = sum(weights.*sEnergy,3);
% figure;imagesc(totalSEnergy);axis image;colormap(hot);

% figure;imagesc(totalSEnergy);colormap(hot);

% baseWeight= 2*(1:numOfLevels);
baseWeight= 2*(numOfLevels:-1:1);
baseWeight=baseWeight./sum(baseWeight);
weights=repmat(permute(baseWeight,[3 1 2]),[orgSize(1) orgSize(2) 1]);

totalCDistinc = sum(weights.*cDistinc,3);
% figure;imagesc(totalCDistinc);axis image;colormap(hot);

%  ntotalCDistinc = stableNormalize(totalCDistinc);
%  ntotalSEnergy = stableNormalize(totalSEnergy);
% result = ntotalSEnergy+ntotalCDistinc;

% result = totalSEnergy+0.5*totalCDistinc;
result = totalSEnergy;
% figure;imagesc(result);axis image;colormap(hot);

end