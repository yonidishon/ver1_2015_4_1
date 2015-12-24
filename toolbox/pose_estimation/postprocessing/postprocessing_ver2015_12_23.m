function [] = postprocessing_ver2015_12_23( src_fold,dst_fold )
%postprocessing_ver2015_12_23 Post processing for the tree pose_estimation
%   This post processing is done in order to filter out the noise of the
%   prediction and increase the performance regardingg the two metrics we
%   are using (chi-square,AUC). 
% The function is to run from the command-line (hopefully under a
% PowerShell enviroment to enable multiple computers.
% The post processing is defined in Trello card : https://trello.com/c/GlR1u2vR 
%               (Post Processing : implement The Test you discussed with Osherov)
% Inputs:
% src_fold : String - the folder (fullpath) the the whole movie prediction lies in 
% dst_fold : String - destination folder (fullpath) for the filter prediction maps (input for
%            the estimation)
% Outputs:
% None - maybe some prints for debugging.

%% Argument checking
if(exist(src_fold,'file') ~= 7) % src_fold doesn't exist
    error('Post:: %s isn''t a directory',src_fold);
end

if(exist(dst_fold,'file') ~= 7) % dst_fold doesn't exist
    fprintf('Post:: %s isn''t folder exists - creating',dst_fold);
    status = mkdir(dst_fold); % creating dst_fold
    if ~status
        error('Post:: Failed to create %s',dst_fold);
    end
end

%% Getting list of all the files in the src_fold (should be .png files)
files = dir(fullfile(src_fold,'*.png'));
files = extractfield(files,'name')';

%% For each of the predictions images

for ii = 1: length(files)
    im = im2double(imread(fullfile(src_fold,files{ii})));
    % 1. Check the prediction total energy signiture (gives an estimate on the
    %    compactness of the prediction
    
    
end
end
    



