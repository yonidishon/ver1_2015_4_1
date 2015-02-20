function [map]=face_gaze(faces,im_size)
% face_gaze gets faces detection and im_size and return an estimation of
% the gaze on the face detections
bbfaces=[faces(:,1),faces(:,2),faces(:,1)+faces(:,3),faces(:,2)+faces(:,4)];
facesconf=faces(6);
confthresh=0;
indsel=find(facesconf>confthresh);
if isempty(indsel)
    map=zeros(im_size);
    return;
end
[nmsbbox,nmsconf]=prunebboxes(bbfaces(indsel,:),facesconf(indsel),0.2);
[X,Y] = meshgrid(1:im_size(2),1:im_size(1));
map=zeros(im_size);
% transforming the selected bb to gaussian friendly format center width and
% height
bb_g=[(nmsbbox(:,1)+nmsbbox(:,3))/2,(nmsbbox(:,2)+nmsbbox(:,4))/2,...
    abs((nmsbbox(:,1)-nmsbbox(:,3))),abs((nmsbbox(:,2)-nmsbbox(:,4)))];
for ii=1:size(nmsbbox,1)
    %map=map+nmsconf(ii).*exp(-((X - bb_g(ii,1)).^2/2/(bb_g(ii,3)/6)^2 + (Y - bb_g(ii,2)).^2/2/(bb_g(ii,4)/6)^2));
    map=map+nmsconf(ii).*exp(-((X - bb_g(ii,1)).^2/2/(bb_g(ii,3)/3)^2 + (Y - bb_g(ii,2)).^2/2/(bb_g(ii,4)/3)^2));
end
map=map./max(map(:));
end
