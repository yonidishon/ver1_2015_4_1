%% ===================================================================
% Get a list of all PNG, BMP or JPG frames in input directory
% 
% [files] = getFrameList
% 
% Input :
%   global prm - Run parameter struct (for info see 'loadDefaultprms.m')             
% 
% Output:
%   files - List of frames
% 
% Writen by: Shaul Oron
% Last update: 17/07/2011
% Debuged on: Matlab 7.11.0 (R2010b)
%
% shauloron@gmail.com
% Computer Vision & Image Processing Lab
% School of Electrical Engineering, Tel-Aviv University, Israel
% ===================================================================

function [files] = getFrameList(inputDir)

files = dir(fullfile(inputDir,'*.png'));
if isempty(files)
        files = dir(fullfile(inputDir,'*.jpg'));
end
if isempty(files)
        files = dir(fullfile(inputDir,'*.jpeg'));
end
if isempty(files)
        files = dir(fullfile(inputDir,'*.bmp'));
end
if isempty(files)
        error('No PNG, BMP or JPG files found at specified directory!')
end