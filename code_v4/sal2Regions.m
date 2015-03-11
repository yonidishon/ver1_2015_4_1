function regPOImap = sal2Regions(globalCueMap,conductLUT,lMap,neighborColorDiff)

regPOImap = zeros(size(globalCueMap));

S = regionprops(lMap,globalCueMap,'MeanIntensity','Area');
regGlobCues = [S.MeanIntensity];
regGlobCues(end+1)=0;
rArea = [S.Area 2*sum(size(lMap))];
rArea = repmat(rArea',1,length(rArea));
rArea(isinf(conductLUT)) = NaN;
rAreaNormVal = nansum(rArea,1);
clear S;

regColorCue = colorCueAssociation(neighborColorDiff,regGlobCues);

% cSalMap  = zeros(size(lMap));
% for regionIdx = 1:numel(regColorCue)
%     cSalMap(lMap==regionIdx)= regGlobCues(regionIdx);
% end
% figure;imagesc(cSalMap);axis image;colormap(hot);


regCues = max(regGlobCues,0.5*(regGlobCues+regColorCue));

regCuesTmp=regCues;
[segA segB] = meshgrid(1:numel(regCues),1:numel(regCues));
maxStep = inf;
itt=0;
while maxStep>0.01 && itt<150
    diffuseLUT = (conductLUT.*regCuesTmp(segA) + (1-conductLUT).*regCuesTmp(segB));
    regCues = nansum(diffuseLUT.*rArea,1)./rAreaNormVal;
    regCues(end) = 0;
    maxStep = max(max(abs(regCues-regCuesTmp)));
    regCuesTmp=regCues;
    itt = itt+1;
%     fprintf('Itt:%i\n',itt);
end

for regionIdx = 1:numel(regCues)
    regPOImap(lMap==regionIdx)= regCues(regionIdx);
end
regPOImap = stableNormalize(regPOImap,true);
% figure;imagesc(regPOImap);axis image;colormap(hot);

end


function regColorCue = colorCueAssociation(neighborColorDiff,regCues)
%Assign color difference to more important region of the two
regColorCue = nan(size(neighborColorDiff));
[segA segB] = find(~isnan(neighborColorDiff));
for segIdx = 1:numel(segA)
    currDiff = neighborColorDiff(segA,segB);
    if (regCues(segA)>regCues(segB))
        regColorCue(segA,segB) = currDiff;
    else
        regColorCue(segB,segA) = currDiff;
    end
end
regColorCue = nanmean(regColorCue);
regColorCue(isnan(regColorCue))=0;
end