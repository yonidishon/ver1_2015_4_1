function [ output_args ] = myfitgmm( heatmap ) %TODO NOT TESTDED AND NOT DONE CODING
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
[X,Y] = meshgrid(1:size(heatmap,2),1:size(heatmap,1));
%reshape(pdf(gmdistribution(C,[300 300],Cw), [X(:) Y(:)]),size(heatmap));
count = round(heatmap(:).*100);
gmminput = cell(numel(count),1);
for jj = 1:numel(count)
 gmminput{jj}= repmat([X(jj),Y(jj)],count(jj),1);
end
gmminput = cell2mat(gmminput);
GMModel = fitgmdist(gmminput,5);


end

