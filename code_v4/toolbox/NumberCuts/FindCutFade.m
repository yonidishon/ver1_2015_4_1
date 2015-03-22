%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find cuts/fades in-out in a specific video
%
% Input
%           - Chi2:            Chi2 values vector about training videos
%           - Low_Threshold:   threshold for finding the video cuts
%           - High_Threshold:  threshold for finding the video fades
%           - Root_Path:       Video frames path
%           - Video_Index:     Processing video number
%           - Chi2_Win:        Chi2 values used in the window detection
% Output
%           - Automatic_Cuts:  Automatic cuts founded in the training videos
%           - Chi2_Values:     Automatic cut Chi2 values
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [Automatic_Cuts,Chi2_Values] = FindCutFade(Chi2,Low_Threshold,High_Threshold,Root_Path,Video_Index,Chi2_Win)

nChi2_Values = length(Chi2);                            % Number of Chi2 values
Size_Half_Win = 10;                                     % Size for window detection
Cuts = [];
Chi2_Values = [];

%% PROCESS CHI2 (1 video at time)
%  Test if Frame1 and Frame2 belong at 2 different shots
%  (between k-1 and k)
    for a=1:nChi2_Values                                % Process all current video frames

        if (Chi2(a) < Low_Threshold)                    % No cut detected
        % 'No cut!!!'
        % Continue
        else                                            % Possible cut/fade detection
            if (Chi2(a) < High_Threshold)               % Possible fade in/out
                Current_Frame = a;
                                                        % Find fade with window detection
                if (Size_Half_Win >= a)
                    Size_Half_Win = a - 1;    
                else
                    if (Size_Half_Win > (nChi2_Values-a))
                        Size_Half_Win = nChi2_Values - a;
                    end
                end

                Chi2_Differences = [];      
                % Chi2_Differences = WindowDetection(Size_Half_Win, Current_Frame, Root_Path,Video_Index);
                
                % New modify
                Chi2_Differences = [diag(Chi2_Win(Size_Half_Win:-1:1,Current_Frame-Size_Half_Win:Current_Frame-1))' Chi2_Win(1:Size_Half_Win,Current_Frame)'];
                % End new modify
                
                [Rank_Chi2,Index] = sort(Chi2_Differences);
                Find_PreFrame = 0;
                if( find(Index(1:Size_Half_Win) > Size_Half_Win) )
                    Find_PreFrame = 1;
                end

                if (Find_PreFrame == 0)                 % Fade in-out detected
%                 disp('Find a fade in-out');
%                 disp(['Video ',int2str(b),' frame ',int2str(a),' Find a fade in-out']);
                    Cuts(a) = a;
                    Chi2_Values(a) = Chi2(a);
                else
                    % 'No cut!!!'
                    % Continue
                end

            else                                        % Cut detected
%                 disp('Find a cut');
%                 disp(['Video ',int2str(b),' frame ',int2str(a),' Find a cut!']);
                Cuts(a) = a;
                Chi2_Values(a) = Chi2(a);
            end
        end

    end

Automatic_Cuts = Cuts(find(Cuts~=0));                   % Create automatic cuts vector
Chi2_Values = Chi2_Values(find(Cuts~=0));               % Create Chi2 automatic cuts vector