% run_convertGazeCRCNS
%% settings
dataRoot = '\\cgm10\D\Competition_Dataset\CRCNS\CRCNS-DataShare\data-orig';
outRoot = '\\cgm10\D\Competition_Dataset\CRCNS';
outGazeRoot = fullfile(outRoot, 'gaze');
videoRoot = '\\cgm10\D\Competition_Dataset\CRCNS\CRCNS-DataShare\stimuli';
fid=fopen('MPGSIZES.txt','r');
 C = textscan(fid,'%s %d');
 
 videos = C{1};
 fclose(fid);
 vid_idx = [5,6,8,10,11,15,18,19,21,26,27,40,41,45,46,49,50]; % fixation Bank subset
 nv = numel(vid_idx);
 videos = videos(vid_idx);
scale = 2; % 480 -> 240

startOffset = 271;
smpPerFrame = 8;
dataC = [639/2, 479/2]; % center of the screen in gaze tracker

% gaze -> data, height, width, length

%% prepare
s = dir(dataRoot);
ns = length(s) - 2;% remove . and ..
subjects = cell(ns, 1);
for i = 1:ns
    subjects{i} = s(i+2).name;
end

%% convert gaze data
for iv = 1:nv
    fprintf('Processing %s... \n', videos{iv}); tic;
    
    % video data
    vr = VideoReader(fullfile(videoRoot, sprintf('%s', videos{iv})));
    read(vr,Inf);
    gaze.height = vr.Height/scale;
    gaze.width = vr.Width/scale;
    gaze.length = vr.NumberOfFrames;
    clear vr;
    c = [gaze.width/2, gaze.height/2];
    
    % parse gaze tracker data
    gaze.data = cell(gaze.length, 1);
    for ifr = 1:gaze.length
        gaze.data{ifr} = nan(ns, 2);
    end
    nam = strsplit(videos{iv},'.');nam = nam{1};
    for i = 1:ns % for every subject
        
        gf = fullfile(dataRoot, subjects{i}, sprintf('%s.e-ceyeS', nam));
        if (exist(gf, 'file'))
            gd = importdata(gf, ' ', 3);
            
            rawData = gd.data(startOffset:end, [1,2,4]);
            nfr = min(gaze.length, floor(size(rawData, 1) / smpPerFrame));
            
            for ifr = 1:nfr
                frData = rawData((ifr-1)*smpPerFrame+1:ifr*smpPerFrame, :);
                ind = (frData(:,3) == 0 | frData(:,3) == 2); % fixations only
                if (any(ind))
                    pt = mean(frData(ind, 1:2), 1);
                    gaze.data{ifr}(i, :) = (pt - dataC) ./ scale + c;
                end
            end
        end
    end
    
    save(fullfile(outGazeRoot, sprintf('%s.mat', nam)), 'gaze');
    
    fprintf('%f sec\n', toc);
end
