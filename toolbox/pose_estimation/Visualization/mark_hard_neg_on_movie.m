% Yonatan 26/10/2015
% script to produce movie with hard negative on it

% Folder with hard negative info on
fold = 'D:\head_pose_estimation\2015_10_25_hard_neg';
% Gaze information
gaze = '\\cgm10\D\DIEM\gaze';
% prefix of files with hard negative information in them
prefix = 'train_hard_neg_new';
files=dir(fullfile(fold,[prefix,'*']));
%for each files
wobj = VideoWriter(fullfile(fold,'hard_neg_vis.mp4'),'MPEG-4');
wobj.FrameRate = 30/10;
open(wobj);
for ii=1:length(files)
    %open file
    fid = fopen(fullfile(fold,files(ii).name),'r');
    % get first line
    tline = fgetl(fid);
    % get fullpath to image
    str1 = strsplit(tline,' ');
    % get video file
    fr = imread(str1{1});
    tmp = cellfun(@(x)str2double(x),str1(2:end));
    patches = [];
    vidnametmp = strsplit(str1{1},'\');vidname = vidnametmp{end-1};
    frnum = strsplit(vidnametmp{end},'.');frnum=str2double(frnum{1});
    gazeinfo=importdata(fullfile(gaze,[vidname,'.mat']),'data');
    frwgaze=gazetoheatmap(fr,gazeinfo.points{frnum},gazeinfo.pointSigma);
    while ischar(tline)    
        str2 = strsplit(tline,' ');
        % get gazeinfo

        if strcmp(str1{1},str2{1}) % still on the same frame
            tmp = cellfun(@(x)str2double(x),str2(2:end));
            patches=[patches;[tmp(1:2)+1,tmp(3:4)-tmp(1:2)]];
        else
            %writeVideo(wobj,insertShape(fr,'FilledRectangle',patches));
            writeVideo(wobj,imresize(im2rgb(insertShape(frwgaze,'FilledRectangle',patches)),[480,640]));
            vidnametmp2 = strsplit(str2{1},'\');vidname2 = vidnametmp2{end-1};
            if (~strcmp(vidnametmp2,vidnametmp))
                 gazeinfo=importdata(fullfile(gaze,[vidname,'.mat']),'data');
                 vidnametmp=vidnametmp2;
            end
            str1=str2;
            % read frame and extract gaze
            fr = imread(str1{1});
            vidnametmp = strsplit(str1{1},'\');vidname = vidnametmp{end-1};
            frnum = strsplit(vidnametmp{end},'.');frnum=str2double(frnum{1});
           
            frwgaze=gazetoheatmap(fr,gazeinfo.points{frnum},gazeinfo.pointSigma);
            %open new patches list
            tmp = cellfun(@(x)str2double(x),str2(2:end));
            patches = [tmp(1:2)+1,tmp(3:4)-tmp(1:2)];
        end
        tline = fgetl(fid);
    end
    writeVideo(wobj,imresize(im2rgb(insertShape(frwgaze,'FilledRectangle',patches)),[480,640,3]));
end
close(wobj);