function [result] = spatioTemporalSaliency(frameCurrent,prevFrames)
resultD = globalTempDistinctness(frameCurrent,prevFrames);

C = zeros(11,2);
Cw = zeros(11,1);
idx=1;
for th=1:-0.1:0.1
    bw = resultD>=th;
    STATS =regionprops(uint8(bw),'centroid','Area');
    C(idx,:) = round(reshape([STATS.Centroid],2,[])');
    Cw(idx) = th;
    idx=idx+1;
end

C(11,:) = round([size(resultD,2)/2 size(resultD,1)/2]);
Cw(11) = 5;
[X Y] = meshgrid(1:size(resultD,2),1:size(resultD,1));
W = reshape(pdf(gmdistribution(C,[10000 10000],Cw), [X(:) Y(:)]),size(resultD));
W = W./max(W(:));
result = stableNormalize(resultD.*W);
end





