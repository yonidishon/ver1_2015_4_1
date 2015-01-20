%Show Dimtry CVPR2013 results side-by-side with Gaze

demo_location='\\CGM41\Users\gleifman\Documents\DimaCode\DIEM\cvpr13\demo_video\';
diemDataRoot = '\\CGM41\Users\gleifman\Documents\DimaCode\DIEM';%'Z:\RGB-D\DimaCode\DIEM'; % TODO current on external drive
save_location ='C:\Users\ydishon\Documents\Video_Saliency\20test_DIEM_dima_vs_gaze\';
DataRoot = diemDataRoot; % DIEM dataset is the data
demo_files=dir([demo_location,'*.avi']);
aa=cellfun(@(x)strsplit(x,'_'),{demo_files.name},'UniformOutput',false)';
aa=cellfun(@(x)strjoin(x(1:end-1),'_'),aa,'UniformOutput',false);
bb=unique(aa);
Diem_videos = importdata(fullfile(DataRoot, 'list.txt'));
DIEM_indx=cellfun(@(x)find(x),cellfun(@(x)strcmp(x,Diem_videos),bb,'UniformOutput',false));
%testIdx = [6,8,10,11,12,14,15,16,34,42,44,48,53,54,55,59,70,74,83,84]; % used by Borji
%testSubset = 1:length(testIdx);
movie_numbers=(1:length(bb))';
%% Description of results content
%%%%%%%%%%%% FORMAT %%%%%%%%%%%%%%%%%%%%%%%%%%%
%{DIEMidx} {VIDEO_NAME}
    %{Demoidx}
    %{Description of the gaze vs Dmitry results}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
% 6.  'BBC_life_in_cold_blood_1278x710'
        %Index=1;  
        
        % Gaze is on the center of the frame, the eyes of the animals, movement (the leading part of the movement),
        % and where the people in the scene are looking at.
        % Dmitry results are heavly centered  - movement and frontal face seemed to play the
        % important cue 
        % Some Scenes are followed by closup/open up Scenes (nature film)
        % so the gaze is tracking the same object of interest  - if we
        % could find what was the object in one of the scene we could guess
        % the previous/following scene.
        
% 8.  'BBC_wildlife_serpent_1280x704'
        %Index=2; 
        
        % No conclusion on gaze or Dmitry's results - seemed to be most of
        % the time the center is dominant.
        
% 10.  'DIY_SOS_1280x712'
        %Index=3; 
        
        % Every time the Guy looks at the wood (direct his look at somewhere
        % in the scene the gaze goes there) Dmitry does this quiet successfully.
        % Major cues for gaze - are frontal face, or if side face -> movement 
        
% 11.   'advert_bbc4_bees_1024x576'
        %Index=4;
        
        % The gaze goes for the bees or for the standout motion of a flower
        % Dmitry fails here (always to the center)
        
% 12.   'advert_bbc4_library_1024x576'
        %Index=5;
        
        % Gaze going for the human and movement
        % Dmitry fails completely - doesn't go for the movement of the librarian and only get the center
        
% 14.   'advert_iphone_1272x720'
        %Index=6;
        
        % Gaze goes to text and movement - Dmitry stays in center only
        % (besides baseball game)
        
% 15.   'ami_ib4010_closeup_720x576'
        %Index=7;
        
        % a woman talking with her face - constraint on the face (both)
        % when she looks to the side people look there (text).
        
% 16.   'ami_ib4010_left_720x576'
        %Index=8;
        
        % Two humans - one's talking->moving the other watching him - people looks
        % at the one who's talking - Dmitry's have an offset because of the
        % central bias?
        
% 34.   'harry_potter_6_trailer_1280x544'
        %Index=9;
        
        % Lots of movements/scene cuts and faces - gaze goes to faces and
        % motion unless too much motion and then goes to the center - if
        % there is text (whole words only) - gaze goes there (final
        % seconds)
        
% 42.  'music_gummybear_880x720'
        %Index=10;
        
        % gaze stays in the middle in this cartoon doesn't react much to
        % movement or anything else
        
% 44.  'music_trailer_nine_inch_nails_1280x720'
        %Index=11;
        
        % Again gaze goes to movement,faces and words - Dmitry stays in the
        % middle
        
% 48.  'news_tony_blair_resignation_720x540'
        %Index=12;
        
        % anchor in the TV - gaze on the face besides when there's a bus
        % going by with a text on it, Dmitry stays with the face all the time.
        
% 53.  'nightlife_in_mozambique_1280x580'
        %Index=13;
        
        % Crab movie - gaze goes to the mouse or eyes of the crab (tracking
        % the crab) Dmitry track the middle most of the time
        % When there is to much corase movement (begining of movie) gaze
        % stays in the middle and doesn't go to any of the objects.
        
% 54.  'one_show_1280x712'
        %Index=14;
        
        % Man walks towards camera  - gaze goes to face (ignoring movements of hands) and spatial saliency
        % when man goes towards the house Dmitry has a major failure
        % marking the chimney as the important and ignoring the movement -
        % gaze tracks the movement of human completly.
        
% 55.  'pingpong_angle_shot_960x720'
        %Index=15;
        
        % Ping Pong - gaze trying to track the ball (fast moving object) or
        % the face of the person holding the ball. Dmitry tracks the humans
        % and center
        
