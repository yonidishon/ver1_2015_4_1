function [BB_neg,BB_pos]=patch_extract_visualization(sz,gazepnts,gazesigma)
% This function gets a framedata contains frame cache and retrieve 
% 3. Calculate the peak of fixation point and retrieve a BB around it.
% 4. stores the BB in a BB_pos and stores an array of BB_neg

HIGHTH=exp(-(2)^2/2);% distance of 2 sigma from maximum;
LOWTH=exp(-(4)^2/2);% distance of 4 sigma from maximum;
fix_points = gazepnts;
if isempty(fix_points)
    BB_neg=[];
    BB_pos=[];
    return;
end
fix_points_sigma = gazesigma;
att_map=points2GaussMap(fix_points',ones(1,length(fix_points)),0,sz,fix_points_sigma);
% figure();imshow(att_map);
th_att_map=att_map>=HIGHTH;
% figure();imshow(th_att_map);
BB_pos=regionprops(th_att_map,'BoundingBox');
if size(BB_pos,1)>1;
    BB_neg=[];
    BB_pos=[];
    return;
end
BB_pos=BB_pos.BoundingBox;




% Getting all the locations that are far from the 
th_att_map_neg=att_map>LOWTH;
BB_neg=regionprops(th_att_map_neg,'BoundingBox');
BB_neg=BB_neg.BoundingBox;

