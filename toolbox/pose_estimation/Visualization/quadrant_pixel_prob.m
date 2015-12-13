%hist3  of quadrants
src_fold = '\\cgm10\d\head_pose_estimation\Train_vis_15';
is_dir = cell2mat(extractfield(dir(src_fold),'isdir'));
avail_ch = extractfield(dir(src_fold),'name');
avail_ch = avail_ch(is_dir);
avail_ch = avail_ch(~ismember(avail_ch,{'.','..','VIS','saved_results'}))';
for  ii=1:length(avail_ch)
    avail_quad = extractfield(dir(fullfile(src_fold,avail_ch{ii})),'name');
    avail_quad = avail_quad(~ismember(avail_quad,{'.','..','whole'}))';
    for jj=1:length(avail_quad)
        avail_files = extractfield(dir(fullfile(src_fold,avail_ch{ii},avail_quad{jj},'*.png')),'name');
        avail_files = avail_files(~ismember(avail_files,{'.','..'}))';
        im_sum = zeros(20,20);
        for kk=1:length(avail_files)
            im = im2double(imread(fullfile(src_fold,avail_ch{ii},avail_quad{jj},avail_files{kk})));
            if ~isequal(size(im),[20,20])
                im = imresize(im,[20,20]);
            end
            im = im./(max(im(:))+eps());
            im_sum = im_sum + im ;
        end
        im_sum = im_sum./length(avail_files);
        fig_name = sprintf('Results of Quad:%s Channel:%s',avail_quad{jj},avail_ch{ii});
        fighand=figure('Name',fig_name);
        set(fighand,'units','normalized','outerposition',[0 0 1 1]);
        imagesc(im_sum); colormap(hot);colorbar
         axis image
        title(sprintf('%s Num of Fr: %i',fig_name,length(avail_files)),'Interpreter','None');
        drawnow;
        print(fighand,fullfile(src_fold,'saved_results',sprintf('prob_NN_%s_%s',avail_quad{jj},avail_ch{ii})),'-dpng','-r0');
    end
end