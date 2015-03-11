clear all
close all
IN_DIR = '../../in/';
OUT_DIR= 'D:/Output/sal/';
% clip='shaky2c.avi';
% xyloObj = VideoReader(clip);
% nFrames = xyloObj.NumberOfFrames;
% vidHeight = xyloObj.Height;
% vidWidth = xyloObj.Width;
if (ismac)
    OUT_DIR= '../../out/app/'; %mac
end
%%
% figure(1);
% hold on;

% files=ls([JuddDir '\*.mat']);
% N = size(files,1);
%
% %% compare saliency maps
% for i=1:N,
%     disp(['Processing image ' num2str(i) ' out of ' num2str(N)]);
%     [path,base_name,ext] = fileparts(fullfile(dataDir,files(i,:)));
%     I = imread(fullfile(dataDir,[base_name '.jpeg']));
for imIndx=65 %imIndx=[1 11 23 63 27]
    frameCurrent = imread([IN_DIR num2str(imIndx) '.jpg']);
    %     frameCurrent = read(xyloObj,imIndx);
    if (size(frameCurrent,3)==1)
        frameCurrent=repmat(frameCurrent,[1 1 3]);
    end
    %     frameGray = rgb2gray(frameCurrent);
    % fpad = padarray(frameCurrent,[30 30]);
    %             imwrite(frameGray, [IN_DIR '28B.jpg'],'jpg');
    
    I_LAB = rgb2lab(frameCurrent);
    [frameSaliencyMap lResult gResult]= spatialSaliency(I_LAB,imIndx);
    %         figure;imagesc(lResult);axis image;colormap(hot);title('local');
    %     figure;imagesc(I_LAB(:,:,1));axis image;colormap(gray);title('global');
    %     figure; imagesc(gResult);axis image;colormap(hot);title('global');
        imwrite(frameSaliencyMap, [OUT_DIR num2str(imIndx) '.png'],'png');
    % figure(2);plot(cols);
%     threshold=0.1:0.005:0.69;
%     for thIndx=1:numel(threshold)
%         croppedImage= cropImage(frameCurrent,frameSaliencyMap,lResult,threshold(thIndx));
%         imwrite(croppedImage, [OUT_DIR num2str(thIndx) '.jpg'],'jpg');
%     end
%     imwrite(frameSaliencyMap, [OUT_DIR num2str(imIndx) '.png'],'png');


    
end

% figure(1);imagesc(frameSaliencyMap);axis image;colormap(hot);
% figure(2);imagesc(lResult);axis image;colormap(hot);



% movie2avi(sMaps,  [OUT_DIR 'saliencyNew.avi']);
