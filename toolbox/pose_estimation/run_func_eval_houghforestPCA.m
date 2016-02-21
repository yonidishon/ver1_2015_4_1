% run the func_eval_houghforest on the PCA channels.
%clear all;close all;clc

channels = {'PCAm','PCAs'};
pred_folder = 'DIEMPCApng';

for ii = 2:length(channels)
    func_eval_houghforest_PCA(pred_folder,channels{ii});
    fprintf('=========================================================================\n');
    fprintf('Finished Processing Method %s  at %s\n',channels{ii},datestr(datetime('now')));
    fprintf('=========================================================================\n');
end