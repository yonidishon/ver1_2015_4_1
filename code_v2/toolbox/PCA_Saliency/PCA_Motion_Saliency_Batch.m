function result = PCA_Motion_Saliency_Batch(fx,fy,I_RGB)
addpath(genpath(fullfile([pwd,'\Saliency\','\EXT\']))) ;
if (size(I_RGB,3)==1) % grayscale image is treated as colored
    I_RGB=repmat(I_RGB,[1 1 3 1]);
end
if size(I_RGB,4)~=size(fx,3) || size(I_RGB,4)~=size(fy,3)
    error('PCA_Motion_Saliency_Batch:: sizes of image and motion maps aren''t the same\n');
end
result = PCA_Motion_Saliency_Core_Batch(fx,fy,I_RGB);
end
