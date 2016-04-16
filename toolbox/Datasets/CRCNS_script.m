clear all;close all;clc
%///////////Optical Flow Params////////////////////
alpha = 0.012;
ratio = 0.75;
minWidth = 20;
nOuterFPIterations = 7;
nInnerFPIterations = 1;
nSORIterations = 30;
ofParam = [alpha, ratio, minWidth, nOuterFPIterations, nInnerFPIterations, nSORIterations];

% PCA
addpath(genpath('\\cgm10\Users\ydishon\Documents\Video_Saliency\toolbox\PCA_Saliency'));
% Optical Flow
addpath(genpath('\\cgm10\Users\ydishon\Documents\Video_Saliency\Dimarudoy_saliency\GDrive\Software\OpticalFlow\mex'));

datapath ='\\cgm10\D\Competition_Dataset\CRCNS\CRCNS-DataShare';
dst_folder = '\\cgm10\D\head_pose_estimation\CRCNSPCApng';
png_folder = '\\cgm10\D\head_pose_estimation\CRCNSpng';
fid=fopen('MPGSIZES.txt','r');
 C = textscan(fid,'%s %d');
 fclose(fid);
 %numVids = numel(C{1});
 VideoFiles = C{1};
 FramesInMovie = C{2};
 vid_idx = [5,6,8,10,11,15,18,19,21,26,27,40,41,45,46,49,50]; % fixation Bank subset
 numVids = numel(vid_idx);
 VideoFiles = VideoFiles(vid_idx);
%%
for ii =1:numVids
    VideoFile = fullfile(datapath,'stimuli',VideoFiles{ii});
    if (exist(fullfile(png_folder,VideoFiles{ii}),'dir'))
        fprintf('Skipping Folder already processesed this Video!\n');
        continue
    end
    if(exist(VideoFile, 'file'))
        % Loop over frames and display the gaze locations over each videe frame
        if ~exist(fullfile(dst_folder,VideoFiles{ii}),'dir')
           status  = mkdir(fullfile(dst_folder,VideoFiles{ii}));
           if ~status
               error('CRCNS:: couldn''t create dir for %s',VideoFiles{ii});
           end
        end
        if ~exist(fullfile(png_folder,VideoFiles{ii}),'dir')
            status  = mkdir(fullfile(png_folder,VideoFiles{ii}));
            if ~status
                error('CRCNS:: couldn''t create dir for %s',VideoFiles{ii});
            end
        end
        vobj = VideoReader(VideoFile); read(vobj,Inf);
        NumberOfFrames = min(FramesInMovie(ii),vobj.NumberOfFrames);
        for k=1:NumberOfFrames
            % Read one frame from the input YUV file and display it
            rgb = read(vobj,k);
            rgb = imresize(rgb,1/2);
            if k==1 || k==2
                [ofx, ofy]=deal(zeros(size(rgb,1),size(rgb,2)));
            else
                fp = read(vobj,k-2);
                fp = imresize(fp,1/2);
                [ofx, ofy] = Coarse2FineTwoFrames(rgb, fp, ofParam);
            end
            [~,Smap,Mmap]=PCA_Saliency_all_color(ofx,ofy,rgb);
            imwrite(Smap,fullfile(dst_folder,VideoFiles{ii},sprintf('%06d_PCAs.png',k)),'BitDepth',16);
            imwrite(Mmap,fullfile(dst_folder,VideoFiles{ii},sprintf('%06d_PCAm.png',k)),'BitDepth',16);
            imwrite(rgb,fullfile(png_folder,VideoFiles{ii},sprintf('%06d.png',k)));
        end
        disp 'Done!'
    else
        disp 'Error! Input video file not found!'
    end
end
