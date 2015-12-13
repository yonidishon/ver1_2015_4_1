%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Extract frames of a specific input video
%
% Input             - Root_Path:                root path where find videos
%                   - video:                    name of the video which you want extraxt the
%                                               frames
%                   - Path_Extraction_Frames:   Directory where extract all the
%                                               frames of the considered video
%                   - Step_Seconds:             [optional] Step time at which extracting
%                                               the video frames
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function ExtractFrameOneVideo(Root_Path,video,Path_Extraction_Frames,Step_Seconds)

Current_Path = pwd;             % Current path       

%% Change path for launching "ffmpeg" command 
cmd = ['cd ',Root_Path];
evalc(cmd);

%% If doesn't exist, create the directory where extract the video frames
if (~exist(Path_Extraction_Frames))
    cmd4 = ['!mkdir ',Path_Extraction_Frames];
    evalc(cmd4);
else
    cmd4 = ['!rm ',Path_Extraction_Frames,'*.*'];
    evalc(cmd4);
end

%% Extract video frames
if (nargin > 3)                 % Extract 1 frame each 'Step_Seconds'
    
    cmd3 = ['!ffmpeg -i ',video,' -vcodec png -ss ',int2str(Step_Seconds),' -an -f image2 -r 1/',int2str(Step_Seconds),' /tmp/sara/%d.png'];
    evalc(cmd3);
    
else                            % Extract all the video frames

    cmd3 = ['!ffmpeg -i ',video,' -vcodec png -an -f image2 /tmp/sara/%d.png'];
    evalc(cmd3);
    
end

%% Return at the original path
cmd4 = ['cd ',Current_Path];
evalc(cmd4);