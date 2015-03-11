function [cols rows] =  saliencyValueIndicator(saliencyMap)
    colSort = sort(saliencyMap,1,'descend'); %sort each column
    rowSort = sort(saliencyMap,2,'descend'); %sort each row
    colSampleNum = ceil(size(saliencyMap,1)/40);
    rowSampleNum =ceil(size(saliencyMap,2)/40);
    cols = mean(colSort(1:colSampleNum,:),1);
    rows = mean(rowSort(:,1:rowSampleNum),2);
end