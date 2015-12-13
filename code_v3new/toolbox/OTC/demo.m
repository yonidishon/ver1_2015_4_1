% OTC: A Novel Local Descriptor for Scene Classification
% Irgb- RGB input image
% sz - patch size
% stepSz - sampling step size
% outSize - size of padded image
% result - OTC descriptor for each patch in the image

sz=7;
stepSz=1;
Irgb = im2double(imresize(imread('0_5_5189.jpg'),[144,256]));
[result,outSize]= OTC_IMAGE(Irgb,sz,stepSz);
