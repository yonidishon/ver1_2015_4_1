% Visualization for determine if the blockiness is due to the x and y in th
% e regression
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                   %               %              %              %
%   GT_CLUSTERED    %   VIS_0_1     %   VIS_0_2    %    VIS_0_3   %
%                   %               %              %              %  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                   %               %              %              %
%       FRAME       %   VIS_1_1     %   PCAS       %    PCAM      %
%                   %               %              %              %
VIS_0_1 = '\\cgm10\D\Video_Saliency_Results\FinalResults3\TreeEnsamble_v7_w_SpMo_patch_cluster';
VIS_0_1_TEXT ='Patches(7x7) CL 50%';
VIS_0_2 = '\\cgm10\D\Video_Saliency_Results\FinalResults3\TreeEnsamble_v5_clean_w_SpMo_all';
VIS_0_2_TEXT ='Pixel NN';
VIS_0_3 = '\\cgm10\D\Video_Saliency_Results\FinalResults3\TreeEnsamble_v5_1_w_SpMo_patch_cluster';
VIS_0_3_TEXT ='Patches(7x7) CL Rand';
VIS_1_1 = ;
VIS_1_1_TEXT ='';
VIDEO_LOC='\\cgm41\users\gleifman\Documents\DimaCode\DIEM\video_unc';
OF_LOC='\\cgm10\D\Video_Saliency_cache_Backup';
GAZE_LOC='\\cgm10\D\DIEM\gaze';
VISDST = VIS_0_2;
addpath(genpath('\\cgm10\Users\ydishon\Documents\Video_Saliency\code_v3\toolbox\PCA_Saliency'));
files=dir([VIS_0_3,'\*.mat']);
files=files(1:2:end);
 
FRMS_CNT=300;
% h=figure('Visible','off');
reverseStr = '';
wobj=VideoWriter(fullfile(VISDST,'Reg_Patch_NN_and_Global_rand_vs_half.mp4'),'MPEG-4');
open(wobj);
% frame_size=[540,2880];
frame_size=[540,960];
pos=[10,10];
%figure();
for ii=1:size(files)
    file_no_end=strsplit(files(ii).name,'.');file_no_end=file_no_end{1};
    msg=sprintf('working on %s\r',files(ii).name);
    fprintf([reverseStr, msg]);reverseStr = repmat(sprintf('\b'), 1, length(msg));
    predMaps_w_x_y=load(fullfile(VIS_0_2,files(ii).name),'predMaps_tree');
    predMaps_w_x_y=predMaps_w_x_y.predMaps_tree;
    predMaps_wo_x_y=load(fullfile(VIS_0_3,files(ii).name),'predMaps_tree');
    predMaps_wo_x_y=predMaps_wo_x_y.predMaps_tree;
    predMaps_wo_x_y_v8_2=load(fullfile(VIS_0_1,files(ii).name),'predMaps_tree');
    predMaps_wo_x_y_v8_2=predMaps_wo_x_y_v8_2.predMaps_tree;
    predMaps_VIS_1_1=load(fullfile(VIS_1_1,files(ii).name),'predMaps_tree');
    predMaps_VIS_1_1=predMaps_VIS_1_1.predMaps_tree;
    gazefile=load(fullfile(GAZE_LOC,[file_no_end,'.mat']));
    gazefile=gazefile.data;
    vobj=VideoReader(fullfile(VIDEO_LOC,[file_no_end,'.avi']));
    start_frm=1;
    frms=start_frm:start_frm+FRMS_CNT-1;
    frames=read(vobj,[frms(1)+30,frms(end)+30]);
    predMaps_w_x_y=predMaps_w_x_y(:,:,frms);
    predMaps_wo_x_y=predMaps_wo_x_y(:,:,frms);
    predMaps_wo_x_y_v8_2=predMaps_wo_x_y_v8_2(:,:,frms);
    predMaps_VIS_1_1=predMaps_VIS_1_1(:,:,frms);
    result_frame=zeros(2*size(frames,1),size(frames,2)*3);
    [m,n,~,~]=size(frames);
    [X,Y]=meshgrid(1:n,1:m);
    for jj=1:FRMS_CNT
        gzpoints=gazefile.points{frms(jj)};
        gazePts = gzpoints(~isnan(gzpoints(:,1)), :);
        gazedensemap=points2GaussMap(gazePts', ones(1, size(gazePts, 1)), 0, [n m], gazefile.pointSigma);
        if ~isempty(gazePts)
            [~,D] = knnsearch([gazePts(:,2),gazePts(:,1)],[Y(:),X(:)]);
            gazeindimap=reshape(exp((-(D./gazefile.pointSigma).^2)./2),m,n);
        else
            gazeindimap=gazedensemap;
        end
        gazedensemap=insertText(repmat(im2uint8(imadjust(gazedensemap,stretchlim(gazedensemap),[])),1,1,3),pos,'GT clustered','FontSize',8);
        gazeindimap=insertText(repmat(im2uint8(imadjust(gazeindimap,stretchlim(gazeindimap),[])),1,1,3),pos,'GT local','FontSize',8);
        tmpframe=insertText(frames(:,:,:,jj),pos,{files(ii).name},'FontSize',8);
        tmppredMaps_w_x_y=insertText(repmat(im2uint8(imadjust(predMaps_w_x_y(:,:,jj),stretchlim(predMaps_w_x_y(:,:,jj)),[])),1,1,3),pos,VIS_0_2_TEXT,'FontSize',8);
        tmppredMaps_wo_x_y=insertText(repmat(im2uint8(imadjust(predMaps_wo_x_y(:,:,jj),stretchlim(predMaps_wo_x_y(:,:,jj)),[])),1,1,3),pos,VIS_0_3_TEXT,'FontSize',8);
        fdata=importdata(fullfile(OF_LOC,[file_no_end,'.avi'],sprintf('frame_%06d.mat',start_frm+30+jj-1)),'data');
        rColor=insertText(repmat(im2uint8(imadjust(predMaps_wo_x_y_v8_2(:,:,jj),stretchlim(predMaps_wo_x_y_v8_2(:,:,jj)),[])),1,1,3),pos,VIS_0_1_TEXT,'FontSize',8);
        tmppredMaps_VIS_1_1=insertText(repmat(im2uint8(imadjust(predMaps_VIS_1_1(:,:,jj),stretchlim(predMaps_VIS_1_1(:,:,jj)),[])),1,1,3),pos,VIS_1_1_TEXT,'FontSize',8);
        
        [~,rSpatial,rMotion] = PCA_Saliency_all(fdata.ofx,fdata.ofy,frames(:,:,:,jj));
        rSpatial=insertText(repmat(im2uint8(imadjust(rSpatial,stretchlim(rSpatial),[])),1,1,3),pos,'Spatial','FontSize',8);
        rMotion=insertText(repmat(im2uint8(imadjust(rMotion,stretchlim(rMotion),[])),1,1,3),pos,'Motion','FontSize',8);
        
        result_frame=[gazedensemap,rColor,tmppredMaps_w_x_y,tmppredMaps_wo_x_y;tmpframe,tmppredMaps_VIS_1_1,rSpatial,rMotion];
        writeVideo(wobj,imresize(result_frame,frame_size));
    end
end;
close(wobj);

