function [result] = globalTempDistinctness(frameCurrent,prevFrames)

orgSize=size(frameCurrent);
orgSize=orgSize(1:2);
numOfLevels=3;
stDistinc = zeros(orgSize(1),orgSize(2),numOfLevels);
clDistinc = stDistinc;
currP = frameCurrent;
prevP = prevFrames;
for pInd=1:numOfLevels
    [ST CL]  = globalTempDiff(cat(3,currP,prevP));
    stDistinc(:,:,pInd) = imresize(ST,orgSize,'bicubic');
    clDistinc(:,:,pInd) = imresize(CL,orgSize,'bicubic');
    currP = impyramid(currP, 'reduce');
    if (~isempty(prevP))
        prevP = impyramid(prevP, 'reduce');
    end
end

stDistinc(stDistinc<0)=0;
clDistinc(clDistinc<0)=0;

% for idx=1:numOfLevels
%    I = stDistinc(:,:,idx);
%    I = round(I./max(I(:))*255);
% %    imwrite(I,jet(256),['manPattern' num2str(idx) '.png'],'png');
%    imwrite(I,['manPattern' num2str(idx) '.png'],'png');
%    I = clDistinc(:,:,idx);
%    I = round(I./max(I(:))*255);
%    imwrite(I,['manColor' num2str(idx) '.png'],'png');
% %    imwrite(I,jet(256),['manColor' num2str(idx) '.png'],'png');
%
% end


% baseWeight= 2*(1:numOfLevels);
baseWeight= (numOfLevels:-1:1);

baseWeight=baseWeight./sum(baseWeight);
weights=repmat(permute(baseWeight,[3 1 2]),[orgSize(1) orgSize(2) 1]);
stResult = sum(weights.*stDistinc,3);
clResult = sum(weights.*clDistinc,3);
out = imfill(stResult);
result = stableNormalize(clResult.*out);

if (nargout >1)
    % Pattern = out;
    Pattern = stResult;
    Pattern= Pattern-min(Pattern(:));
    Pattern = Pattern./max(Pattern(:));
    
    Color = clResult;
    % Color= Color-min(Color(:));
    Color = Color./max(Color(:));
end

% figure;imagesc(frameCurrent);axis image;
% figure;imagesc(out);axis image;colormap(jet);colormap(gray);

% figure;imagesc(clResult);axis image;colormap(jet);colormap(gray);
% figure;imagesc(stableNormalize(clResult.*out));axis image;colormap(jet);colormap(gray);

% stResult = imfilter(stResult,fspecial('gaussian',16,5));

%         imwrite(result,[saveDIR 'sd+cd.png'],'png');

% t=(stResult./max(stResult(:)));
% imwrite(round(t.*255),jet(256),'forkPCA.png','png');

% figure;imagesc(out);axis image;colormap(gray);title('struct');
% imwrite(out./max(out(:)),'struct.png','png');
% figure;imagesc(clResult);axis image;colormap(gray);title('color');
% imwrite(clResult./max(clResult(:)),'color.png','png');
%
% figure;imagesc(out-stResult);axis image;colormap(gray);
%
% newR = bwmorph((out-stResult)>0.1,'clean');
% figure;imagesc(newR.*result);axis image;
% STATS =regionprops(newR,result,'centroid','Area','MeanIntensity');
%
% C = round(reshape([STATS.Centroid],2,[])');
% Cw = [STATS.MeanIntensity];
% Ca = [STATS.Area];
% C(Ca<50,:) = [];
% Cw(Ca<50) = [];
% Ca(Ca<50) = [];
%
% % idx = sub2ind(size(resultD),C(:,2),C(:,1));
% % Cw = Cw.*resultD(idx);
% obj = gmdistribution(C,[100 100],Cw);
%
% obj = gmdistribution(C,[5000 5000],Cw);
% [X Y] = meshgrid(1:size(result,2),1:size(result,1));
% W = reshape(pdf(obj, [X(:) Y(:)]),size(result));
% W = W./max(W(:));
% figure;imagesc(W);axis image;
% resultD = stableNormalize(result.*W);
% figure;imagesc(resultD);axis image;colormap(gray);
end