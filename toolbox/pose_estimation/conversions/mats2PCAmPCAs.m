% Script to produce the PCAs and PCAm from DIEM movies

% .png format:
% Images are needed to be in .png format.
% file names will be in the format of #frame_PCA<s,m>.png
% each movie will have its own images in its own folder.
% folder name will be == movie name (without file extension).

cache = '\\cgm10\D\Video_Saliency_cache_Backup'; %-> if going to full-on data needs to updata this
movie_list = importdata('\\cgm10\D\DIEM\list.txt');
borji_list_subset = [6,8,10,11,12,14,15,16,34,42,44,48,53,54,55,59,70,74,83,84]; % Used by Borji on DIEM
dst_folder ='\\cgm10\D\head_pose_estimation\DIEMPCApng';
addpath(genpath('\\cgm10\Users\ydishon\Documents\Video_Saliency\toolbox\pose_estimation'));
addpath(genpath('\\cgm10\Users\ydishon\Documents\Video_Saliency\toolbox\PCA_Saliency'));
for k=1:length(borji_list_subset);
    movie_name_no_ext = movie_list{borji_list_subset(k)};
    matfiles = dir(fullfile(cache,[movie_name_no_ext,'.avi'],'*.mat'));
    if ~exist(fullfile(dst_folder,movie_name_no_ext),'dir')
        mkdir(fullfile(dst_folder,movie_name_no_ext));
    end
    for ii=1:length(matfiles)
        fname=fullfile(cache,[movie_name_no_ext,'.avi'],sprintf('frame_%06d.mat',ii));
        img_data=importdata(fname,'data');
        [~,Smap,Mmap]=PCA_Saliency_all(img_data.ofx,img_data.ofy,img_data.image);
        imwrite(Smap,fullfile(dst_folder,movie_name_no_ext,sprintf('%06d_PCAs.png',ii)),'BitDepth',16);
        imwrite(Mmap,fullfile(dst_folder,movie_name_no_ext,sprintf('%06d_PCAm.png',ii)),'BitDepth',16);
    end
end;