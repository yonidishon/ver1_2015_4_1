output_dir ='\\cgm10\d\DenseTraj_features';
diemDataRoot = '\\CGM41\Users\gleifman\Documents\DimaCode\DIEM';%'Z:\RGB-D\DimaCode\DIEM'; % TODO current on external drive
videos = importdata(fullfile(diemDataRoot, 'list.txt'));
script = 'C:\Users\ydishon\Documents\improved_trajectory_release\VS\Imporved_Trajectories\x64\Release\DenseTrack.exe';
%script = 'DenseTrack.exe';
testIdx = [6,8,10,11,12,14,15,16,34,42,44,48,53,54,55,59,70,74,83,84]; % used by Borji
%cd('C:\Users\ydishon\Documents\improved_trajectory_release\VS\Imporved_Trajectories\x64\Release');
for ii=2:length(testIdx);
    system(sprintf('%s %s.avi > %s.features',script,...
        fullfile(diemDataRoot,'video_unc',videos{testIdx(ii)})...
        ,fullfile(output_dir,videos{testIdx(ii)})));
end
