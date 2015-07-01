% BUILD FULL TREE FROM sub-trees
% Get the version prefix for the current tree
clear all;close all;clc;
fprintf('Start script for building full tree\n');

cd(fileparts(mfilename('fullpath')));
TREEPREFIX='tree_cluster_patch_v2';
TREEVER='tree_cluster_patch_v2';
DATE='2015_06_30';
FULLTREENAME=['fulltree_',TREEVER,'_',DATE];

treefiles=dir([TREEPREFIX,'*']);
fulltree=load(treefiles(1).name);
fulltree=fulltree.learned_tree;
fulltree=fulltree.compact;
fprintf('Finished loading tree #1\n');
for ii=2:length(treefiles)
    curtree=load(treefiles(ii).name);
    curtree=curtree.learned_tree;
    curtree=curtree.compact;
    fulltree=combine(fulltree,curtree);
    fprintf('Finished appending tree #%i\n',ii);
end
fprintf('Saving Full tree\n');
save(FULLTREENAME,'fulltree','-v7.3');
fprintf('Finished!!\n');