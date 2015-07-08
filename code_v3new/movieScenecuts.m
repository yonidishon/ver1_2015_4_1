function cutFrames = movieScenecuts(videonm,videos,cuts)
%movieScenecuts
%Inputs:
%   videonm - str - name of the video
%   videos - cell array in each cell video names
%   cuts - cell array in each cell the frames of the cuts in the video
%Outputs:
%   cutFrames - a vector of frame indices that are the points in the clip
%               for changing scenes
cutFrames=cuts{strcmp(videonm,videos)};
if length(cutFrames)>110 % the cuts aren't real
    cutFrames=[];
end
end

