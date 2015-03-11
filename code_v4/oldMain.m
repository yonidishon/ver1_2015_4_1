clear all
% close all
IN_DIR = '../../in/';
OUT_DIR= 'D:/Output/pic/';
% clip='swimCrop2.avi';
% [video] = mmread(clip, 38:140,[],false,true,'',true,true); %test3
% [video] = mmread(clip, 55:(55+65),[],false,true,'',true,doFFMPEG);%test4
% [video] = mmread(clip, 900:1300,[],false,true,'',true,true); %red
% [video] = mmread(clip, 1:1700,[],false,true,'',true,doFFMPEG);
% xyloObj = VideoReader(clip);
% nFrames = xyloObj.NumberOfFrames;
% vidHeight = xyloObj.Height;
% vidWidth = xyloObj.Width;
if (ismac)
    OUT_DIR= '../../out/'; %mac
end
%%
% figure(1);
% hold on;
indx=1;

% files=ls([JuddDir '\*.mat']);
% N = size(files,1);
% 
% %% compare saliency maps
% for i=1:N,
%     disp(['Processing image ' num2str(i) ' out of ' num2str(N)]);
%     [path,base_name,ext] = fileparts(fullfile(dataDir,files(i,:)));
%     I = imread(fullfile(dataDir,[base_name '.jpeg']));
for imIndx=28 %imIndx=[1 11 23 63 27]
    frameCurrent = imread([IN_DIR num2str(imIndx) '.jpg']);
% name='malefemale';
%     frameCurrent = imread([IN_DIR name '.jpg']);
%         frameCurrent=read(xyloObj, imIndx);

    if (size(frameCurrent,3)==1)
        frameCurrent=repmat(frameCurrent,[1 1 3]);
    end
%     frameGray = rgb2gray(frameCurrent);
% fpad = padarray(frameCurrent,[30 30]);
%             imwrite(frameGray, [IN_DIR '28B.jpg'],'jpg');

    I_LAB = rgb2lab(frameCurrent);

%     figure;imagesc(frameCurrent);axis image;colormap(gray);

%     dMap = directionMap(I_LAB);
    tm=tic;
    localFeatures = localFeatures(I_LAB);
    gResult = globalDistinctness(I_LAB,localFeatures./max(localFeatures(:)));
    
%     figure;imagesc(localFeatures);axis image;colormap(hot);title('local');
%     figure;imagesc(gResult);axis image;colormap(hot);title('global');


    frameSaliencyMap = gResult.*localFeatures;%;.*cResult.*distincDist;
    %Normalize saliency Map
    sortSaliency = sort(frameSaliencyMap(:),'descend');
    
    maxSaliency = mean(sortSaliency(1:round(numel(sortSaliency)*.01)));
    frameSaliencyMap = frameSaliencyMap./maxSaliency;
    frameSaliencyMap(frameSaliencyMap>1)=1;
    
    
    
%     figure;imagesc(frameSaliencyMap);axis image;colormap(hot);title('total');
%     figure;imagesc(localFeatures);axis image;colormap(hot);


    
    
%     figure;imagesc(sNorm);axis image;colormap(hot);
%     figure;imagesc(cNorm);axis image;colormap(hot);
%     figure;imagesc(frameCurrent);axis image;colormap(hot)
%     figure;imagesc(I_LAB(:,:,2));axis image;colormap(jet);

% %     figure;imagesc(sNorm.*gNorm);axis image;colormap(hot);
% 
%     figure;imagesc(frameCurrent);axis image;

    %     figure;imagesc(distincDist);axis image;colormap(hot);
    %     figure;imagesc(sResult);axis image;colormap(hot);
    
        
    
    
    fprintf('Finished frame %d after %f\n',imIndx,toc(tm));
%         imwrite(frameSaliencyMap, [OUT_DIR name '.png'],'png');
%         imwrite(frameSaliencyMap, [OUT_DIR num2str(imIndx) '.png'],'png');
% % imwrite(sResult./max(sResult(:)), [OUT_DIR 'structEnergy4.png'],'png');
% imwrite(gradResult./max(gradResult(:)), [OUT_DIR 'gradEnergy4.png'],'png');
    % % figure;imagesc(frameSaliencyMap);axis image;colormap(hot);
    %
%         saliencyFrame = im2uint8(repmat(frameSaliencyMap,[1 1 3]));
%         sMaps(imIndx)= im2frame(saliencyFrame);
    % %
    
    
    C = corner(frameSaliencyMap, 'MinimumEigenvalue',20);
patchHalfSize=4;
Crect = [(C(:,1)-patchHalfSize) (C(:,1)+patchHalfSize) (C(:,2)-patchHalfSize) (C(:,2)+patchHalfSize)];
%Padding 
b=5;
fullHalfSize = patchHalfSize+b;
padding=[-b,b,-b,b];
Crect = Crect + repmat(padding,size(Crect,1),1);
C(min(Crect,[],2)<1,:)=[];
Crect(min(Crect,[],2)<1,:)=[];
C(Crect(:,2)>size(frameSaliencyMap,2),:)=[];
Crect(Crect(:,2)>size(frameSaliencyMap,2),:)=[];
C(Crect(:,4)>size(frameSaliencyMap,1),:)=[];
Crect(Crect(:,4)>size(frameSaliencyMap,1),:)=[];

% Show the movie frame
figure, imshow(frameSaliencyMap,[]);
hold on
plot(C(:,1), C(:,2), 'r*');
hold off;

    
    
end

% movie2avi(sMaps,  [OUT_DIR 'saliencyNew.avi']);

% figure;imagesc(frameCurrent);axis image;
