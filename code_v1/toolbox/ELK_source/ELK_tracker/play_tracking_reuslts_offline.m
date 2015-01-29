function play_tracking_reuslts_offline(viddir,resdir,seq)
global h;

resfiles = dir(fullfile(resdir,[seq '*.txt']));
res = load(fullfile(resdir,resfiles(end).name));
h.gt = [];
try
    h.gt = load(fullfile(viddir,seq,'groundtruth_rect.txt'));
end
h.imdir = fullfile(viddir,seq,'img');
h.frm = 1;
h.frm_list = get_frame_list(h.imdir);
im = imread(fullfile(h.imdir,h.frm_list(1).name));
h.fig = figure('KeyPressFcn',{@my_key_press,res});
imshow(im);
h.ax = gca;
h.im = findobj(h.ax,'type','image');
axis off;axis tight;axis equal;
set(h.ax,'position',[0,0,1,1]);
if ~isempty(h.gt)
    h.gtbox = rectangle('position',h.gt(1,1:4),'linewidth',1,'linestyle','--','edgecolor','g');
end
h.bbox = rectangle('position',res(1,2:5),'linewidth',2.5,'edgecolor',[1,0.5,0]);
h.txt = text(10,20,num2str(0),'color',[1 1 0],'FontSize',14);
h.play = 0;
h.fps = 20;

function my_key_press(obj,evnt,res)
global h;

if h.play
    h.play = 0;
    evnt.Key = 'noKey';
end
switch evnt.Key
    case {'rightarrow','numpad6'}
        h.frm = min(h.frm+1,max(size(res,1),size(h.gt,1)));
        update_image(res);
    case {'leftarrow','numpad4'}
        h.frm = max(h.frm-1,1);
        update_image(res);
    case {'home','numpad7'}
        h.frm = 1;
        update_image(res);
    case {'end','numpad1'}
        h.frm = max(size(res,1),size(h.gt,1));
        update_image(res);
    case {'escape'}
        close(h.fig);
    case {'p'}
        h.play = 1;
        while h.play && h.frm <= max(size(res,1),size(h.gt,1))
            t = tic;
            update_image(res);
            h.frm = h.frm+1;
            dt = toc(t);
            if dt<1/h.fps
                pause(1/h.fps-dt);
            end
        end
        h.play = 0;
    case {'f'}
        answer = inputdlg('Set frame rate (fps):','Set frame rate',1,{num2str(h.fps)});
        if ~isempty(answer{1})
            try
                h.fps = str2num(answer{1});
            end
        end
    case {'g'}
        answer = inputdlg(sprintf('Go to frame (0-%d):',size(res,1)-1),...
            'Go to frame:',1,{num2str(h.frm)});
        if ~isempty(answer{1})
            try
                n = str2num(answer{1});
                h.frm = min(max(0,n),size(res,1)-1);
            end
        end
        update_image(res);
end

function update_image(res)
global h;

n = h.frm;
im = imread(fullfile(h.imdir,h.frm_list(n).name));
set(h.im,'cdata',im);
if ~isempty(h.gt)
    set(h.gtbox,'position',h.gt(n,1:4));
end
if size(res,1)>=n && all(res(n,2:5)>0)
    set(h.bbox,'position',res(n,2:5));
    set(h.txt,'string',num2str(h.frm));
else
    set(h.bbox,'position',[0,0,1,1]);
    set(h.txt,'string',[num2str(h.frm) '- NO BBOX!']);
end
drawnow;