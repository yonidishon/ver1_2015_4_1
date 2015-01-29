% =================================================================================
% Create transformation matrix (3x3) using warp parameters p
% 
% [W] = setWarp(p)
%
% Input:
%   p - Warp parameters 
%
% Output:
%   W - 3x3 transformation matrix
%
% Writen by: Shaul Oron
% Last update: 17/07/2011
% Debuged on: Matlab 7.11.0 (R2010b)
%
% shauloron@gmail.com
% Computer Vision & Image Processing Lab
% School of Electrical Engineering, Tel-Aviv University, Israel
% =================================================================================

function [W] = setWarp(p)

W = [ 1+p(1) ,  p(3)  , p(5)  ; ...
      p(2)   , 1+p(4) , p(6)  ;...
      0      ,  0     ,  1     ];