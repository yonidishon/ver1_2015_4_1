%Script to loading movie and showing a cut in the 00_faces.mat file
clear all;close all;clc;
DIEMpath='\\CGM41\Users\gleifman\Documents\DimaCode\DIEM\video_unc\';
faces_stct=load('00_faces.mat','faces');
faces_stct=faces_stct.faces;
videos_stct=load('00_gaze.mat','videos');
videos_stct=videos_stct.videos;

%chose video randomally and insert text to show scene cut
r=randi(84);
video_name=videos_stct{r};
frame_cuts=faces_stct{r}.cuts;
vo=VideoReader([DIEMpath,video_name,'.avi']);
h=figure('Name',video_name);
for ii=1:4:vo.NumberOfFrames
    frame=read(vo,ii);
    if (numel(frame_cuts)>0 && ii>=frame_cuts(1)  ) % this frame is cut frame
        position=[round(vo.Width/2-60),round(2*vo.Height/3)];
        imagesc(insertText(frame,position,'Frame_cut',...
            'TextColor','yellow','FontSize',20));
        drawnow;
        pause(0.2);
        title(sprintf('Frame#%i Next framecut at %i',ii,frame_cuts(1)));
        frame_cuts=frame_cuts(2:end);%take one out
    else
       imagesc(frame);
       if numel(frame_cuts)>0
            title(sprintf('Frame#%i Next framecut at %i',ii,frame_cuts(1)));
       else
           title(sprintf('Frame#%i Next framecut at %s',ii,'end_of_movie'));
       end
       drawnow
    end
end
close(h);
fprintf('Finish to view movie %s\n',video_name);