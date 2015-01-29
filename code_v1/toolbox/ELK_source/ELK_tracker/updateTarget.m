%% =================================================================================
% Update target stracture based on LK results
% 
% [target] = updateTarget(target,p)
%
% Input:
%   target - Current target structure
%   p - New warp parameters
%   
% Output:
%   target - Updated target structure
%
% Writen by: Shaul Oron
% Last update: 17/07/2011
% Debuged on: Matlab 7.11.0 (R2010b)
%
% shauloron@gmail.com
% Computer Vision & Image Processing Lab
% School of Electrical Engineering, Tel-Aviv University, Israel
% ===================================================================================

function [target] = updateTarget(target,p)

% Get observation
target.p_prev = target.p;
target.p = p;
W = setWarp(target.p);
target.verticesOut = W*target.verticesIn;
target.verticesOut = bsxfun(@rdivide,target.verticesOut,target.verticesOut(3,:));

% Verify we stay inside the image +-15 pixels (this is the tolerance in
% ELK_tracker_main, and that we do not get below patch size 8 in x and y
% (required for the bg_fg_model)
szt=size(target.T);
LocationCondition= (target.verticesOut(1,1)<-14 || target.verticesOut(1,2)>target.imX+14 || target.verticesOut(2,1)<-14 || target.verticesOut(2,3)>target.imY+14);
ScaleCondition= ( target.verticesOut(1,2)-target.verticesOut(1,1)<8 || target.verticesOut(2,3)-target.verticesOut(2,2)<8 );
if LocationCondition || ScaleCondition
    target.p = target.p_prev;
    W = setWarp(target.p);
    target.verticesOut = W*target.verticesIn;
    target.verticesOut = bsxfun(@rdivide,target.verticesOut,target.verticesOut(3,:));
end


% convert to final Image coords.
xyTI = W*target.xyT;
target.xyTI = bsxfun(@rdivide,xyTI,xyTI(3,:));
