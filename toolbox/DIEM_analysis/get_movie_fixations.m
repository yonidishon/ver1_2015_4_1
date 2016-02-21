%
clear all;close all;clc
DataRoot = '\\cgm10\D\DIEM';
gazeDataRoot = fullfile(DataRoot, 'gaze');
videos=importdata(fullfile(DataRoot, 'list.txt'));
%% Showing Mean fixation points over all videos
sum_gaze = zeros(144,256);
for ii = 1:length(videos)
    s = load(fullfile(gazeDataRoot, sprintf('%s.mat', videos{ii})));
    gazeData = s.data;
    gazeData_re = imresize(gazeData.binaryMaps,[144,256]);
    sum_gaze = sum_gaze + sum(gazeData_re,3)./size(gazeData_re,3);
    imagesc(sum_gaze)
    drawnow
    pause(1)
    fprintf('Finished iteration# %i/%i  %s\n',ii,length(videos),datestr(datetime('now')));
end
%% Showing mean fixation over all frames ineach movie
for ii = 1:length(videos)
    s = load(fullfile(gazeDataRoot, sprintf('%s.mat', videos{ii})));
    gazeData = s.data;
    %gazeData_re = imresize(gazeData.binaryMaps,[144,256]);
    gazeData_re = gazeData.binaryMaps;
    %sum_gaze = sum_gaze + sum(gazeData_re,3)./size(gazeData_re,3);
    sum_gaze = sum(gazeData_re,3)./size(gazeData_re,3);
    figure('Name',sprintf('vid#%i : %s',ii,videos{ii}));
    imagesc(sum_gaze)
    drawnow
    pause(1)
    fprintf('Finished iteration# %i/%i  %s\n',ii,length(videos),datestr(datetime('now')));
end