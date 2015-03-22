function LAB = rgb2lab(RGB)
dRGB=im2double(RGB);
% dRGB = double(RGB)/255;
C=makecform('srgb2lab');
LAB=lab2double(applycform(dRGB,C));
% LAB= rgb2labFULL(dRGB);
gfilt = fspecial('gaussian',9,4);
LAB(:,:,2) = imfilter(LAB(:,:,2),gfilt);
LAB(:,:,3) = imfilter(LAB(:,:,3),gfilt);
end