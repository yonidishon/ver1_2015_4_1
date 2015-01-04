function [objHeatMap,boxes]=computeObjectnessmap(im,numberSamples)
%Created: Yonatan Dishon 31/12/2014
%         Wrapper function for the runObjectness and
%         computeObjectnessHeatMap functions

%INPUT
%img - input image
%numberSamples - number of windows sampled from the objectness measure
%params - struct containing parameters of the function (loaded in startup.m

%OUTPUT
% objHeatMap - probability map size(im) of objectness measure
% boxes - the bounding boxes of the objects in the image 
%         Format: [xmin ymin xmax ymax score] - score - higher is better.          

%tic;
% imgExample = imread('002053.jpg');
boxes = runObjectness(im,numberSamples);
%toc
%figure,imshow(imgExample),drawBoxes(boxes);
%figure;
objHeatMap = computeObjectnessHeatMap(im,boxes);
end