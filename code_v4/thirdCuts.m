function segResult = thirdCuts(I_RGB,pixelSaliency)
imSize = size(I_RGB);
thirdsSegment = zeros([imSize(1:2) 9]);
padSize = rem(3-rem(imSize(1:2),3),3);
pRGB = padarray(I_RGB,padSize,'replicate','post');
imSize=size(pRGB);
tSize = imSize(1:2)/3;
I_LAB = single(rgb2lab(pRGB));

% colors = reshape(I_LAB,[imSize(1)*imSize(2) 3]);
% L = im2col(I_LAB(:,:,1),tSize,'distinct');
% A = im2col(I_LAB(:,:,2),tSize,'distinct');
% B = im2col(I_LAB(:,:,3),tSize,'distinct');
S = im2col(pixelSaliency,tSize,'distinct');
N = S./repmat(max(S),[size(S,1) 1]); %Normalize each third



% SEGMENTS = vl_slic(I_LAB, 16, 300,'MinRegionSize',64);
% [~, ~, n] = unique(SEGMENTS); %Ensure no missing index
% SEGMENTS = reshape(n,size(SEGMENTS)); %Ensure no missing index
% numOfSegments = max(SEGMENTS(:));


% S= S./repmat(sum(S),[size(S,1) 1]); %Normalize each third



bg = 0.1;
pbgfg = 0.5;
fg = 0.7;

OUTdir = './OUT/';
imwrite(I_RGB,[OUTdir 'rgbInput.png'],'png');
for thrd=1:9
    thirdcols = S;
    thirdcols(thirdcols>=0.7) = 0.6;
%     thirdcols(thirdcols>=0.7)=0.6;
    tVec= 1-N(:,thrd);
    
thirdcols(:,thrd) = tVec;
%     foregroundIdx = N(:,thrd)>=0.7;
%     backgroundIdx = N(:,thrd)==0;
%     thirdcols(foregroundIdx,thrd)=1;
%     thirdcols(backgroundIdx,thrd)=0;
    thirdMasks = col2im(thirdcols,tSize,imSize(1:2),'distinct');
    thirdMasks = thirdMasks((1+padSize(1)):end,(1+padSize(2)):end);
    thirdMasks(1,:)=0;
    thirdMasks(end,:)=0;
    thirdMasks(:,1)=0;
    thirdMasks(:,end)=0;
    imwrite(thirdMasks,[OUTdir 'thirdMask.png'],'png');
    grabCut([OUTdir 'rgbInput.png'],[OUTdir 'thirdMask.png'],[OUTdir 'grab.png'],[OUTdir 'grab2.png'],bg,pbgfg,fg);
    thirdsSegment(:,:,thrd) = im2double(imread([OUTdir 'grab.png']));
figure;imshow(thirdsSegment(:,:,thrd));
%     Fpdf(thrd) = gmdistribution.fit([L(foregroundIdx,thrd) A(foregroundIdx,thrd) B(foregroundIdx,thrd)],5);
%     Fpdf(thrd) = gmdistribution.fit([L(backgroundIdx,thrd) A(backgroundIdx,thrd) B(backgroundIdx,thrd)],5);
end
% figure;imagesc(1-pixelSaliency);axis image;
% figure;imagesc(I_RGB);axis image;
segResult  = mean(thirdsSegment,3);
figure;imagesc(segResult);axis image;colormap(gray);
% wVec = [1 2 1 2 2 2 1 2 1];
% % wVec = wVec./sum(wVec);
% wVec = squeeze(sum(sum(thirdsSegment,1),2));
% wVec = wVec./sum(wVec);
% weights = repmat(reshape(wVec,1,1,[]),[size(thirdsSegment,1) size(thirdsSegment,2) 1]);
% 
% t2 = sum(weights.*thirdsSegment,3);
% figure;imagesc(t2);axis image;

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