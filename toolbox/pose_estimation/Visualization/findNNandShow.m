function [ex_patch,NN] = findNNandShow(path,files,ex_num,nn_num,patchSz)
% This function inputs:
% - path - full path for the files (.png) files of patches)
% - files - cell array of files with patches (.png)
% - ex_num - Number of examples to show
% - nn_num - Number of NN to retrieve
% - patchSz - patch height and width (scalar)
% This function outputs:
% 1. ex_patch - example patches path - cell array ex_numx1
% 2. NN - nearest neigbours pathes cell array ex_numxnn_num
% choosing random files
ex_patch = cell(ex_num,1);
NN = cell(ex_num,nn_num);
perm = randperm(length(files));
cnt_ex = 1 ;
success = 1;
while success <= ex_num
    cur_file = files{perm(cnt_ex)};
    prefix = strsplit(cur_file,'_');prefix = strcat(prefix{1},'_');
    files_no_same_mov = files(~strncmpi(prefix,files,length(prefix)));
    X = imread(fullfile(path,cur_file));
    [m,n] = size(X);
    if ~isequal([m,n],[patchSz,patchSz]);
        if cnt_ex < numel(perm)
            cnt_ex = cnt_ex +1;
            continue;
        else
            warning('findNNandShow::Out of permutation not enough examples');
            break;
        end
    end
    X = X(:)';
    Y = zeros(length(files_no_same_mov),size(X,2));
    % Getting all patch data to Y matrix
    for jj=1:length(files_no_same_mov)
       %fprintf('File %i/%i :: %s\n',jj,length(files_no_same_mov),fullfile(path,files_no_same_mov{jj}));
       tmp = imread(fullfile(path,files_no_same_mov{jj}));
       if ~isequal(size(tmp),[m,n]) 
           Y(jj,:) = NaN;
           continue; 
       end
       Y(jj,:) = tmp(:)';
    end
    IDX=knnsearch(Y,X,'K',nn_num);
    NN(success,:) = cellfun(@(x)fullfile(path,x),files_no_same_mov(IDX),'UniformOutput',false);
    ex_patch{success} = fullfile(path,cur_file);
    success = success+1;
    cnt_ex = cnt_ex +1;
end