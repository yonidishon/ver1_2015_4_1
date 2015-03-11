function [responses,data_mat]=process_data_for_learner_nn(c_map,sp_map,mo_map,x_map,y_map,gaze_gt_strct)
% Function to arrange the data and responses to the learner. Created 20/2/2015 Yonatan Dishon.
% Inputs:
% - c_map - (mxn) Color importantcy map - output of PCA_Saliency
% - sp_map - (mxn) Spatial improtantcy map - output of PCA_Saliency
% - mo_map - (mxn) Motion importantcy map - output of PCA_Motion_Saliency
% - x_map - (mxn) distance of every pixel from the center (x_direction - i.e. width)
% - y_map - (mxn) distance of every pixel from the center (y_direction - i.e. height)
% - gaze_gt_strct - struct containing the GT gaze data for that frame -
%   the function translate it to gaze gaussianMap and then translate it to
%   the response vector.
% Outputs:
% - responses - a vector of the expected responses (numel)x1 where -
% numel=mxn
[m,n]=size(c_map);
[X,Y]=meshgrid(1:n,1:m);
gz.points = gaze_gt_strct.points{gaze_gt_strct.index};
gazePts = gz.points(~isnan(gz.points(:,1)), :);
%gazeGmap= points2GaussMap(gazePts', ones(1, size(gazePts, 1)), 0, [n, m], gaze_gt_strct.pointSigma);
if isempty(gazePts)
    gz.points = gaze_gt_strct.points{gaze_gt_strct.index-1};
    gazePts = gz.points(~isnan(gz.points(:,1)), :);
end
[IDX,D] = knnsearch([Y(:),X(:)],gazePts);
% Guassian weight for the corresponding distance
D_g=(1/gaze_gt_strct.pointSigma/sqrt(2*pi)).*exp((-(D./gaze_gt_strct.pointSigma).^2)./2);
D_g=D_g./max(D_g);
data_mat=[c_map(:),sp_map(:),mo_map(:),x_map(:),y_map(:)];
responses=D_g(:);
end
