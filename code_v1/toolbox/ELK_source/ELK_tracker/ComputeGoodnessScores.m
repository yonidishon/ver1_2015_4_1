function [combined_err_est, Tfg_perc, Tout_fg]  = ...
    ComputeGoodnessScores( Tout, target, prm , classifier )

[pr_Tout_fg,pr_Tout_bg,~] = FG_BG_model(Tout,'test',prm.fgbg,[],classifier,[]);    % compute Tout likelihood map
Tout_fg = pr_Tout_fg./(pr_Tout_bg+pr_Tout_fg);
combined_err_est = sqrt(sum(sum(Tout_fg.*sum((target.T-Tout).^2,3)))/sum(Tout_fg(:)))/255; % weighted
combined_err_est = combined_err_est/mean(Tout_fg(:));
tmp = Tout_fg(4:end-4,4:end-4);
Tout_fg_sort = sort(tmp(:));
Tout_fg_perc = Tout_fg_sort(round((0.1:0.1:0.9)*numel(Tout_fg_sort)));
Tfg_perc = Tout_fg_perc(prm.w_percentile);


