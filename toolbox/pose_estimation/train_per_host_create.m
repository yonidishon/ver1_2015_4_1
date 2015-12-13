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
hosts = {'CGM-AYELLET-1',...
    'CGM7',...
    'CGM16',...
    'CGM22',...
    'CGM41',...
    'CGM45',...
    'CGM46',...
    'CGM47'};
filenmsuffix ='.txt'; % TODO
%filenmsuffix = '.txt';
gaze = '\\cgm10\D\DIEM\gaze';
movie_list = importdata('\\cgm10\D\DIEM\list.txt');
% borji_list_subset = [6,8,10,11,12,14,15,16,34,42,44,48,53,54,55,59,70,74,83,84]; % Used by Borji on DIEM
my_training_set = [7,18,20,21,22,32,39,41,46,51,56,60,65,72,73]; %15 vids - hand selected
%train_set={'BBC_life_in_cold_blood_1278x710'
%           'advert_iphone_1272x720'
%          'one_show_1280x712'};
train_set = movie_list(my_training_set);
MOVIESPERHOST = repmat(floor(length(train_set)/length(hosts)),length(hosts),1);
carry_over = mod(length(train_set),length(hosts));
MOVIESPERHOST(end-(carry_over-1):end,:) = MOVIESPERHOST(end-(carry_over-1):end,:)+1;
src_folder='\\cgm10\D\head_pose_estimation\DIEMpng';
dst_folder ='\\cgm10\D\head_pose_estimation\2015_10_25_hard_neg';%'\\cgm10\D\head_pose_estimation\DIEMpng';
addpath(genpath('\\cgm10\Users\ydishon\Documents\Video_Saliency\Dimarudoy_saliency\Dropbox\Matlab\video_attention'));
addpath(genpath('\\cgm10\Users\ydishon\Documents\Video_Saliency\toolbox\pose_estimation'));
NUMIMAGES=-1;% -1 = all in the dataset %100;
SKIP =10;%5;
OFFSET = 30;% to be consistent with Dmitry.
counter = 1;

for ii=1:length(hosts)
    fid=fopen(fullfile(dst_folder,['hard_neg_trainsub_',hosts{ii},filenmsuffix]),'w');
    fprintf(fid,'%d 1\n',0); % dummy value
    foldernms = train_set(counter:counter+(MOVIESPERHOST(ii)-1));
    totnumframes=0;
    for k=1:length(foldernms);
        movie_name_no_ext = foldernms{k};
        gazeinfo=importdata(fullfile(gaze,[movie_name_no_ext,'.mat']),'data');
        for jj=OFFSET:SKIP:length(gazeinfo.points);
            [BB_NEG,BB_POS]=patch_extract([gazeinfo.width,gazeinfo.height],gazeinfo.points{jj},gazeinfo.pointSigma);
            if isempty(BB_NEG) || isempty(BB_POS)
                continue;
            end
            totnumframes=totnumframes+1;
            for pp=1:size(BB_POS,1)
                fprintf(fid,'%s %s\n',...
                    fullfile(src_folder,movie_name_no_ext,sprintf('%06d.png',jj)),num2str(BB_POS(pp,:)));
            end
        end
    end
fclose(fid);
A = regexp( fileread(fullfile(dst_folder,['hard_neg_trainsub_',hosts{ii},filenmsuffix])), '\n', 'split');
A{1} = sprintf('%d 1\n',totnumframes);
fid = fopen(fullfile(dst_folder,['hard_neg_trainsub_',hosts{ii},filenmsuffix]), 'w');
fprintf(fid, '%s\n', A{:});
fclose(fid);
counter = counter + MOVIESPERHOST(ii);
end
