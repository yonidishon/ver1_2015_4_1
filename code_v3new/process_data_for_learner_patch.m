function [responses,data_mat]=process_data_for_learner_patch(sp_map,mo_map,gaze_gt_strct,GT_FORM,PatchSz)
% TODOYD - if it should be general to general number of feature maps need
% to change this
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
[m,n]=size(sp_map);
gz.points = gaze_gt_strct.points{gaze_gt_strct.index};
gazePts = gz.points(~isnan(gz.points(:,1)), :);
if isempty(gazePts)
    responses=[];
    data_mat=[];
    return
end

if strcmp(GT_FORM,'cluster')
    gazeGmap= points2GaussMap(gazePts', ones(1, size(gazePts, 1)), 0, [n, m], gaze_gt_strct.pointSigma);
else
    [X,Y]=meshgrid(1:n,1:m);
    [~,D] = knnsearch(gazePts,[Y(:),X(:)]);
    % Guassian weight for the corresponding distance
    gazeGmap=exp((-(D./gaze_gt_strct.pointSigma).^2)./2);
end
if PatchSz == 1
    Mpatches = mo_map(:);
    Spatches = sp_map(:);
else
    Mpatches = im2colstep(mo_map,[PatchSz PatchSz])';
    Spatches = im2colstep(sp_map,[PatchSz PatchSz])';
end
data_mat=[Spatches,Mpatches];
responses=gazeGmap(:);


end
