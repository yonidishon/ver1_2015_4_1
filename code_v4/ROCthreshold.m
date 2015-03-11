function [mHitRate , mFalseAlarm] = ROCthreshold(GT,ALG_DIR)
%mHitRate & mFalseAlarm - Each column per algorithm
% percent_salient = [1, 3, 5, 10, 15, 20, 25, 30];
thresholds = 1:-.05:0;

numOfFiles = size(GT,3);
numOfAlgos = length(ALG_DIR);

[hitRate falseAlarm precision] = deal(zeros(numOfFiles,length(thresholds),numOfAlgos));
%Iterate over images
for imIndx=1:numOfFiles
   
    fprintf('Processing image %i out of %i\n',imIndx,numOfFiles);
 base_name = ['frame_' num2str(imIndx)];
    gtMap = GT(:,:,imIndx);
    
    gtSize = size(gtMap);
    if (length(gtSize) == 3)
        gtMap = rgb2gray(gtMap);
        gtSize(3)= [];
    end
%     gtMap = double(gtMap>0);
    numOfPixels = gtSize(1)*gtSize(2); % number of pixels
    %Calculate threshold of amount of pixels used for each percentile
    %Read & resize image from each algorithm
    
    for algIdx = 1:numOfAlgos
        sMap = readSaliencyMap(ALG_DIR(algIdx),base_name,gtSize);
        [hitRate(imIndx,:,algIdx) falseAlarm(imIndx,:,algIdx) precision(imIndx,:,algIdx)] = thresholdBased_HR_FR(sMap,thresholds,gtMap);
    end
    
end %End of image loop

%Average across images -
mHitRate = permute(mean(hitRate,1),[2 3 1]);
mFalseAlarm = permute(mean(falseAlarm,1),[2 3 1]);
% mPrecision = permute(mean(precision,1),[2 3 1]);
% beta= 0.3;
% Fmeasure = ((1+beta)*mPrecision.*mHitRate)./(eps+beta*mPrecision+mHitRate);
% FmeasureMEAN = mean(Fmeasure);
% FmeasureMAX = max(Fmeasure,[],1);
% FmeasureMAX = permute(mean(max(((1+beta)*precision.*hitRate)./(eps+beta*precision+hitRate),[],2),1),[2 3 1]);
% FmeasureMEAN = permute(mean(mean(((1+beta)*precision.*hitRate)./(eps+beta*precision+hitRate),2),1),[2 3 1]);
% for ind=1:5
% AP(ind) = trapz(mHitRate(:,ind),mPrecision(:,ind));
% end
 
end











function sMap = readSaliencyMap(cALG_DIR,base_name,gtSize)
file_name = fullfile(cALG_DIR.dir,[cALG_DIR.prefix base_name cALG_DIR.postfix '.' cALG_DIR.ext]);
% sMap = imresize(im2double(imread(file_name)),gtSize(1:2),'nearest');
sMap = imresize(im2double(imread(file_name)),gtSize(1:2));
% sMap = im2double(imread(file_name));
if (size(sMap,3)==3)
    sMap = rgb2gray(sMap);
end
sMap = sMap./max(sMap(:));
% sMap(sMap>1)=1;
sMap(sMap<0)=0;

end


function [hitRate falseAlarm precision] = thresholdBased_HR_FR(sMap,thresholds,gtMap)
numOfThreshs = length(thresholds);
[hitRate falseAlarm precision] = deal(zeros(1,numOfThreshs));
% figure;imshow(sMap);
% gMap = imresize(gtMap,size(sMap),'nearest');
for threshIdx=1:numOfThreshs
    cThrsh=thresholds(threshIdx);
%     [hitRate(threshIdx) , falseAlarm(threshIdx)] = hitRates((sMap>=cThrsh),(gtMap>=cThrsh));
[hitRate(threshIdx) , falseAlarm(threshIdx), precision(threshIdx)] = hitRates((sMap>=cThrsh),(gtMap));

end
end


