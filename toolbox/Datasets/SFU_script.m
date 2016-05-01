%clear all;close all;clc
%///////////Optical Flow Params////////////////////
alpha = 0.012;
ratio = 0.75;
minWidth = 20;
nOuterFPIterations = 7;
nInnerFPIterations = 1;
nSORIterations = 30;
ofParam = [alpha, ratio, minWidth, nOuterFPIterations, nInnerFPIterations, nSORIterations];
% Define the size of the input video
W = 352;
H = 288;

% PCA
addpath(genpath('\\cgm10\Users\ydishon\Documents\Video_Saliency\toolbox\PCA_Saliency'));
% Optical Flow
addpath(genpath('\\cgm10\Users\ydishon\Documents\Video_Saliency\Dimarudoy_saliency\GDrive\Software\OpticalFlow\mex'));

datapath ='\\cgm10\D\Competition_Dataset\SFU\SFU_etdb';
VideoFiles = dir(fullfile(datapath,'RAW','*.yuv'));
VideoFiles = extractfield(VideoFiles,'name')';
dst_folder = '\\cgm10\D\head_pose_estimation\SFUPCApng176x144';
png_folder = '\\cgm10\D\head_pose_estimation\SFUpng176x144';
numVids = numel(VideoFiles);
for ii =1:numVids
    VideoFile = fullfile(datapath,'RAW',VideoFiles{ii});
    nam = strsplit(lower(VideoFiles{ii}),'_');nam = nam{1};
    if (exist(fullfile(png_folder,nam),'dir') || exist(fullfile(png_folder,upper(nam)),'dir'))
        fprintf('Skipping Folder:%s already processesed this Video!\n',VideoFiles{ii});
        continue
    end
    
    CSVFile = fullfile(datapath,'CSV',sprintf('%s-Screen.csv',nam));
    if(exist(VideoFile, 'file') && exist(CSVFile,'file'))
        % Loop over frames and display the gaze locations over each videe frame
        [GazeLocations, ~] = xlsread(CSVFile);
        [NumberOfFrames, ~] = size(GazeLocations);
        vidnam = strsplit(VideoFiles{ii},'_'); vidnam = upper(vidnam{1});
        if ~exist(fullfile(dst_folder,vidnam),'dir')
           status  = mkdir(fullfile(dst_folder,vidnam));
           if ~status
               error('SFU:: couldn''t create dir for %s',vidnam);
           end
        end
        
        if ~exist(fullfile(png_folder,vidnam),'dir')
            status  = mkdir(fullfile(png_folder,vidnam));
            if ~status
                error('SFU:: couldn''t create dir for %s',vidnam);
            end
        end
        for k=1:NumberOfFrames
            % Read one frame from the input YUV file and display it
            rgb = loadFileYuv(VideoFile,W,H,k);
            rgb = imresize(rgb,0.5);
            if k==1 || k==2
                [ofx, ofy]=deal(zeros(size(rgb,1),size(rgb,2)));
            else
                fp = loadFileYuv(VideoFile,W,H,k-2);
                fp = imresize(fp,0.5);
                [ofx, ofy] = Coarse2FineTwoFrames(rgb, fp, ofParam);
            end
            [~,Smap,Mmap]=PCA_Saliency_all_color(ofx,ofy,rgb);
            
            imwrite(Smap,fullfile(dst_folder,vidnam,sprintf('%06d_PCAs.png',k)),'BitDepth',16);
            imwrite(Mmap,fullfile(dst_folder,vidnam,sprintf('%06d_PCAm.png',k)),'BitDepth',16);
            imwrite(rgb,fullfile(png_folder,vidnam,sprintf('%06d.png',k)));
        end
        disp 'Done!'
    else
        disp 'Error! Input video file not found!'
    end
end
