function croppedImage= cropImage(image,saliencyMap,th)

    [cols rows] =  saliencyValueIndicator(saliencyMap);
%     [colsL rowsL] =  saliencyValueIndicator(localEnergyMap);
    [lowEdgeR highEdgeR] = croppingEdges(rows,th);
    [lowEdgeC highEdgeC] = croppingEdges(cols,th);
    
    
    
    croppedImage = image(lowEdgeR:highEdgeR,lowEdgeC:highEdgeC,:);
    % figure;imshow(croppedImage);
    

end

function [cols rows] =  saliencyValueIndicator(saliencyMap)
    colSort = sort(saliencyMap,1,'descend'); %sort each column
    rowSort = sort(saliencyMap,2,'descend'); %sort each row
    colSampleNum = ceil(size(saliencyMap,1)/40);
    rowSampleNum =ceil(size(saliencyMap,2)/40);
    cols = mean(colSort(1:colSampleNum,:),1);
    rows = mean(rowSort(:,1:rowSampleNum),2);
end

function [lowEdge highEdge] = croppingEdges(dimMax,th)
G=fspecial('gaussian',11,5);
G=G(6,:);
G=G./sum(G);
sdimMax = filter(G,1,dimMax);
% LOWthLocal=max(th-.1,0); %0.1;
LOWth=th; %0.2;
MIDth=LOWth+.2;
HIGHth=0.7;
MidI =  crossing(dimMax,[],MIDth);
% figure(4);plot(local);hold on;
% figure(2);plot(dimMax);hold on;
% plot(MidI,dimMax(MidI),'ro');
% hold off;
% figure(3);plot(sdimMax);hold on;
legalPair=zeros(1,numel(MidI)-1);
for pairIdx=1:numel(MidI)-1
   l=MidI(pairIdx); 
   h=MidI(pairIdx+1);
   if ((h-l<10))
       continue;
   end
   mx = max(dimMax(l:h));
   if (mx>=HIGHth)
       legalPair(pairIdx)=1;
   end
end
lowThEdge = find(dimMax(1:MidI(find(legalPair,1,'first')))<=LOWth,1,'last');
if (isempty(lowThEdge))
    lowEdge=1;
    highEdge=numel(dimMax);
    return;
end
[valL,vallyIdxL] = findpeaks(1-sdimMax(1:MidI(find(legalPair,1,'first'))));
vallyIdxL(valL>(LOWth+0.05))=[];
if(isempty(vallyIdxL))
    vallyIdxL=-1;
end
lowEdge = max(lowThEdge,vallyIdxL(end));
rightBar=MidI(find(legalPair,1,'last')+1);
highThEdge = find(dimMax(rightBar:end)<=LOWth,1,'first');
[valH,vallyIdxH] = findpeaks(1-sdimMax((rightBar:end)));
vallyIdxH(valH>(LOWth+0.05))=[];
if(isempty(vallyIdxH))
    vallyIdxH=inf;
end
highEdge =rightBar-1+ min(highThEdge,vallyIdxH(1));

%Attempt to adujst according to local energies
% lowLocal = find(local(1:lowEdge)<=LOWthLocal,1,'last');
% if ((lowEdge-lowLocal) <=(numel(local)/5))
%     lowEdge=lowLocal;
% end
% 
% highLocal = find(local(highEdge:end)<=LOWthLocal,1,'first')-1;
% if (highLocal <=(numel(local)/5))
%     highEdge=highEdge + highLocal;
% end




end