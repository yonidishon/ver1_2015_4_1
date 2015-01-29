restoredefaultpath;
clear all;
clear classes;
clear children;
close all;
clc;
main_dir = pwd;
addpath(genpath(main_dir));
vl_setup;
clc;
try
    pdir = cd('ELK_tracker');
    mex im2col_ndim_fast_mex.cpp;
    mex my_im2col_color_fast_mex.cpp;
    cd(pdir);
catch
    cd(pdir);
    error('Unable to compile im2col_ndim_fast_mex.cpp into mex file');
end
fprintf('init completed, main dir is now: %s\n',main_dir);