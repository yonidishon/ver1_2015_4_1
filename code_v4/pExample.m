clear all;
close all;
if (~exist('VL_SLIC.m','file'))
    oldFolder = cd('vlfeat-0.9.14\toolbox\');
    vl_setup();
    cd(oldFolder);
end


I=imread('Z:\Documents\Dropbox\Study\Doctorate\Publications\Saliency\images\pattern\cham.jpg');
I = imresize(I,1/2);
I = repmat(rgb2gray(I), [1 1 3] );
figure;imshow(I);
imwrite(I,'cham.png','png');


[sDiffMap sAllMap out C] = testDiff(I);
lng= size(out,1);

figure;imagesc(sDiffMap);axis image;colormap(gray)
figure;imagesc(s);axis image; colormap(gray)
sD = ind2rgb(round(sDiffMap*255)+1,jet(256));
sD2 = ind2rgb(round(s*255)+1,jet(256));

imwrite(sD,'pcaJ.png','png');
imwrite(sD2,'patchJ.png','png');

iMap = zeros(size(sDiffMap));
iMap(23:27,48:52)=1;
iMap(40:43,23:27)=1;
imwrite(iMap,'map.png','png');

Cjet= jet(256);
Cs = 1+round(sDiffMap*255);
Ca = 1+round(s*255);
Cs=Cs(:);
Ca=Ca(:);

%%
markedImage = I;
iMap = zeros(size(sDiffMap));
% y = [23,27];
% x = [48,52];
y = [32,34];
x = [63,66];

iMap(y(1):y(2),x(1):x(2))=1;
[X Y] = meshgrid(x(1):x(2),y(1):y(2));
iIn = sub2ind(size(sDiffMap),Y,X);

[X Y] = meshgrid((x(1)-2):(2+x(2)),(y(1)-2):(2+y(2)));
iALL = sub2ind(size(sDiffMap),Y,X);
d = setdiff(iALL(:), iIn(:));
for ind=1:numel(d)
    [r c] = ind2sub(size(sDiffMap),d(ind));
    for cid=1:3
        markedImage(r,c,cid) = round(Cjet(end,cid)*255);
    end
end


inds = find(iMap);
% figure;imshow(iMap);
Cc = repmat(Cjet(1,:),[lng,1]);
for cid=1:3
    Cc(inds,cid) = Cjet(end,cid);
end
iMap = zeros(size(sDiffMap));
% y = [40,43];
% x = [23,27];
y = [40,42];
x = [7,9];
iMap(y(1):y(2),x(1):x(2))=1;
[X Y] = meshgrid(x(1):x(2),y(1):y(2));
iIn = sub2ind(size(sDiffMap),Y,X);

[X Y] = meshgrid((x(1)-2):(2+x(2)),(y(1)-2):(2+y(2)));
iALL = sub2ind(size(sDiffMap),Y,X);
d = setdiff(iALL(:), iIn(:));
for ind=1:numel(d)
    [r c] = ind2sub(size(sDiffMap),d(ind));
    for cid=1:3
        markedImage(r,c,cid) = round(Cjet(160,cid)*255);
    end
end
imwrite(markedImage,'marked.png','png');
figure;imshow(markedImage);
inds2 = find(iMap);

for cid=1:3
    Cc(inds2,cid) = Cjet(160,cid);
end

inds = [inds ; inds2];
sz = 6*ones(lng,1);
sz(inds)=60;
d = setdiff(1:lng, inds);
outt = [out(d,:) ; out(inds,:)];
sz = [sz(d,:) ; sz(inds,:)];
Cs = [Cs(d,:) ; Cs(inds,:)];
Ca = [Ca(d,:) ; Ca(inds,:)];
Cc = [Cc(d,:) ; Cc(inds,:)];
% close all;
% for f=2:9
% h=figure;scatter(outt(:,1),outt(:,2),sz,Cc,'filled');
% end
% print(h,'-dpng','scatter.png');
%%

% figure;scatter(outt(:,1),outt(:,2),sz,Cc,'filled');
