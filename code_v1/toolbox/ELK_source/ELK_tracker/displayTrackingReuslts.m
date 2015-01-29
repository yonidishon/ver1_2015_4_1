%% ======================================================================================
% Display tracking results
%
% [] = displayTrackingReuslts(I,target,frame,Tout)
%
% Input:
%   I - Image
%   target - Current target structure
%   frame - Frame number
%
% Output:
%
% Writen by: Shaul Oron
% Last update: 17/07/2011
% Debuged on: Matlab 7.11.0 (R2010b)
%
% shauloron@gmail.com
% Computer Vision & Image Processing Lab
% School of Electrical Engineering, Tel-Aviv University, Israel
% =======================================================================================

function [prm] = displayTrackingReuslts(I,target,frame,prm,action,gt_rect)

v = target.verticesOut;
switch lower(prm.mode)
    case 'tr'
        clr = [0.1,0.75,0.1];
    case 'tr-scl'
        clr = [0,1,0];
    case 'occ-trk'
        clr = [1,0.5,0];
    case 'occ-lost'
        clr = [1,0,0];
    case 'zoh'
        clr = [1,1,0];
end
if ~isfield(prm,'fig') || isempty(prm.fig)
    
    prm.fig = figure(10);
    set(prm.fig,'WindowKeyPressFcn',@MyKeyPress);
    imagesc(I);colormap gray; axis image;
    prm.img = findobj(prm.fig,'Type','image');
    axis off;axis image;
    set(gca,'Unit','normalized','Position',[0 0 1 1]);
    prm.line = line([v(1,:),v(1,1)],[v(2,:),v(2,1)],'color',clr,'linewidth',2.5);
    prm.act_txt = text(v(1,1),v(2,1)-10,sprintf('%s',prm.mode),'color',clr,'FontSize',13,'fontweight','bold');
    prm.txt = text(10,20,num2str(frame),'color',[1 1 0],'FontSize',14);
    if exist('gt_rect','var') && ~isempty(gt_rect)
        prm.line_gt =rectangle('position',gt_rect,'EdgeColor',[1 0 1]);
    end
else
    set(prm.img,'cdata',I);
    set(prm.line,'xdata',[v(1,:),v(1,1)],'ydata',[v(2,:),v(2,1)],'color',clr);
    set(prm.act_txt,'string',sprintf('%s',prm.mode),'position',[v(1,1),v(2,1)-10],'color',clr);
    set(prm.txt,'string',sprintf('Frame %d',frame));
    if exist('gt_rect','var') && ~isempty(gt_rect)
        set(prm.line_gt,'Position',gt_rect);
    end
end

    
drawnow;