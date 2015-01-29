%% ===================================================================
% Set initial target position as defined in prm or from user
% 
% [target,T] = setInitialTargetPosition(I)
% 
% Input :
%   I - Initial frame
%   global prm - Run parameter struct (for info see 'loadDefaultprms.m')             
% 
% Output:
%   target - target struct
%       .T - Target patch
%       .p - Initial warp params
%       .verticesIn - Vertices of target BB in target coordinate system
%       .xyT - Target coords
%       .xyTI - Traget coords warped to Image
%       .verticesOut - Vertices of target BB in image coordinate system
%   T - Target patch
% 
% Writen by: Shaul Oron
% Last update: 17/07/2011
% Debuged on: Matlab 7.11.0 (R2010b)
%
% shauloron@gmail.com
% Computer Vision & Image Processing Lab
% School of Electrical Engineering, Tel-Aviv University, Israel
% ===================================================================

function target = init_target(I,target0, T)
% If only 2 arguments are given, the template is set to rectangle target0
% of image I
% If also T is given, the template is set to T and its position to th
% rectangle target0.

if ~exist('T','var') || isempty(T)
    T = imcrop(I,target0);
end
target.T = double(T);
[Sy,Sx,Sf] = size(target.T);

target.imX = size(I,2);
target.imY = size(I,1);

% Set initial warp (as translation only)
target.p = [0,0,0,0,target0(1)-1,target0(2)-1]';

% Set vertices of target BB (target coords.)
target.verticesIn = [ 1, Sx, Sx, 1 ; 1, 1, Sy, Sy ; 1, 1, 1, 1];    
 
% Set template coordinates
[xx,yy] = meshgrid(1:Sx,1:Sy);
target.xyT = [xx(:),yy(:),ones(numel(xx),1)]';

% convert to Image coords.
W = setWarp(target.p);
xyTI = W*target.xyT;
target.xyTI = bsxfun(@rdivide,xyTI,xyTI(3,:));

% Find target vertices in image coords. 
target.verticesOut = W*target.verticesIn;
target.verticesOut = bsxfun(@rdivide,target.verticesOut,target.verticesOut(3,:));