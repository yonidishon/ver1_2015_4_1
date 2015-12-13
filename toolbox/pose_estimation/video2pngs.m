% Script to produce the images from DIEM movies

% .png format:
% Images are needed to be in .png format.
% file names will be in the format of #frame.png
% each movie will have its own images in its own folder.
% folder name will be == movie name (without file extension).


videosFold = '\\cgm10\D\DIEM\video_unc'; %-> if going to full-on data needs to updata this
movie_list = importdata('\\cgm10\D\DIEM\list.txt');
borji_list_subset = [6,8,10,11,12,14,15,16,34,42,44,48,53,54,55,59,70,74,83,84]; % Used by Borji on DIEM
my_training_set = [7,18,20,21,22,32,39,41,46,51,56,60,65,72,73];
not_training_set = 1:84;
not_training_set([borji_list_subset,my_training_set]) = [];
my_training_set = not_training_set;
dst_folder ='\\cgm10\D\head_pose_estimation\DIEMpng';
addpath(genpath('\\cgm10\Users\ydishon\Documents\Video_Saliency\toolbox\pose_estimation'));
for k=1:length(my_training_set);
    movie_name_no_ext = movie_list{my_training_set(k)};
    if ~exist(fullfile(dst_folder,movie_name_no_ext),'dir')
        mkdir(fullfile(dst_folder,movie_name_no_ext));
    end
    t= datetime('now','TimeZone','local','Format','d-MMM-y HH:mm:ss');
    fprintf('%s: Start processing #%i/%i movie:%s\n',datestr(t),k,length(my_training_set),movie_name_no_ext);
    vobj = VideoReader(fullfile(videosFold,[movie_name_no_ext,'.avi']));
    read(vobj,inf);
    for ii=1:vobj.NumberOfFrames
        imwrite(read(vobj,ii),fullfile(dst_folder,movie_name_no_ext,sprintf('%06d.png',ii)));  
    end
end;