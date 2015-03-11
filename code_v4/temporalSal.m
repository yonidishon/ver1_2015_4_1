function [sDiffMap] = temporalSal(I_grad,spatSal)
imSize = size(I_grad);
imSize=imSize(1:2);
% I_mag = sqrt(sum(I_grad.^2,3));
% SEGMENTS = vl_slic(I_grad, 16, 300,'MinRegionSize',16);
% % figure;imagesc(SEGMENTS);colormap(rand(max(SEGMENTS(:)),3));axis image;
% [~, ~, n] = unique(SEGMENTS); %Ensure no missing index
% SEGMENTS = reshape(n,size(SEGMENTS)); %Ensure no missing index
% numOfSegments = max(SEGMENTS(:));

% STATSY2 = regionprops(SEGMENTS,I_grad(:,:,1).^2,'MeanIntensity');
% STATSX2 = regionprops(SEGMENTS,I_grad(:,:,2).^2,'MeanIntensity');
% Y_SPM = segAvg(SEGMENTS,I_grad(:,:,1))';
% X_SPM = segAvg(SEGMENTS,I_grad(:,:,2))';
% spm = [Y_SPM' X_SPM'];

reconError = discardEdges(stableNormalize(structDifference(I_grad,spatSal,imSize)));
% sErrorX = discardEdges(stableNormalize(structDifference(I_grad(:,:,2)-mean2(I_grad(:,:,2)),X_SPM,STATSX2,SEGMENTS,numOfSegments,imSize)));
% clear STATSY2 STATSX2;

% reconError = sErrorY+sErrorX;
rErrorMap=min(reconError(:)) .* ones(imSize);
rErrorMap(5:(end-4),5:(end-4))=reconError(5:(end-4),5:(end-4));
% rErrorMap(9:(end-8),9:(end-8))=reconError(9:(end-8),9:(end-8));

sDiffMap = rErrorMap;
end

function [avg] = segAvg(SEGMENTS,map)
STATS = regionprops(SEGMENTS,map,'MeanIntensity','PixelValues');
avg = [STATS.MeanIntensity];
end


function sError = structDifference(I_grad,spatSal,imSize)
[~,IX] = sort(spatSal(:),'descend');
IX = (IX(1:round(numel(spatSal)/64)));
pVecY = im2colstep(padarray(double(I_grad(:,:,1)),[4 4],'replicate'),[9 9])';
pVecX = im2colstep(padarray(double(I_grad(:,:,2)),[4 4],'replicate'),[9 9])';
sError =  (projNrec([pVecY pVecX],IX,imSize));

end