function calcVideoSaliency(diemDataRoot,outputDir,videoIdx)
totTime = 0;
if (~exist('startIdx','var'))
    startIdx=1;
end
videos = videoListLoad(diemDataRoot, 'DIEM');


vidOBJ = VideoReader([diemDataRoot '\video_unc\' videos{videoIdx} '.avi']);
nFrames = vidOBJ.NumberOfFrames;

if (exist([outputDir videos{videoIdx}],'dir'))
   fls = numel(dir( [outputDir videos{videoIdx} '\*.png']));
   if (nFrames==fls)
       return;
   end
end


writeDir = [outputDir videos{videoIdx}];
mkdir(writeDir);

% vidHeight = vidOBJ.Height;
% vidWidth = vidOBJ.Width;

vidOUT = VideoWriter([writeDir 'salVid.avi']);
open(vidOUT);







fprintf('\n');
framePrev = nan;

frameCurrent = im2double(read(vidOBJ,1));

% %
% % optical = vision.OpticalFlow('Method','Lucas-Kanade','OutputValue', 'Horizontal and vertical components in complex form','ReferenceFrameSource','Input port');
% optical = vision.OpticalFlow('OutputValue', 'Horizontal and vertical components in complex form','ReferenceFrameSource','Input port');
% % optical = vision.BlockMatcher('ReferenceFrameSource','Input port','BlockSize',[5 5],'OutputValue', 'Horizontal and vertical components in complex form');
Aq = linspace(-pi,pi,17);
alpha = 0.012;
ratio = 0.75;
minWidth = 20;
nOuterFPIterations = 7;
nInnerFPIterations = 1;
nSORIterations = 30;

para = [alpha,ratio,minWidth,nOuterFPIterations,nInnerFPIterations,nSORIterations];

maxWidth = size(frameCurrent,2);
maxHeight = size(frameCurrent,1);
r = 1:maxHeight;
c = 1:maxWidth;
[X, Y] = meshgrid(c,r);

rd = 1:5:maxHeight;
cd = 1:5:maxWidth;
[Xd, Yd] = meshgrid(cd,rd);


for imIndx=1:nFrames

    %     if imIndx==6
    %         dd=3;
    %     end
%     [~,base_name,ext] = fileparts(fileList(imIndx).name);
%     base_name = ['alice_' num2str(imIndx,'%04d')];
    frameCurrent = im2double(read(vidOBJ,imIndx));
    
    
        calcCFrame=true;
    if (~all(isnan(framePrev)))
       frameD = sum(abs(framePrev-frameCurrent),3); 
       frameD = max(frameD(:));
       if (frameD<0.1)
           calcCFrame=false;
       end
    end
    
    if (max(frameCurrent(:))<0.1)
        frameSaliencyMap = fspecial('gaussian',[maxHeight maxWidth],50);
        frameSaliencyMap = frameSaliencyMap./max(frameSaliencyMap(:));
        calcCFrame  = false;
    end
    
    if (calcCFrame == true)
    Glvl = false;
    if (size(frameCurrent,3)==1)
        Glvl = true;
    end
    fprintf('\n');
    strng = sprintf('%i/%i',imIndx,nFrames);
    fprintf(strng);
    
%     salTic = tic;
    %     frameSaliencyMap = spatioTemporalSaliency(frameCurrent,prevFrames);
    [spatialSaliencyMap pattern color weight]  = spatialSaliency(frameCurrent,Glvl);
    if (~any(isnan(framePrev)))
%         optFlow = step(optical,frameCurrent,framePrev);
        %                       optFlow = step(optical,framePrev,frameCurrent);
        
        
        [H,V] = Coarse2FineTwoFrames(frameCurrent,framePrev,para);
%         Vd = V(rd, cd);
%         Hd = H(rd,cd);
%         figure;imshow(frameCurrent);hold on;
%         quiver(Xd,Yd,-Hd,-Vd,0);hold off;
% 
%         R = sqrt(H.^2+V.^2);
%         A = atan2(V,H);
%         
%         Avec = im2colstep(padarray(A,[3 3],'replicate'),[7 7])';
%         Rvec = im2colstep(padarray(R,[3 3],'replicate'),[7 7])';
%         [nA,binA] = histc(Avec,linspace(-pi,pi,16),2);
%         [~,by] = meshgrid(1:size(binA,2),1:size(binA,1));
%         indices = [by(:) binA(:)];
%       WH = accumarray(indices, 1+Rvec(:), size(nA), @sum);
%       figure;imagesc(WH);
%       sWH = exp(-1/10*reshape(std(WH,0,2),size(R)));      
%       se = strel('disk',6);
% %       sWH = imopen(sWH,se);
%       sWH = imfilter(sWH,fspecial('gaussian',10,5));
%            
%       figure;imagesc(sWH);axis image
      

      tmpMap  = temporalSal(cat(3,single(V),single(H)),spatialSaliencyMap);
%       figure;imagesc(tmpMap);axis image;
%         figure;imagesc(tmpMap.*sWH);axis image;
%         figure;imagesc(spatialSaliencyMap);axis image
%         
        %         V2 = imag(optFlow2);
        %         H2 = real(optFlow2);
        %         figure;
        %         subplot(2,1,1);imagesc(abs(H-H2));axis image;
        %         subplot(2,1,2);imagesc(abs(V-V2));axis image;
        %
        
        
        %         M = [H(:) V(:)];
        %         meanM = mean(M,1);
        %         D = reshape(sum(abs(M-repmat(meanM,[size(M,1) 1])),2),size(H));
        %         figure;imagesc(D);axis image;
        %         figure;imagesc(tmpMap);axis image;
        %
        
        
        %          figure;imshow(framePrev);
        %         figure;imshow(frameCurrent); hold on;
        %         quiver(Xd,Yd,1*(Hd.*Wd),1*(Vd.*Wd),5,'r'); hold off;
        
        
        
        frameSaliencyMap = stableNormalize(spatialSaliencyMap.*tmpMap);
        
    else
        frameSaliencyMap = spatialSaliencyMap;
        
    end
    end
    %
    % %         figure;imagesc(tmpMap);axis image;
    % %         filt = fspecial('gaussian',5,2);
    % %         fuzzySpat = imfilter(spatialSaliencyMap,filt);
    % %         figure;imagesc(fuzzySpat);axis image;
    % %         frameDiff = single(imfilter(frameCurrent,filt))-single(imfilter(framePrev,filt));
    % %         frameDiff = (single(frameCurrent)-single(framePrev)).*fuzzySpat;
    % %         figure;imagesc(frameDiff);axis image;
    %
    % %         if (max(frameDiff(:)>10))
    % %         [FX,FY] = gradient(frameDiff);
    % %         tmpMap  = temporalSal(cat(3,single(FY),single(FX)),spatialSaliencyMap);
    % %         tmpMap = stableNormalize(imfill(tmpMap,'holes'));
    % %         tmp = multiResTemp(H,V,spatialSaliencyMap);
    % %         if (~any(isnan(tmp(:))))
    % %             tmpMap = tmp;
    % %         end
    % %        figure;imagesc(tmpMap);axis image;
    % % figure;imagesc(spatialSaliencyMap); axis image;
    % % figure;imshow(spatialSaliencyMap);
    % % figure;imagesc(frameDiff);axis image;
    % % %         keyboard;
    %         frameSaliencyMap = stableNormalize(spatialSaliencyMap.*tmpMap);
    %         frameSaliencyMap = imfill(frameSaliencyMap,'holes');
    % %         figure;imagesc(frameSaliencyMap);axis image;
    % %         else
    % %         end
    %     else
    %         frameSaliencyMap = spatialSaliencyMap;
    %     end
%     salToc = toc(salTic);
%     totTime = totTime + salToc;
    
    
    framePrev = frameCurrent;
    imwrite(frameSaliencyMap, [writeDir '/' 'frame_' num2str(imIndx) '.png'],'png');
    writeVideo(vidOUT,frameSaliencyMap);
 
    
    
    
    %     imwrite(pattern, [outputDir '/' base_name '_MULTI.png'],'png');
    %     imwrite(color, [outputDir '/' base_name '_C.png'],'png');
    %     imwrite(weight, [outputDir '/' base_name '_W.png'],'png');
    %     imwrite(stableNormalize(pattern.*color), [outputDir '/' base_name '_P+C.png'],'png');
    
    
    
    
end
% fprintf('\nTotal time---> %d seconds\n',totTime);
close(vidOUT);
end