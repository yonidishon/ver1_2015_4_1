%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compute number of cuts feature
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc;
close all;
clear all;

Automatic_Cuts = [];
Chi2_Values = [];
Num_bins = 256;

Root_Path = '/common/sara/Video/';                      % Video root directory
Path_Extraction_Frames = '/tmp/sara/';

Subdirectory = dir(Root_Path);
Num_Category = length(Subdirectory);

Size_Half_Win = 10;                                     %
Low_Threshold = 0.05;                                   %
High_Threshold = 0.15;                                  %

%% Processing all the categories
for b=4:4%Num_Category

    fprintf(1,'Processing category...%s\n\n',Subdirectory(b).name);

    if ((Subdirectory(b).name(1) ~= '.') && (Subdirectory(b).name(1) ~= 'K') && (Subdirectory(b).name(1) ~= 'i') && (Subdirectory(b).name(1) ~= 'D'))

        Path = [Root_Path Subdirectory(b).name,'/'];
        Video_Files = dir([Root_Path Subdirectory(b).name,'/*.avi']);
        Num_Videos = length(Video_Files);

        Total_Automatic_Cuts = zeros(1,Num_Videos);
%         Gray_Histograms = [];
%         Chi2 = [];
%         Chi2_Win = [];
%         Measure = [];
%         Measure_Win = [];
        
%% Processing all the videos of the current category        
        for a=1:Num_Videos
            
            fprintf(1,'Processing video...%s\n\n',Video_Files(a).name);
            
%             if (exist([Path_Extraction_Frames,'1.png']))
                
%% Compute video frame size
                Video_Info = aviinfo([Root_Path Subdirectory(b).name,'/',Video_Files(a).name]);
                mpixels = Video_Info.Width;
                npixels = Video_Info.Height;
                dimImage = mpixels * npixels;

%% Compute frame histograms of the current video
                Gray_Histograms = ComputeGrayHistograms([Root_Path Subdirectory(b).name],Video_Files(a).name,Path_Extraction_Frames,Num_bins);

%% Compute Chi2 values of the current video                
                Chi2 = ComputeChi2(Gray_Histograms,dimImage);
                Measure = Chi2;

%% Compute Chi2 values for the window detection 
%% (window size = 2*Size_Half_Win)                
                Chi2_Win = Chi2WindowDetection(Size_Half_Win,Gray_Histograms,dimImage);
                Measure_Win = Chi2_Win;

%% Use workspace istead computing all the  "Chi2Video" and "Chi2Win" values in real-time     
                %     load([Root_Path,'Chi2Video',int2str(a),'.mat']);
                %     Measure = Chi2;
                %     load ([Root_Path,'Chi2Win',int2str(a),'.mat']);
                %     Measure_Win = Chi2_Win;

%% Cuts detection                
                [Automatic_Cuts,Chi2_Values] = FindCutFade(Measure,Low_Threshold,High_Threshold,Path,a,Measure_Win);
                Number_Automatic_Cuts = length(Automatic_Cuts);
                Total_Automatic_Cuts(a) = Number_Automatic_Cuts;

%             end

        end

%% Save data        
        Name_Dir = ['/common/sara/CutDetection/Total_Automatic_Cuts_',Subdirectory(b).name,'.mat'];
        save(Name_Dir,'Total_Automatic_Cuts','Automatic_Cuts');

    else
        disp('skip folder...');
    end

end

