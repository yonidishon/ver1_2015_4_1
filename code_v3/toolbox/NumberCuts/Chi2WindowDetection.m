%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compute Chi2 values for a specific video for the window detection
%
% Input
%           - Size_Half_Win:    Dimension of the window detection
%           - Histograms:       Histogram values of the video frames
%           - dimImage:         Dimension of the video frame
% Output
%           - Chi2_Win:         Chi2 values
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function Chi2_Win = Chi2WindowDetection(Size_Half_Win,Histograms,dimImage);

nBins = 256;
EPS1 = 0.01;
Num_Frames = size(Histograms,2);

Chi2_Win = zeros(Size_Half_Win,Num_Frames-1);

%% fade
for a=1:Size_Half_Win
    
    EPS = ones(nBins,Num_Frames-a)*EPS1;                           % vector of EPS = 0.01
    H1 = Histograms(:,1:Num_Frames-a);
    H2 =  Histograms(:,a+1:Num_Frames);
    denominator = max(cat(3,H1,H2,EPS),[],3);
    Chi2_Win(a,1:Num_Frames-a) = sum( ((H1 - H2).^2) ./ denominator )/dimImage;   % Compute Chi2 difference
    
end