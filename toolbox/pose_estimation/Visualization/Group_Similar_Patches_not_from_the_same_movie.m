% This script:
% 1. takes a quadrant (folder) of a certain modality.
% 2. Choose a Patch (image) in Random.
% 3. Find the 10 Nearest Neigbours to the Patch (Euclid dist) that aren't
%    from the same movie!
% 4. record their image names.
% 5. present results on a Nice figure. (tight subplot)

% getting the channel folders
src_fold = '\\cgm10\d\head_pose_estimation\Train_vis_15';
is_dir = cell2mat(extractfield(dir(src_fold),'isdir'));
avail_ch = extractfield(dir(src_fold),'name');
avail_ch = avail_ch(is_dir);
avail_ch = avail_ch(~ismember(avail_ch,{'.','..','VIS','saved_results'}))';
ex_num = 5;
nn_num = 10;
patchSz = 20;
for ii=1:length(avail_ch)
    % Get the available Quadrants:
    avail_quad = extractfield(dir(fullfile(src_fold,avail_ch{ii})),'name');
    avail_quad = avail_quad(~ismember(avail_quad,{'.','..','whole'}))';
    for jj = 1:length(avail_quad)
        if exist(fullfile(src_fold,sprintf('NN_%s_%s.mat',avail_quad{jj},avail_ch{ii})),'file')==2
            data=load(fullfile(src_fold,sprintf('NN_%s_%s.mat',avail_quad{jj},avail_ch{ii})));
            fighand = displayNNresults(data.ex_patch,data.NN_patch,avail_quad{jj},avail_ch{ii});
            set(fighand,'units','normalized','outerposition',[0 0 1 1]); 
            continue;
        end
        % Getting Available file names in each Quadrants
        avail_files = extractfield(dir(fullfile(src_fold,avail_ch{ii},avail_quad{jj},'*.png')),'name');
        avail_files = avail_files(~ismember(avail_files,{'.','..'}))';
        [ex_patch,NN_patch] = findNNandShow(fullfile(src_fold,avail_ch{ii},avail_quad{jj})...
            ,avail_files,ex_num,nn_num,patchSz);
        fighand = displayNNresults(ex_patch,NN_patch,avail_quad{jj},avail_ch{ii});
        set(fighand,'units','normalized','outerposition',[0 0 1 1]);        
        save(fullfile(src_fold,sprintf('NN_%s_%s.mat',avail_quad{jj},avail_ch{ii})),'ex_patch','NN_patch');
        %print(fighand,fullfile(src_fold,sprintf('NN_%s_%s',avail_quad{jj},avail_ch{ii})),'-dpng','-r0');
        fig_im = getframe(fighand);
        imwrite(fig_im.cdata,fullfile(src_fold,sprintf('NN_%s_%s.png',avail_quad{jj},avail_ch{ii})));
        savefig(fighand,fullfile(src_fold,sprintf('NN_%s_%s',avail_quad{jj},avail_ch{ii})));
    end
end