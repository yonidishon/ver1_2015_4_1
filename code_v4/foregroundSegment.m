function fSeg = foregroundSegment(localCueMap,regPOImap,I_LAB,lMap,regColor,mShiftLines)

% figure;imagesc(I_LAB(:,:,3));axis image;colormap(hot);
LABvec = reshape(I_LAB,[numel(localCueMap) 3]);
thValues = unique(regPOImap(:))';
% figure;plot(thValues);

thValues(thValues<0.05)=[];
if numel(thValues)>30
    thValues = thValues(round(linspace(1,numel(thValues),30)));
    fprintf('\nQuantizing thresholds\n');
end
% figure;plot(1:numel(thValues),thValues);
% % figure;plot(1:numel(thValues),segScore'+lowSTD);
% diffVec = [0 ;(diff(thValues'))];
% figure;plot(1:numel(thValues),diffVec);
% 
% [pks,locs] = findpeaks(diffVec);
% figure;plot(diffVec);

% cLoc = locs(diffVec(locs) == max(diffVec(locs)));


% thValues(thValues<=0.05) = [];
% thValues(1)=[];
% totalLocalResult = sum(localCueMap(:));
% [segScore lowSTD dd] = deal(zeros(numel(thValues),1));
% prevBG = zeros(size(regPOImap));
matchCost = zeros(numel(thValues),1);
for thIdx = 1:numel(thValues)
    th = thValues((thIdx));
    fgLabel = bwlabel(regPOImap>=th);
%         figure;imagesc(fgLabel);axis image;

    ObjPx = regionprops(fgLabel,'PixelIdxList');
    numOfFGObjects=length(ObjPx);
    mObj = zeros(numOfFGObjects,3);
    for fgObject=1:numOfFGObjects
        pxIdx = ObjPx(fgObject).PixelIdxList;
        mObj(fgObject,:) = (mean(LABvec(pxIdx,:)));
    end
    bgIdx = find(fgLabel==0);
    mObj(end+1,:) = (mean(LABvec(bgIdx,:)));
    [~,I] = pdist2(mObj,regColor,'euclidean','Smallest',1);
    I(I==numOfFGObjects+1)=0;
    Imap = zeros(size(lMap));
    for regIdx=1:size(regColor,1)
        Imap(lMap==regIdx) = I(regIdx);
    end
%     figure;imagesc(Imap);axis image;

    matchScore = zeros(numOfFGObjects,numOfFGObjects+1);
    numOfPixels=numel(fgLabel);
    objAreaR = sum(sum(fgLabel>0))./numOfPixels;

    for fgObject=1:numOfFGObjects
        objMap = fgLabel==fgObject;
        for sgObject=0:numOfFGObjects
            [hitRate , falseAlarm] = hitRates(Imap==sgObject,objMap);
            matchScore(fgObject,sgObject+1) = objAreaR+hitRate/(falseAlarm+0.1);
        end
    end
    possiblePaths = (1:size(matchScore,2));
    P = perms(possiblePaths)';
    P(end,:)= [] ;
    [~, Y] = meshgrid(1:size(P,2),1:size(P,1));
    indx = sub2ind(size(matchScore),Y,P);
    matchCosts = mean(matchScore(indx),1);
    [matchCost(thIdx),ind] = max(matchCosts);
    nobj(thIdx) = numOfFGObjects;
end
% figure;plot(thValues);


[~,cTH] = max(matchCost);
% adValues = matchCost'./nobj;
% figure;plot(1:numel(thValues),matchCost');hold on;
% plot(cTH,matchCost(cTH),'*r'); hold off;
% title('org');

% figure;plot(1:numel(thValues),adValues);hold on;
% plot(cTH,adValues(cTH),'*r'); hold off;
% title('adValues');

% figure;plot(1:numel(thValues),nobj);
% 
fSeg = regPOImap>=thValues(cTH);
% figure;imagesc(fSeg);axis image;colormap(hot);
% debug=3;
%     bgDiffIndx = find(bgDiff);
%     bgOldIndx = find(prevBG);
%     fgColors = LABvec(fgIndx,:);
%     bgColors = LABvec(bgIndx,:);
%     bgNewColors = LABvec(bgDiffIndx,:);
%     bgOldColors = mean(LABvec(bgOldIndx,:));
%     if (isnan(bgOldColors))
%         dd(thIdx)=0;
%     else
%         dd(thIdx) = mean(mean(abs(pdist2(bgOldColors,bgNewColors))));
%     end
%     prevBG = bgMap;
%     fgSTD = mean(fgColors);
%     bgSTD = mean(bgColors);
%     
%     lowSTD(thIdx) = max(abs(fgSTD-bgSTD));
%     
%     fgArea = mean(localCueMap(logical(fgMap)));
%     fgEdge = bwmorph(fgMap,'remove') | bwmorph(bgMap,'remove');
%     
%     segScore(thIdx) = fgArea + mean(localCueMap(fgEdge));
%   
% end
% figure;imagesc(regPOImap);axis image;colormap(hot);

end

function [hitRate , falseAlarm] = hitRates(testMap,gtMap)
neg_gtMap = ~gtMap;
neg_testMap = ~testMap;

hitCount = sum(sum(testMap.*gtMap));
trueAvoidCount = sum(sum(neg_testMap.*neg_gtMap));
missCount = sum(sum(testMap.*neg_gtMap));
falseAvoidCount = sum(sum(neg_testMap.*gtMap));

falseAlarm = 1 - trueAvoidCount / (trueAvoidCount + missCount);

hitRate = hitCount / (hitCount + falseAvoidCount);
end
