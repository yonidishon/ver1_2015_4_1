function tmpMap = multiResTemp(H,V,spatialSaliencyMap)
% filt = fspecial('gaussian',10,4);
% fuzzySpat = imfilter(spatialSaliencyMap,filt);
%         figure;imagesc(fuzzySpat);axis image;
%         frameDiff = single(imfilter(frameCurrent,filt))-single(imfilter(framePrev,filt));
% frameDiff = (single(frameCurrent)-single(framePrev)).*fuzzySpat;

% ttt = frameCurrent;
% filt = fspecial('gaussian',5,2);
% tmpMap = zeros([size(frameCurrent) 2]);
orgSize = size(frameCurrent);
% for lvl=1:2

% frameDiff = single(imfilter(frameCurrent,filt))-single(imfilter(framePrev,filt));

% if (max(frameDiff(:))>10)
%     [FX,FY] = gradient(frameDiff);
    tmp  = temporalSal(cat(3,single(V),single(H)),spatialSaliencyMap);
%     tmpMap = imresize(stableNormalize(imfill(tmp,'holes')),orgSize);
% else
%     tmpMap=nan;
%     return;
% end
%         frameCurrent = impyramid(frameCurrent, 'reduce');
%         framePrev = impyramid(framePrev, 'reduce');
%         spatialSaliencyMap = impyramid(spatialSaliencyMap, 'reduce');
% end
% tmpMap = sum(tmpMap,3);

end