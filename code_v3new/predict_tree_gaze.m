function [pred_maps]=predict_tree_gaze(tree,trainset,data_folder,movie_name,frsize,numfr,offset)
global GENERALPARAMS
% Function predict_gaze to predict the gaze in a movie based on tree learned on trainset. Created 24/2/2015 Yonatan Dishon.
%
% Input:
%   - tree - the learned tree ansamble - in compact format.
%   - trainset - name of movies used for training set.
%   - data_folder - the folder where the feature maps and responses are
%       saved in
%   - movie_name - name of the movie from the DIEM dataset (needs to be
%       saved and precalculated in the data_folder.
%   - frsize - the size of frame [m,n] in the movie_name movie.
%   - numfr - number of frames to predict - going in accodense to
%       what Dmitry did in his testing [frame#30,videolen-30]
%
% Output:
%   - gt_maps - the Ground Truh gaze responses from the saved results
%   - pred_maps - the predicted gaze maps according to the features and
%       regression function learned by the ansembled of trees.
    if any(ismember(trainset,movie_name))
        error('Movie belong to the training set!');
    end
    files=dir(fullfile(data_folder,movie_name,'\*.mat'));
    pred_maps=zeros(frsize(1),frsize(2),numfr);
    halfPt=floor(GENERALPARAMS.PatchSz/2);
    % TODOYD - need to decied how I take it in future releases to correlate
    % between the frame number here and training
    %for jj=offset:numfr+offset
    for jj=1:numfr
        filedata=load(fullfile(data_folder,movie_name,files(jj).name));
        %pred_maps(halfPt+1:end-halfPt,halfPt+1:end-halfPt,1+jj-offset)=reshape(predict(tree,filedata.data)...
        %   ,frsize(1)-GENERALPARAMS.PatchSz+1,frsize(2)-GENERALPARAMS.PatchSz+1);
         pred_maps(halfPt+1:end-halfPt,halfPt+1:end-halfPt,jj)=reshape(predict(tree,filedata.data)...
           ,frsize(1)-GENERALPARAMS.PatchSz+1,frsize(2)-GENERALPARAMS.PatchSz+1);
    end
end