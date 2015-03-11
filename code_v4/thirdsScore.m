function legal = thirdsScore(map)
map = map./max(map(:));
imSize = size(map);
% figure;imagesc(map);axis image;colormap(jet)
padSize = rem(3-rem(imSize(1:2),3),3);
pMap = padarray(map,padSize,'replicate','post');
imSize=size(pMap);
tSize = imSize(1:2)/3;
S = im2col(map,tSize,'distinct');
M = mean(S);
V = M-mean(map(:));
legal=any(V>0.2);
end