% This script:
% 1. takes all quadrants (folders) of a certain modality.
% 2. for each patch
%   1. Find the Nearest Neigbour to the Patch (Euclid dist) that aren't
%    from the same movie!
%   2. record their quadrant in a 4x4 matrix
%   5. present results on a Nice figure. (tight subplot)

% getting the channel folders
src_fold = '\\cgm10\d\head_pose_estimation\Test_vis_Borji';%Train_vis_15';
is_dir = cell2mat(extractfield(dir(src_fold),'isdir'));
avail_ch = extractfield(dir(src_fold),'name');
avail_ch = avail_ch(is_dir);
avail_ch = avail_ch(~ismember(avail_ch,{'.','..','VIS','saved_results'}))';
patchSz = 20;
for ii=1:length(avail_ch)
    % Get the available Quadrants:
    avail_quad = extractfield(dir(fullfile(src_fold,avail_ch{ii})),'name');
    avail_quad = avail_quad(~ismember(avail_quad,{'.','..','whole'}))';
    % extract files from each quadrant
    all_files = [];
    for jj = 1:length(avail_quad) % for all quadrants
        % Getting Available file names in each Quadrants
        avail_files = extractfield(dir(fullfile(src_fold,avail_ch{ii},avail_quad{jj},'*.png')),'name');
        avail_files = avail_files(~ismember(avail_files,{'.','..'}))';
        quad_num = avail_quad{jj};quad_num = str2num(quad_num(1));
        quad_ind = repmat({quad_num},length(avail_files),1);
        prefix = cellfun(@(x)strsplit(x,'_'),avail_files,'UniformOutput',false);
        prefix = cellfun(@(x)str2num(x{1}),prefix,'UniformOutput',false);
        avail_files = cellfun(@(x)fullfile(src_fold,avail_ch{ii},avail_quad{jj},x),avail_files,'UniformOutput',false);
        % all files: is a cell array contains the quadrant index, movie index
        % and full path to .png patch file)
        all_files = [all_files;[quad_ind,prefix,avail_files]];
    end
    % patch_data the actual data of the all_files cell array in double
    patch_data = cellfun(@(x)im2double(imread(x)),all_files(:,3),'UniformOutput',false);
    % reject all not 20x20 patches
    not_20_20_patches = cellfun(@(x)~isequal(size(x),[patchSz,patchSz]),patch_data);
    fprintf('Ch::%s Number of not square %ix%i patches is: %i\n',...
        avail_ch{ii},patchSz,patchSz,numel(not_20_20_patches));
    patch_data(not_20_20_patches,:) = [];
    all_files(not_20_20_patches,:)=[];
    % convert the patch to row and normalized
    patch_data = cell2mat(cellfun(@(x)x(:)',patch_data,'UniformOutput',false));
    patch_data = patch_data./(repmat(max(patch_data')',1,size(patch_data,2))+eps());
    low_std = std(patch_data');
    low_std = low_std <= 0.05;
    patch_data(low_std,:) = [];
    all_files(low_std,:)=[];
    % get the unique indices of movies and quadrants
    movies = unique(cell2mat(all_files(:,2)));
    movie_ind = cell2mat(all_files(:,2));
    quadrants = unique(cell2mat(all_files(:,1)));
    quad_ind = cell2mat(all_files(:,1));
    %distanc_array = {'euclidean','seuclidean','cityblock','cosine','correlation','spearman'};
    %for dist = 1:numel(distanc_array)
    IDX = zeros(size(patch_data,1),2);
    IDX(:,1) = quad_ind;
    % for each movie 
    for tt = 1:size(quadrants,1)
        % in each quadrant
        for kk = 1:size(movies,1)
            % Get the indices of the movie in the specific quadrant
            test_log = bsxfun(@eq,movie_ind,movies(kk)) &  bsxfun(@eq,quad_ind,quadrants(tt));
            % Find the actual index of all the dataset points besides that
            % one that are
            mother_idx = find(~test_log);
            % Find the nearest neigbour of the patch information in all the
            % dataset without that movie in data quadrant.
            idx = knnsearch(patch_data(~test_log,:),patch_data(test_log,:),'Distance','correlation');
%             % debug
%             figure();
%             test_idx = find(test_log);
%             for bb = 1:length(idx)
%                 subplot(1,2,1);imshow(reshape(patch_data(mother_idx(idx(bb)),:),20,20));
%                 title(all_files{mother_idx(idx(bb)),3});
%                 subplot(1,2,2);imshow(reshape(patch_data(test_idx(bb),:),20,20));
%                 title(all_files{test_idx(bb),3});
%                 drawnow;
%                 pause();
%             end
            IDX(test_log,2) = quad_ind(mother_idx(idx));
        end
    end
    conf_mat = accumarray(IDX,1);
    fprintf('Ch::%s\n',avail_ch{ii});
    conf_mat = conf_mat./repmat(sum(conf_mat')',1,size(conf_mat,2))
 %   end
end