function [BB_neg,BB_pos]=patch_extract(h,fr,sz,gazepnts,gazesigma,numsamples,idx)
% This function gets a framedata contains frame cache and retrieve 
% 3. Calculate the peak of fixation point and retrieve a BB around it.
% 4. stores the BB in a BB_pos and stores an array of BB_neg
global stat
PATCHSZ=40;
BB_size = PATCHSZ;
HIGHTH=exp(-(2)^2/2);% distance of 1 sigma from maximum;
%LOWTH=exp(-(4)^2/2);% distance of 4 sigma from maximum;
fix_points = gazepnts;
if isempty(fix_points)
    BB_neg=[];
    BB_pos=[];
    return;
end

cmap = jet(256);
ncol = size(cmap, 1);
fix_points_sigma = gazesigma;
att_map=points2GaussMap(fix_points',ones(1,length(fix_points)),0,sz,fix_points_sigma);
rgbHM = ind2rgb(round(att_map * ncol), cmap);
alphaMap = 0.7 * repmat(att_map, [1 1 3]);
gim = rgb2gray(fr);
gim = imadjust(gim, [0; 1], [0.3 0.7]);
gf = repmat(gim, [1 1 3]);

fix_points_sigma = gazesigma;
att_map=points2GaussMap(fix_points',ones(1,length(fix_points)),0,sz,fix_points_sigma);
fim = rgbHM .* alphaMap + im2double(gf) .* (1-alphaMap);
% figure();imshow(att_map);
th_att_map=att_map>=HIGHTH;
% figure();imshow(th_att_map);
%BB_pos=regionprops(th_att_map,'BoundingBox');
area = extractfield(regionprops(th_att_map,'Area'),'Area');
if numel(area)>1
    [~,idx] = sort(area,'descend');
    cent = extractfield(regionprops(th_att_map,'Centroid'),'Centroid')';
    cent = reshape(cent,2,numel(idx))';
    cent = cent(idx(1),:);
else
    cent = extractfield(regionprops(th_att_map,'Centroid'),'Centroid');
end
cent = round((cent-1));
BB_pos = [max(cent(2)-BB_size/2,1),min(cent(2)+BB_size/2-1,size(th_att_map,1)),max(cent(1)-BB_size/2,1),min(cent(1)+BB_size/2-1,size(th_att_map,2))];
ffim = insertShape(fim,'Rectangle',[BB_pos(3),BB_pos(1),BB_pos(4)-BB_pos(3),BB_pos(2)-BB_pos(1)], 'LineWidth', 1);
ffim = insertShape(ffim,'Circle',[cent,2]);
imshow(imresize(ffim,[720,1080]));
title(sprintf('Frame#%d',idx));
% with converstion to OpenCv (start from 0) and (x,y) format; BB_pos = [x,y,x+width,y+height,center_x,center_y]
BB_pos=[ceil((BB_pos(1:2)))-1,(BB_pos(3:4)-1)];
BB_pos=[BB_pos([3,1,4,2]),cent];
uiwait(h);
if ((BB_pos(3)-BB_pos(1))<PATCHSZ-10 || (BB_pos(4)-BB_pos(2))<PATCHSZ-10) || stat
    BB_neg=[];
    BB_pos=[];
    return;
end

%BB_image = insertShape(framedata.image, 'Rectangle', [BB_pos(1:2),BB_pos(3:4)-BB_pos(1:2)], 'LineWidth', 5);
%BB_image = insertShape(BB_image, 'FilledCircle', [BB_pos(5:6),1], 'LineWidth', 1);
% h=imshow(BB_image);
% pause(0.5);
% close(gcf);

% Get negative examples
% Lets assume we have NUMOFPOS patches and we need to get also negative
% patches.

% Getting all the locations that are far from the 
%th_att_map_neg=att_map<LOWTH;
th_att_map_neg=att_map<HIGHTH; % TODO
% removing edges
th_att_map_neg([1:PATCHSZ/2,sz(2)-PATCHSZ/2+1:sz(2)],:)=0;
th_att_map_neg(:,[1:PATCHSZ/2,sz(1)-PATCHSZ/2+1:sz(1)])=0;
% h=imshow(framedata.image);
% set(h, 'AlphaData', th_att_map_neg);
% pause(0.5);
% close(gcf);
rndind=randperm(sum(double(th_att_map_neg(:))));
rndind=rndind(1:numsamples);
neg_smaples=find(th_att_map_neg(:));
[neg_y,neg_x]=ind2sub(flip(sz),neg_smaples(rndind));
% with converstion to OpenCv (start from 0) and (x,y) format;
neg_subs=[neg_x,neg_y]-PATCHSZ/2; 
BB_neg=[neg_subs,neg_subs+PATCHSZ];
% check that the size of the positive BBs is enough
