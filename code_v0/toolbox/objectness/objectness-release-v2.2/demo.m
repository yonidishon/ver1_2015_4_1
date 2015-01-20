tic;
imgExample = imread('002053.jpg');
boxes = runObjectness(imgExample,10);
toc
figure,imshow(imgExample),drawBoxes(boxes);
%figure;
objHeatMap = computeObjectnessHeatMap(imgExample,boxes);