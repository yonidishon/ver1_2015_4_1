function valueMap = stableNormalize(valueMap)
%Normalize localFeatures for global feature use
% if (~exist('stableMin','var'))
%     stableMin = false;
% end
% 
% if (stableMin)
%     sortVMap = sort(valueMap(:),'ascend');
%     minValue = mean(sortVMap(1:max(round(numel(sortVMap)*.01),1)));
%     valueMap = valueMap-minValue;
%     valueMap(valueMap<0)=0;
% end
    sortVMap = sort(valueMap(:),'descend');
    sortVMap(isnan(sortVMap))=[];
    valueMap = valueMap./mean(sortVMap(1:max(round(numel(sortVMap)*.01),1)));
    valueMap(valueMap>1)=1;
% end