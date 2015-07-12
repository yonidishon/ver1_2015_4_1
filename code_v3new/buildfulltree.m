% SCRIPT
% BUILD FULL TREE FROM sub-trees %
% Get the version prefix for the current tree
fprintf('Start script for building full tree\n');
FULLTREENAME=fullfile(TreesDst,[GENERALPARAMS.full_tree_ver,'_fulltree']);

treefiles=dir(fullfile(TreesDst,[GENERALPARAMS.full_tree_ver,'*']));
treesoobErrrorArr=zeros(length(treefiles),TREEPARAMS.numtrees);
fulltree=load(fullfile(TreesDst,treefiles(1).name));
fulltree=fulltree.learned_tree;
treesoobErrrorArr(1,:)=oobError(fulltree,'mode','individual');
NumOfObs = size(fulltree.X,1);
fulltree=fulltree.compact;
fprintf('Finished loading tree #1\n');
for ii=2:length(treefiles)
    curtree=load(fullfile(TreesDst,treefiles(ii).name));
    curtree=curtree.learned_tree;
    treesoobErrrorArr(ii,:)=oobError(curtree,'mode','individual');
    curtree=curtree.compact;
    fulltree=combine(fulltree,curtree);
    fprintf('Finished appending tree #%i\n',ii);
end

fprintf('Saving Full tree\n');
save(FULLTREENAME,'fulltree','-v7.3');
fprintf('Saving Full tree text file\n');
fid = fopen([FULLTREENAME,'_params.txt'],'wt');

fprintf(fid,'GENERALPARAMS are:\n');
%// Extract field data
fields = fieldnames(GENERALPARAMS);
values = struct2cell(GENERALPARAMS);
%// Convert numerical values to strings
idx = cellfun(@isnumeric, values); 
values(idx) = cellfun(@num2str, values(idx), 'UniformOutput', false);
C = {fields{:}; values{:}};
fprintf(fid,'%s = %s\n',C{:});

fprintf(fid,'TREEPARAMS are:\n');
%// Extract field data
fields = fieldnames(TREEPARAMS);
values = struct2cell(TREEPARAMS);
%// Convert numerical values to strings
idx = cellfun(@isnumeric, values); 
values(idx) = cellfun(@num2str, values(idx), 'UniformOutput', false);
C = {fields{:}; values{:}};
fprintf(fid,'%s = %s\n',C{:});
fprintf(fid,'\nFrame # in training = %d , Observations # = %d\n',NumOfObs/TREEPARAMS.samples_per_frame,NumOfObs);
fprintf(fid,'\nOut-of-Bag Mean Error: %s\n',num2str(mean(treesoobErrrorArr,2)'));
fprintf(fid,'Out-of-Bag Error:\n');
fprintf(fid,'%s\n',mat2str(treesoobErrrorArr));
fprintf('Finished!!\n');