function W = imOrientation(sal)
imSize = size(sal);
padSize = rem(3-rem(imSize(1:2),3),3);
pSal = padarray(sal,padSize,'replicate','post');
imSize=size(pSal);
tSize = imSize(1:2)/3;
pVec = im2col(pSal,tSize,'distinct');
W = reshape(mean(pVec),[3 3]);
end