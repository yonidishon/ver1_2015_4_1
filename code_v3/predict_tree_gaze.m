function [gt_maps,pred_maps]=predict_tree_gaze(tree,trainset,data_folder,movie_name,frsize,numfr)
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
%   - gt_maps - the Ground Truth gaze responses from the saved results
%   - pred_maps - the predicted gaze maps according to the features and
%       regression function learned by the ansembled of trees.
    if any(ismember(trainset,movie_name))
        error('Movie belong to the training set!');
    end
    %[gt_maps,data]=load_train_set(data_folder,movie_name);
    [gt_maps,data]=load_train_set_feat_pred1(data_folder,movie_name);
    pred_vec=predict(tree,cell2mat(data));
    pred_maps=reshape(pred_vec,[frsize,numfr]);
    gt_maps=reshape(cell2mat(gt_maps),[frsize,numfr]);
end