function normVmap = stableZero(valueMap)
    %Normalize localFeatures for global feature use
    sortVMap = sort(valueMap(:),'ascend');
    minValue = mean(sortVMap(1:round(numel(sortVMap)*.01)));
    normVmap = valueMap-minValue;
    normVmap(normVmap<0)=0;
end