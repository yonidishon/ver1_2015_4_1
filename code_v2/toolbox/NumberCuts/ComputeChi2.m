%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compute Chi2 Values for a specific video
%
% Input
%           - Histograms:       Video frame histograms
%           - dimImage:         Frame size (240x360)
% Output
%           - Chi2:             Video Chi2 values
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function Chi2f = ComputeChi2(Histograms,dimImage);

nBins = 256;
EPS1 = 0.01;
Num_Frames = size(Histograms,2);

Chi2 = zeros(1,Num_Frames-1);

%% Compute Chi2 values
EPS = ones(nBins,Num_Frames-1)*EPS1;                           % vector of EPS = 0.01
H1 = Histograms(:,1:Num_Frames-1);
H2 =  Histograms(:,2:Num_Frames);
denominator = max(cat(3,H1,H2,EPS),[],3);
Chi2(1:Num_Frames-1) = sum( ((H1 - H2).^2) ./ denominator )/dimImage;   % Compute Chi2 difference