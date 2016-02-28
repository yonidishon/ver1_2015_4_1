function [ chi_dist ] = mychisquare( heatmap1,heatmap2 )
% mychisquare 
% simple func to calculate the chi-square dist between two heatmaps.
% YD: in my case between prediction map and a uniform map
% inputs:
% heatmap1,heatmap2 two MxN maps
% outputs:
% chi_dist - the chi-square distance between heatmap1 and heatmap2
p1 = heatmap1(:) / sum(heatmap1(:));
p2 = heatmap2(:) / sum(heatmap2(:));
chi_dist = sum((p1 - p2) .^ 2 ./ (p1 + p2+eps)) ./ 2;
end

