function [vecs,ave_vec,pVecL] = PCA_basic_1scale(I_RGB)
L = single(rgb2lab(I_RGB));
pVecL = im2colstep(padarray(double(L),[4 4],'replicate'),[9 9])';
ave_vec = mean(pVecL,1)';
[vecs,~] = princomp(pVecL);

end
function L = rgb2lab(RGB)
dRGB=im2double(RGB);
C=makecform('srgb2lab');
LAB=lab2double(applycform(dRGB,C));
% gfilt = fspecial('gaussian',9,4);
% LAB(:,:,2) = imfilter(LAB(:,:,2),gfilt);
% LAB(:,:,3) = imfilter(LAB(:,:,3),gfilt);
L=LAB(:,:,1);
end
