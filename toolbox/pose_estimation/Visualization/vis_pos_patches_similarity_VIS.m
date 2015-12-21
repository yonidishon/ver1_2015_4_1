% script for visualization of the foreground region of the train/test set
% on the DIEM output is 4 folders (quadrants around peak with images in them
% img format is : <video_name_shorthand>_<frame#>_<BB_size>_<cent_coordinate>.png
% video_name_shorthand is the video number in the list
% frame number is the frame number in the video
% channel is the channel of the feature : PCAs ,  PCAm

% setting nessecary data
gaze = '\\cgm10\D\DIEM\gaze';
movie_list = importdata('\\cgm10\D\DIEM\list.txt');
addpath(genpath('\\cgm10\Users\ydishon\Documents\Video_Saliency\Dimarudoy_saliency\Dropbox\Matlab\video_attention'));
addpath(genpath('\\cgm10\Users\ydishon\Documents\Video_Saliency\toolbox\pose_estimation'));
test_set = [6,8,10,11,12,14,15,16,34,42,44,48,53,54,55,59,70,74,83,84]; % Used by Borji on DIEM
train_set = [7,18,20,21,22,32,39,41,46,51,56,60,65,72,73]; %15 vids - hand selected

src_folder = '\\cgm10\D\head_pose_estimation\DIEMpng'; % PCA images
dst_folder ='\\cgm10\D\head_pose_estimation\Out_Of_Train_vis_15';%'\\cgm10\D\head_pose_estimation\DIEMpng';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Exp description %%%%%%%%%%%%%%%%%%%%%%%
% 1.GetNumberof frame per movie
FRPERMOV = 100;
OFFSET = 30;
BB_size =40;
% 2. choose test set or train set
%train_set = movie_list(test_set);
%train_set = movie_list(train_set);
mov_ind = 1:84;
mov_ind([train_set,test_set]) =[];

train_set = movie_list(mov_ind);
% 3. for each movie extract the quadrant to the right folder.

for k=1:length(train_set);
    movie_name_no_ext = train_set{k};
    gazeinfo=importdata(fullfile(gaze,[movie_name_no_ext,'.mat']),'data');
    movfiles = dir(fullfile(src_folder,movie_name_no_ext,'*.png'));
    SKIP = round((size(movfiles,1)-OFFSET)/FRPERMOV);
    for ii=OFFSET:SKIP:length(gazeinfo.points);
        % find peak of gaze and extract a bounding box of 40x40 around it
        HIGHTH=exp(-(1)^2/2);% distance of 2 sigma from maximum;
        fix_points = gazeinfo.points{ii};
        if isempty(fix_points)
            continue
        end
        att_map=points2GaussMap(fix_points',ones(1,length(fix_points)),0,[gazeinfo.width,gazeinfo.height],gazeinfo.pointSigma);
        th_att_map=att_map>=HIGHTH;
        area = extractfield(regionprops(th_att_map,'Area'),'Area');
        if numel(area)>1
          [~,idx] = sort(area,'descend');
          cent = extractfield(regionprops(th_att_map,'Centroid'),'Centroid')';
          cent = reshape(cent,2,numel(idx))';
          cent = cent(idx(1),:);
        else
          cent = extractfield(regionprops(th_att_map,'Centroid'),'Centroid');  
        end
        cent = round(flip(cent));
        % get the Salinecy maps
        f_m=imread(fullfile(src_folder,train_set{k},sprintf('%06d.png',ii)));
        lu_quad_m = f_m(max(cent(1)-BB_size/2,1):cent(1)-1,max(cent(2)-BB_size/2,1):cent(2)-1,:);
        ru_quad_m = f_m(max(cent(1)-BB_size/2,1):cent(1)-1,cent(2):min(cent(2)+BB_size/2-1,size(f_m,2)),:);
        ld_quad_m = f_m(cent(1):min(cent(1)+BB_size/2-1,size(f_m,1)),max(cent(2)-BB_size/2,1):cent(2)-1,:);
        rd_quad_m = f_m(cent(1):min(cent(1)+BB_size/2-1,size(f_m,1)),cent(2):min(cent(2)+BB_size/2-1,size(f_m,2)),:);  
        %debug
%         figure();
%         subplot(2,3,[1,4]);imshow(f_m(cent(1)-BB_size/2:cent(1)+BB_size/2-1,cent(2)-BB_size/2-1:cent(2)+BB_size/2-1));
%         subplot(2,3,2);imshow(lu_quad_m,[]);
%         subplot(2,3,3);imshow(ru_quad_m,[]);
%         subplot(2,3,5);imshow(ld_quad_m,[]);
%         subplot(2,3,6);imshow(rd_quad_m,[]);
        % save images : % img format is : <video_name_shorthand>_<frame#>_<BB_size>_<cent_coordinate>.png
        imwrite(lu_quad_m,fullfile(dst_folder,'VIS','2nd',sprintf('%i_%i_%i_%i-%i.png',mov_ind(k),ii,BB_size,cent(1),cent(2))));
        imwrite(ru_quad_m,fullfile(dst_folder,'VIS','1st',sprintf('%i_%i_%i_%i-%i.png',mov_ind(k),ii,BB_size,cent(1),cent(2))));
        imwrite(ld_quad_m,fullfile(dst_folder,'VIS','3rd',sprintf('%i_%i_%i_%i-%i.png',mov_ind(k),ii,BB_size,cent(1),cent(2))));
        imwrite(rd_quad_m,fullfile(dst_folder,'VIS','4th',sprintf('%i_%i_%i_%i-%i.png',mov_ind(k),ii,BB_size,cent(1),cent(2))));
        imwrite(f_m(max(cent(1)-BB_size/2,1):min(cent(1)+BB_size/2-1,size(f_m,1)),max(cent(2)-BB_size/2,1):min(cent(2)+BB_size/2-1,size(f_m,2)),:)...
            ,fullfile(dst_folder,'VIS','whole',sprintf('%i_%i_%i_%i-%i.png',mov_ind(k),ii,BB_size,cent(1),cent(2))));
    end
    t= datetime('now','TimeZone','local','Format','d-MMM-y HH:mm:ss');
    fprintf('%s: Finish processing #%i/%i movie:%s\n',datestr(t),k,length(train_set),movie_name_no_ext);
end
