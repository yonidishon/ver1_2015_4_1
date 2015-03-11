function normVmap = stableMin(valueMap)
    %Normalize localFeatures for global feature use
    sortVMap = sort(valueMap(:),'ascend');
    maxValue = mean(sortVMap(1:round(numel(sortVMap)*.01)));
    normVmap = valueMap./maxValue;
    normVmap(normVmap>1)=1;
end