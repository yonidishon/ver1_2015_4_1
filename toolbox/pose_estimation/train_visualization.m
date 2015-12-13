% Script to produce the .txt from DIEM movies to train the
% HoughForest

% .png format:
% Images are needed to be in .png format.
% file names will be in the format of #frame.png
% each movie will have its own images in its own folder.
% folder name will be == movie name (without file extension).

% .txt file format:
% will be sitting in the perent directory.
% - one will be called train_neg.txt
% - one will be called train_pos.txt
% - one will be called test_images.txt
% train_pos.txt:
%  - NUMSAMPLESIM 1 // number of images + dummy value (1)
%  - pos0.png 0 0 74 36 37 18 // filename + boundingbox (top left - bottom right) + center of bounding box
% train_neg.txt:
%  - NUMSAMPLESIM*NUMIMAGES 1 // number of images + dummy value (1)
%  - neg0.png 0 0 100 40 // filename + boundingbox (top left - bottom right)
% test.txt:
% - #Files within file
% - list of fullfile pathes

% [BB_neg,BB_pos]=patch_extract(framedata,gazepnts,gazesigma)

gaze = '\\cgm10\D\DIEM\gaze';
% movie_list = importdata('\\cgm10\D\DIEM\list.txt');
% borji_list_subset = [6,8,10,11,12,14,15,16,34,42,44,48,53,54,55,59,70,74,83,84]; % Used by Borji on DIEM
train_set={'BBC_life_in_cold_blood_1278x710'
           'advert_iphone_1272x720'
           'one_show_1280x712'};
dst_folder ='\\cgm10\D\head_pose_estimation\DIEMpng';
addpath(genpath('\\cgm10\Users\ydishon\Documents\Video_Saliency\Dimarudoy_saliency\Dropbox\Matlab\video_attention'));
addpath(genpath('\\cgm10\Users\ydishon\Documents\Video_Saliency\toolbox\pose_estimation'));
video_loc = '\\cgm10\D\DIEM\video_unc';
NUMIMAGES=-1;% -1 = all in the dataset %100;
SKIP =1;
OFFSET = 30 ;% to be consistent with Dmitry.
NUMSAMPLESIM=50;

for k=1:length(train_set);
    movie_name_no_ext = train_set{k};
    gazeinfo=importdata(fullfile(gaze,[movie_name_no_ext,'.mat']),'data');
    vobj = VideoReader(fullfile(video_loc,[movie_name_no_ext,'.avi']));
    wobj = VideoWriter(fullfile('\\cgm10\D\head_pose_estimation',...
        'Train_vis',[movie_name_no_ext,'.mp4']),'MPEG-4');
    open(wobj);
    for ii=OFFSET:SKIP:length(gazeinfo.points);
        [BB_NEG,BB_POS]=patch_extract_visualization([gazeinfo.width,gazeinfo.height],gazeinfo.points{ii},gazeinfo.pointSigma);
        if isempty(BB_NEG) || isempty(BB_POS)
            continue;
        end
        fr = read(vobj,ii);
        fr = insertShape(rgb2gray(fr),'Rectangle',[BB_POS;BB_NEG],'Color',{'green','red'});
        writeVideo(wobj,fr);
    end
    close(wobj);
end