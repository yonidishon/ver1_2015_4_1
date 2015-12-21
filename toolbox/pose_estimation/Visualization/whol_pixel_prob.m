%hist3  of quadrants
src_fold = '\\cgm10\d\head_pose_estimation\Train_vis_15';% Test_vis_Borji;
is_dir = cell2mat(extractfield(dir(src_fold),'isdir'));
avail_ch = extractfield(dir(src_fold),'name');
avail_ch = avail_ch(is_dir);
avail_ch = avail_ch(~ismember(avail_ch,{'.','..','VIS','saved_results'}))';
% h = figure();
% set(h,'units','normalized','outerposition',[0 0 1 1]);
for  ii=1:length(avail_ch)
    avail_files = extractfield(dir(fullfile(src_fold,avail_ch{ii},'whole','*.png')),'name');
    avail_files = avail_files(~ismember(avail_files,{'.','..'}))';
    im_sum = zeros(40,40);
    for kk=1:length(avail_files)
        im = im2double(imread(fullfile(src_fold,avail_ch{ii},'whole',avail_files{kk})));
        if ~isequal(size(im),[40,40])
            im = imresize(im,[40,40]);
        end
        im = im./(max(im(:))+eps());
        im_sum = im_sum + im ;
%         if ~mod(kk,100)
%             imagesc(im_sum);
%             axis image;
%             colormap(hot);colorbar;
%             title(kk);
%             drawnow;
%             pause(1);
%         end
    end
    im_sum = im_sum./length(avail_files);
    
    save(fullfile(src_fold,'saved_results',sprintf('prob_NN_%s_%s.mat','whole',avail_ch{ii})),'im_sum');
    % TODO - UNCOMMENT THIS
%     fig_name = sprintf('Results of :%s Channel:%s','whole',avail_ch{ii});
%     fighand=figure('Name',fig_name);
%     set(fighand,'units','normalized','outerposition',[0 0 1 1]);
%     imagesc(im_sum); colormap(hot);colorbar
%     axis image
%     title(sprintf('%s Num of Fr: %i',fig_name,length(avail_files)),'Interpreter','None');
%     drawnow;
%     print(fighand,fullfile(src_fold,'saved_results',sprintf('prob_NN_%s_%s','whole',avail_ch{ii})),'-dpng','-r0');
end