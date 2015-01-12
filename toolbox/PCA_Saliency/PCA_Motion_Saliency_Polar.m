function result = PCA_Motion_Saliency(fx,fy,I_RGB)

% if (~exist('vl_slic.m','file'))
%     fprintf('\nConfiguring vl_slic & IM2COLSTEP\n');
%     bindir = mexext;
%     if (~strcmp(mexext,'mexw64'))
%         fprintf('Note: You are not using Windows 64 bit: Fast im2colstep diabled\n');
%     end;
%     if strcmp(bindir, 'dll'), bindir = 'mexw32' ; end
%     addpath(fullfile(pwd,'EXT','vl_slic')) ;
%     addpath(fullfile(pwd,'EXT','vl_slic',bindir)) ;
% end
addpath(genpath(fullfile([pwd,'\Saliency\','\EXT\']))) ;
if (size(I_RGB,3)==1) % grayscale image is treated as colored
    I_RGB=repmat(I_RGB,[1 1 3]);
end
result = PCA_Motion_Saliency_Core(fx,fy,I_RGB);
%result = PCA_Motion_Saliency_Core_v1(fx,fy,I_RGB);
