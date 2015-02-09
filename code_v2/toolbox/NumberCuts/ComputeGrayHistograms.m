%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compute frame histograms (BN) of a specific video
%
% Input
%           - Video_Directory:          Directory where is stored the video to
%                                       process
%           - Video:                    Name of the video to process
%           - Path_Extraction_Frames:   Directory where extract all the
%                                       frames of the considered video
%           - Num_bins:                 Number of bin considered to
%                                       compute the colors histograms
% Output
%           - Gray_Histograms:          Frame histograms of the
%                                       entire video
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function Gray_Histograms = ComputeGrayHistograms(Video_Directory,Video,Path_Extraction_Frames,Num_bins);

% Num_bins = 256;
%% Extract all the video frames            
ExtractFrameOneVideo(Video_Directory,Video,Path_Extraction_Frames);

Video_Frames = dir([Path_Extraction_Frames,'*.png']);       % List of video frames
Num_Video_Frames = length(Video_Frames);                    % Video number frames

Gray_Histograms = zeros(Num_bins,Num_Video_Frames);         % Init matrix

%% Process all video frames
for a=1:Num_Video_Frames                                    
    Frame1 = [];
    Hist1 = [];
    Frame1grey = [];
    Name_Frame1 = [int2str(a),'.png'];
    Frame1 = imread([Path_Extraction_Frames Name_Frame1]);

%% Compute current frame histogram (BN - 256bins) 
    Frame1grey = rgb2gray(Frame1);                          
    Hist1 = imhist(Frame1grey,Num_bins);
    Hist1 = Hist1/sum(Hist1);
    Gray_Histograms(:,a) = Hist1;
end

%% Remove all the video frames
if (Num_Video_Frames < 5000)
    cmd = ['!rm ',Path_Extraction_Frames,'*.png'];
    evalc(cmd);
else
    file_png = dir([Path_Extraction_Frames,'*.png']);
    for h=1:Num_Video_Frames
        delete([Path_Extraction_Frames file_png(h).name]);
    end
end