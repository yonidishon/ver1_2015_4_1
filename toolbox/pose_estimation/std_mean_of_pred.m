function [mu_vec,std_vec]=std_mean_of_pred(pred_map,gt_pt)
% pred_map - image double of the prediction map [0,1]
% gt_pt - the center of the BB in the GT
% mu_vec - the mu vector of the prediction
% std_vec - the std vector of the prediction
non_neg = pred_map > 0;
[X,Y]=ind2sub(size(non_neg),find(non_neg));
std_vec = std([X,Y],pred_map(non_neg));
mu_vec = sum(bsxfun(@times,[X,Y],pred_map(non_neg)))./sum(pred_map(non_neg));
fprintf('Std is %s ,Mu diff is %s\n',mat2str(std_vec),mat2str(abs(mu_vec-gt_pt)));
end