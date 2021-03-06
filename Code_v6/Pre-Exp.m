addpath(genpath('\\cgm10\Users\ydishon\Documents\Video_Saliency\toolbox\'));
VIDEO_LOC='\\cgm41\users\gleifman\Documents\DimaCode\DIEM\video';
GAZE_LOC='\\cgm10\D\DIEM\gaze';
%movies=dir(fullfile(VIDEO_LOC,'*.avi'));
movies=dir(fullfile(VIDEO_LOC,'*.mp4'));
% Getting only the DIEM basic movies (84 movies);
movies=movies(cellfun(@(x)isempty(x),strfind({movies.name},'_depth')));
% Select one Movie
movie=movies(10).name;
% Getting movie obj.
vobj=VideoReader(fullfile(VIDEO_LOC,movie));
% Getting Gaze information
file_no_end=strsplit(movie,'.');file_no_end=file_no_end{1};
gazefile=load(fullfile(GAZE_LOC,[file_no_end,'.mat']));
gazefile=gazefile.data;
frame_n = read(vobj,600);
frame_n_plus_15 = read(vobj,600+100);
imSize=size(frame_n);imSize=imSize(1:2);
[PCA_n,ave_n,vecs_n]= PCA_basic_1scale(frame_n);
[PCA_n_plus_15,ave_n_plus_15,vecs_n_plus_15]= PCA_basic_1scale(frame_n_plus_15);
cosdist=abs(PCA_n_plus_15'*PCA_n);
figure();imagesc(cosdist);colorbar; xlabel('im n');ylabel('im n+15');
[~,im_n_maxs_ind]=max(cosdist,[],1);
vec_n=abs(im_n_maxs_ind'-[1:size(cosdist,2)]');
[~,im_n_plus_15_maxs_ind]=max(cosdist,[],2);
vec_n_plus_15=abs(im_n_plus_15_maxs_ind-[1:size(cosdist,2)]');
%reconError_n = sum(abs((vecs_n*PCA_n(:,im_n_maxs_ind))),2);
reconError_n = sum(abs((vecs_n*PCA_n(:,[46,67]))),2);
reconError_n=reconError_n./max(reconError_n(:));
reconError_n = reshape(reconError_n,imSize);
%reconError_n_plus_15 = sum(abs((vecs_n_plus_15*PCA_n_plus_15(:,im_n_plus_15_maxs_ind))),2);
reconError_n_plus_15 = sum(abs((vecs_n_plus_15*PCA_n_plus_15(:,[45,65]))),2);
reconError_n_plus_15=reconError_n_plus_15./max(reconError_n_plus_15(:));
reconError_n_plus_15 = reshape(reconError_n_plus_15,imSize);
figure();
subplot(2,2,1);imshow(frame_n);
subplot(2,2,2);imshow(reconError_n,[]);
subplot(2,2,3);imshow(frame_n_plus_15);
subplot(2,2,4);imshow(reconError_n_plus_15,[]);
