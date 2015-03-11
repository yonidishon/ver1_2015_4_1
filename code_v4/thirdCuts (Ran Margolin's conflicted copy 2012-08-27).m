function segResult = thirdCuts(I_RGB,pixelSaliency)
imSize = size(I_RGB);
padSize = rem(3-rem(imSize(1:2),3),3);
pRGB = padarray(I_RGB,padSize,'replicate','post');
imSize=size(pRGB);
tSize = imSize(1:2)/3;
I_LAB = single(rgb2lab(pRGB));
mThirds = zeros(3,3,3);
L = im2col(I_LAB(:,:,1),tSize,'distinct');
A = im2col(I_LAB(:,:,2),tSize,'distinct');
B = im2col(I_LAB(:,:,3),tSize,'distinct');
S = im2col(pixelSaliency,tSize,'distinct');
S= S./repmat(sum(S),[size(S,1) 1]); %Normalize each third
indx = find(S>=0.55);
mThirds(:,:,1) = reshape(sum(L.*S),[3 3]);
mThirds(:,:,2) = reshape(sum(A.*S),[3 3]);
mThirds(:,:,3) = reshape(sum(B.*S),[3 3]);
cThirds = zeros(3,3,9);
for thrd=1:9
    cThirds(:,:,thrd) = cov([L(:,thrd) A(:,thrd) B(:,thrd)]);
end
SEGMENTS = vl_slic(I_LAB, 16, 300,'MinRegionSize',64);
[~, ~, n] = unique(SEGMENTS); %Ensure no missing index
SEGMENTS = reshape(n,size(SEGMENTS)); %Ensure no missing index
numOfSegments = max(SEGMENTS(:));
colors = zeros(numOfSegments,3);
for cidx = 1:3
    STATS = regionprops(SEGMENTS,I_LAB(:,:,cidx),'MeanIntensity');
    colors(:,cidx) = [STATS.MeanIntensity];
end
indx= 1;
segResult = zeros([size(SEGMENTS),9]);
for row = 1:3
    for col =1:3
        C = cThirds(:,:,sub2ind([3 3],row,col));
        segResult(:,:,indx) = growColor(row,col,SEGMENTS,mThirds,C,colors);
        indx=indx+1;
    end
end



end


function segResult = growColor(row,col,SEGMENTS,mThirds,C,colors)
cColor = squeeze(mThirds(row,col,:))';
done =false;
pnum=0;
while ~done
    d = pdist2(cColor,colors,'mahalanobis',C);
    indx = find(d<=1.8);
    cColor = 0.5*mean(colors(indx,:))+0.5*cColor;
    done = numel(indx) == pnum;
    pnum = numel(indx);
end
segResult = ismember(SEGMENTS,indx);
figure;imshow(segResult);
end