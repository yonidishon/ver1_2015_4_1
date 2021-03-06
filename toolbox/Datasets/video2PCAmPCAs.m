% Script to produce the PCAs and PCAm from DIEM movies

% .png format:
% Images are needed to be in .png format.
% file names will be in the format of #frame_PCA<s,m>.png
% each movie will have its own images in its own folder.
% folder name will be == movie name (without file extension).

%///////////Optical Flow Params////////////////////
alpha = 0.012;
ratio = 0.75;
minWidth = 20;
nOuterFPIterations = 7;
nInnerFPIterations = 1;
nSORIterations = 30;
ofParam = [alpha, ratio, minWidth, nOuterFPIterations, nInnerFPIterations, nSORIterations];
%///////////////////////////////////////////////////

videosFold = '\\cgm10\D\DIEM\video_unc'; %-> if going to full-on data needs to updata this
movie_list = importdata('\\cgm10\D\DIEM\list.txt');
%borji_list_subset = [6,8,10,11,12,14,15,16,34,42,44,48,53,54,55,59,70,74,83,84]; % Used by Borji on DIEM
%my_training_set = [7,18,20,21,22,32,39,41,46,51,56,60,65,72,73];
test_and_train_set = [6,8,10,11,12,14,15,16,34,42,44,48,53,54,55,59,70,74,83,84,7,18,20,21,22,32,39,41,46,51,56,60,65,72,73];
all_ind = 1:84;
all_ind(test_and_train_set) = [];
test_and_train_set = all_ind;
dst_folder ='\\cgm10\D\head_pose_estimation\DIEMPCAWCOLORpng';
% pose_estimation
addpath(genpath('\\cgm10\Users\ydishon\Documents\Video_Saliency\toolbox\pose_estimation'));
% PCA
addpath(genpath('\\cgm10\Users\ydishon\Documents\Video_Saliency\toolbox\PCA_Saliency'));
% Optical Flow
addpath(genpath('\\cgm10\Users\ydishon\Documents\Video_Saliency\Dimarudoy_saliency\GDrive\Software\OpticalFlow\mex'));
frnum=0;
for k=7:length(test_and_train_set);
    movie_name_no_ext = movie_list{test_and_train_set(k)};
    if ~exist(fullfile(dst_folder,movie_name_no_ext),'dir')
        mkdir(fullfile(dst_folder,movie_name_no_ext));
    end
    vobj = VideoReader(fullfile(videosFold,[movie_name_no_ext,'.avi']));
    read(vobj,inf);
    for ii=1:vobj.NumberOfFrames
        frnum=frnum+1;
        if (mod(frnum,1000)==0)
            fprintf('Processing %s total frames process so far is %i\n',movie_name_no_ext,frnum);
        end
        if (exist(fullfile(dst_folder,movie_name_no_ext,sprintf('%06d_PCAm.png',ii)),'file') && ...
                exist(fullfile(dst_folder,movie_name_no_ext,sprintf('%06d_PCAs.png',ii)),'file'))
            continue;
        end
        f = read(vobj,ii);
        if ii==1 || ii==2
            [ofx, ofy]=deal(zeros(size(f,1),size(f,2)));
        else
            fp = read(vobj, ii - 2);
            [ofx, ofy] = Coarse2FineTwoFrames(f, fp, ofParam);
        end
        [~,Smap,Mmap]=PCA_Saliency_all_color(ofx,ofy,f);
        imwrite(Smap,fullfile(dst_folder,movie_name_no_ext,sprintf('%06d_PCAs.png',ii)),'BitDepth',16);
        imwrite(Mmap,fullfile(dst_folder,movie_name_no_ext,sprintf('%06d_PCAm.png',ii)),'BitDepth',16);
    end
end;