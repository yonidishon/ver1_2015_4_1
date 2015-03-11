function calcDistinct(inputLocation,outputDir,STATFILE,startIdx)
if (~exist('startIdx','var'))
    startIdx=1;
end

if (~isdir(outputDir) || ~exist(outputDir,'dir'))
    error('outputDir is not a directory or does not exist');
end
if (isdir(inputLocation))
    fileList=dir([inputLocation '/*.png']);
    IN_DIR=inputLocation;
    NumOfFiles=size(fileList,1);
else
    [IN_DIR,base_name,ext] = fileparts(inputLocation);
    fileList.name = [base_name ext];
    NumOfFiles=1;
end


strng =[];
fprintf('\n');
for imIndx=startIdx:NumOfFiles
    [~,base_name,ext] = fileparts(fileList(imIndx).name);
    frameCurrent = rgb2gray(imread([IN_DIR '/' base_name ext]));
    M = max(size(frameCurrent));
    if (size(frameCurrent,3)==1)
        frameCurrent=repmat(frameCurrent,[1 1 3]);
    end
    frameCurrent = imresize(frameCurrent,250/M);
%     frameCurrent2 = frameCurrent;

%     imwrite(frameCurrent,['D:\Output\PatternTime\images\' base_name '.png'],'png')

    
fprintf('\n');
    strng = sprintf('%i/%i',imIndx,NumOfFiles);
    fprintf(strng);
    salTic = tic;
    [sDiffMap sAllMap] = testDiff(frameCurrent,frameCurrent);
%     sDiffMap = imfill(sDiffMap);
    salToc = toc(salTic);
    if (~isempty(STATFILE))
        numOfPixels = size(I_LAB,1)*size(I_LAB,2);
        if (exist(STATFILE,'file'))
        load(STATFILE);
        else
            totalTime=0;
            numOfSamples=0;
            numOfImages = 0;
            averageTime = 0;
        end
        totalTime = totalTime + salToc;
        numOfSamples = numOfSamples + numOfPixels;
        averageTime = totalTime/numOfSamples;
        numOfImages = numOfImages+1;
%         save(STATFILE,'numOfSamples','averageTime','totalTime','numOfImages');
    end
    imwrite(sDiffMap, [outputDir base_name '_PCA.png'],'png');
%     imwrite(sAllMap, [outputDir '/' base_name '_ANN.png'],'png');

end


end