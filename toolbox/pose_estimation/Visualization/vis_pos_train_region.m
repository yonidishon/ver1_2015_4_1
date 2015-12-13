% script for visualization of the foreground region of the train/test set
% on the DIEM

gaze = '\\cgm10\D\DIEM\gaze';
movie_list = importdata('\\cgm10\D\DIEM\list.txt');
borji_list_subset = [6,8,10,11,12,14,15,16,34,42,44,48,53,54,55,59,70,74,83,84]; % Used by Borji on DIEM
%my_training_set = [7,18,20,21,22,32,39,41,46,51,56,60,65,72,73]; %15 vids - hand selected
%train_set={'BBC_life_in_cold_blood_1278x710'
%           'advert_iphone_1272x720'
%          'one_show_1280x712'};
my_training_set = borji_list_subset;
train_set = movie_list(my_training_set);
src_folder = '\\cgm10\D\head_pose_estimation\DIEMPCApng';
dst_folder ='C:\Users\ydishon\Documents\Video_Saliency\Train_vis';%'\\cgm10\D\head_pose_estimation\DIEMpng';
addpath(genpath('\\cgm10\Users\ydishon\Documents\Video_Saliency\Dimarudoy_saliency\Dropbox\Matlab\video_attention'));
addpath(genpath('\\cgm10\Users\ydishon\Documents\Video_Saliency\toolbox\pose_estimation'));
NUMIMAGES=-1;% -1 = all in the dataset %100;
SKIP =1;%5;
OFFSET = 30;% to be consistent with Dmitry.
totnumframes=0;


for k=1:length(train_set);
    movie_name_no_ext = train_set{k};
    wobj = VideoWriter(fullfile(dst_folder,[movie_name_no_ext,'.avi']),'Uncompressed AVI');
    open(wobj);
    gazeinfo=importdata(fullfile(gaze,[movie_name_no_ext,'.mat']),'data');
    for ii=OFFSET:SKIP:length(gazeinfo.points);
        HIGHTH=exp(-(1)^2/2);% distance of 2 sigma from maximum;
        fix_points = gazeinfo.points{ii};
        att_map=points2GaussMap(fix_points',ones(1,length(fix_points)),0,[gazeinfo.width,gazeinfo.height],gazeinfo.pointSigma);
        %[~,BB_POS]=patch_extract([gazeinfo.width,gazeinfo.height],gazeinfo.points{ii},gazeinfo.pointSigma,0);
        th_att_map=att_map>=HIGHTH;
        ind = find(repmat(th_att_map,1,1,3));
%         BB_pos=regionprops(th_att_map,'BoundingBox');
%         if isempty(BB_POS)
%             continue;
%         end
%         if size(BB_pos,1)>1; % more than one positive position
%             areas=regionprops(th_att_map,'Area');
%             [areas,idx]=sort(extractfield(areas,'Area'));
%             if areas(1) > 2*areas(2)
%                 BB_pos = BB_pos.BoundingBox(idx(1));
%             else
%                 BB_pos = extractfield(BB_pos,'BoundingBox');
%                 BB_pos = reshape(BB_pos,4,numel(areas));
%             end
%          end
        f=imread(fullfile(src_folder,train_set{k},sprintf('%06d.png',ii)));
        gray=repmat(round(rgb2gray(f)/2),1,1,3);
        gray(ind)=f(ind);
%        f=insertShape(f,'Circle',[BB_POS(5:6)+1,20;BB_POS(5:6)+1,0],'LineWidth',1);
        writeVideo(wobj,gray);
    end
    close(wobj);
    t= datetime('now','TimeZone','local','Format','d-MMM-y HH:mm:ss');
    fprintf('%s: Finish processing #%i/%i movie:%s\n',datestr(t),k,length(train_set),movie_name_no_ext);
end
