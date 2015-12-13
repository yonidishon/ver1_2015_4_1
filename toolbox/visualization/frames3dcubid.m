% YOU NEEED TO ADJUST THIS FUNCTION IN ORDER TO READ OTHER MOVIES - SAVE
% AND INTERAPT THE INTERVAL TO PUT THE MOVIE IN 

offset=0;
numofframes=1020;
interval = 30;
% figure();
for ii=1:numofframes
    gazemaps(:,:,ii)=points2GaussMap(data.points{ii+offset}',ones([1 size(data.points{ii+offset})]),0,[data.width data.height],10);
%     imshow(gazemaps(:,:,ii));
%     drawnow;
end
vobj=VideoReader('d:\DIEM\video_unc\ami_ib4010_closeup_720x576.avi');
frames=read(vobj,offset+[1 numofframes]);
X=repmat((1:data.width)',1,(data.height)*numofframes/interval)';
Y=permute(repmat(permute(1:interval:numofframes,[1 3 2]),data.height,data.width),[2,1,3]);
Y=Y(:,:)';
Z=repmat(repmat((1:data.height)',1,data.width),numofframes/interval,1);
Cforalpha=permute(gazemaps(:,:,1:interval:numofframes),[2,1,3]);Cforalpha=Cforalpha(:,:)';
Cr=permute(squeeze(frames(:,:,1,1:interval:numofframes)),[2,1,3]);Cr=Cr(:,:)';
Cg=permute(squeeze(frames(:,:,2,1:interval:numofframes)),[2,1,3]);Cg=Cg(:,:)';
Cb=permute(squeeze(frames(:,:,3,1:interval:numofframes)),[2,1,3]);Cb=Cb(:,:)';
C=cat(3,Cr,Cg,Cb);
videocube=surf(X,Y,Z,C);
set(gca,'Zdir','reverse')
set(videocube, 'EdgeColor','none','FaceAlpha','flat','AlphaDataMapping','scaled','AlphaData',Cforalpha);
box on;axis tight;
view(-80,40);