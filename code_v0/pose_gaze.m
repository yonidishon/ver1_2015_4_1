function [map]=pose_gaze(poselets,im_size)
% face_gaze gets faces detection and im_size and return an estimation of
% the gaze on the face detections
bbpose=poselets.bounds';
bbpose=[bbpose(:,1),bbpose(:,2),bbpose(:,1)+bbpose(:,3),bbpose(:,2)+bbpose(:,4)];
posesconf=poselets.score;
confthresh=3;
indsel=find(posesconf>confthresh);
if isempty(indsel)
    map=zeros(im_size);
    return;
end
[nmsbbox,nmsconf]=prunebboxes(bbpose(indsel,:),posesconf(indsel),0.2);
% Cropping the poselets to the half middle of the poselets and the top 3rd
% of the Bounding box
bb_width=abs(nmsbbox(:,1)-nmsbbox(:,3));
bb_height=abs(nmsbbox(:,2)-nmsbbox(:,4));
cropped_box=[nmsbbox(:,1)+bb_width./4,nmsbbox(:,2),nmsbbox(:,3)-bb_width./4,nmsbbox(:,4)-(2/3).*bb_height];
[X,Y] = meshgrid(1:im_size(2),1:im_size(1));
map=zeros(im_size);
% transforming the selected bb to gaussian friendly format center width and
% height
bb_g=[(cropped_box(:,1)+cropped_box(:,3))/2,(cropped_box(:,2)+cropped_box(:,4))/2,...
    abs((cropped_box(:,1)-cropped_box(:,3))),abs((cropped_box(:,2)-cropped_box(:,4)))];
for ii=1:size(cropped_box,1)
    if bb_g(ii,3)*bb_g(ii,4)<20^2 % face is too small ->false positive
        continue;
    elseif bb_g(ii,3)*bb_g(ii,4)<50^2
        rat=sqrt(50^2/bb_g(ii,3)*bb_g(ii,4));
        bb_g(ii,3)=rat*bb_g(ii,3);bb_g(ii,4)=rat*bb_g(ii,4);
    end
    map=map+nmsconf(ii).*exp(-((X - bb_g(ii,1)).^2/2/(bb_g(ii,3)/6)^2 + (Y - bb_g(ii,2)).^2/2/(bb_g(ii,4)/6)^2));
end
map=map./max(map(:));
end