% 59.  'pingpong_no_bodies_960x720'
        %Index=16;
        
        % Pingpong with no bodies - gaze tracking the ball and when there
        % is no ball - center - Dmitry stay in center all the time
        
% 70.  'sport_scramblers_1280x720'
        %Index=17;
        
        % Motorcycle stunt movie - gaze on the tattoos and other words and
        % the main object (mostly one) in the scene - different motion from
        % the scene + spatial saliency + people trying to predict where
        % will the biker will emerge from. Dmitry stays in the middle every
        % time in the beginning of the scene and only after 2-3 sec track
        % the main object.
        
% 74.  'sport_wimbledon_federer_final_1280x704'
        %Index=18;
        
        % Tennis Match - gaze focus on players face (closeups), score board
        % (when changes), and on ball (fastest object) or the human objects
        % that doing most movements. Dmitry - 
        
% 83.  'tv_uni_challenge_final_1280x712'
        %Index=19;
        
        %jeopardy TV show - on frontal bias towards faces we've already seen in previous scenes
        %on closeups faces and faces + score (text) on longshots. 
        %Dmitry - faces + center
        
% 84.  'university_forum_construction_ionic_1280x720'
        Index=20;
        
        % Timelapse of construction - gaze - beginning words of movie,
        % later center with random movement towards movement
        % Dmitry - Center.    
%% Loop for creating visualization of results        
for Index=1:length(bb)
    fprintf('Index right now is %i, Writing Movie %s\n',Index,bb{Index});
    dima_video_nm=[demo_location,bb{Index},'_ours.avi'];
    gaze_video_nm=[demo_location,bb{Index},'_gaze.avi'];
    orig_video_nm=[demo_location,bb{Index},'_video.avi'];
    
    dima_vobj=VideoReader(dima_video_nm);
    gaze_vobj=VideoReader(gaze_video_nm);
    orig_vobj=VideoReader(orig_video_nm);
    result_wobj=VideoWriter([save_location,bb{Index},'_DvG.mp4'],'MPEG-4');
    open(result_wobj);
    %h=figure('Name',bb{Index});
    pos=[50,orig_vobj.Height-50];
    for ii=1:min(gaze_vobj.NumberOfFrames,dima_vobj.NumberOfFrames)

        orig_frameembed=insertText(read(orig_vobj,ii),pos,'Orig','FontSize',18);
        gaze_frameembed=insertText(read(gaze_vobj,ii),pos,'Gaze','FontSize',18);
        dima_frameembed=insertText(read(dima_vobj,ii),pos,'Dima','FontSize',18);
        compused_image=[orig_frameembed;gaze_frameembed;dima_frameembed];
        clear orig_frameembed gaze_frameembed dima_frameembed
        %imagesc(imresize(compused_image,[size(compused_image,1)/3,size(compused_image,2)]));
        %title('Gaze on the Middle Dimtry''s on the Bottom');
        %drawnow;
        finalFrame=imresize(compused_image,[size(compused_image,1)/3,round(size(compused_image,2)/3)]);
        writeVideo(result_wobj,finalFrame);
    end
    close(result_wobj);
    %close(h);
end
%% Prove Ran the visualization is correct    
Index=10;
    fprintf('Index right now is %i, Writing Movie %s\n',Index,bb{Index});
    dima_video_nm=[demo_location,bb{Index},'_ours.avi'];
    gaze_video_nm=[demo_location,bb{Index},'_gaze.avi'];
    vimeo_video_nm=[save_location,bb{Index},'_vimeo.mp4'];
    
    dima_vobj=VideoReader(dima_video_nm);
    gaze_vobj=VideoReader(gaze_video_nm);
    orig_vobj=VideoReader(vimeo_video_nm);
    result_wobj=VideoWriter([save_location,bb{Index},'_gaze_vs_vimeogaze.mp4'],'MPEG-4');
    open(result_wobj);
    %h=figure('Name',bb{Index});
    pos=[50,orig_vobj.Height-50];
    for ii=1:min(gaze_vobj.NumberOfFrames,dima_vobj.NumberOfFrames)

        orig_frameembed=insertText(read(orig_vobj,ii+60),pos,'Gaze From Vimeo','FontSize',18);
        gaze_frameembed=insertText(imresize(read(gaze_vobj,ii),[orig_vobj.Height,orig_vobj.Width]),pos,'Gaze','FontSize',18);
        dima_frameembed=insertText(imresize(read(dima_vobj,ii),[orig_vobj.Height,orig_vobj.Width]),pos,'Dima','FontSize',18);
        compused_image=[orig_frameembed;gaze_frameembed;dima_frameembed];
        clear orig_frameembed gaze_frameembed dima_frameembed
        %imagesc(imresize(compused_image,[size(compused_image,1)/3,size(compused_image,2)]));
        %title('Gaze on the Middle Dimtry''s on the Bottom');
        %drawnow;
        finalFrame=imresize(compused_image,[size(compused_image,1)/3,round(size(compused_image,2)/3)]);
        writeVideo(result_wobj,finalFrame);
    end
    close(result_wobj);
    %close(h);