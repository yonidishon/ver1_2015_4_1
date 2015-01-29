

function target = template_update(I,M,target0)

T = imcrop(I,target0);

target.T = double(T);
target.lastT = double(T);
[Sy,Sx,Sf] = size(target.T);

target.imX = size(I,2);
target.imY = size(I,1);

% Set initial warp (as translation only)
target.p = [0,0,0,0,target0(1),target0(2)]';

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
