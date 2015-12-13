function [RGB]=vl_slic_show(image,SEGMENTS)
I_LAB = single(rgb2lab(image));
if nargin<2
    SEGMENTS = vl_slic(I_LAB, 8, 300);
end
mL=regionprops(SEGMENTS,I_LAB(:,:,1),'MeanIntensity');
ma=regionprops(SEGMENTS,I_LAB(:,:,2),'MeanIntensity');
mb=regionprops(SEGMENTS,I_LAB(:,:,3),'MeanIntensity');
mLab=[extractfield(mL,'MeanIntensity')',extractfield(ma,'MeanIntensity')',extractfield(mb,'MeanIntensity')'];
mRGB=lab2rgb(mLab);
if (size(SEGMENTS,1)*size(SEGMENTS,2)>100000);
    mask=imdilate(SEGMENTS,ones(3,3))>imerode(SEGMENTS,ones(3,3));
else
    mask=imdilate(SEGMENTS,ones(3,3))>imerode(SEGMENTS,ones(1,1));
end
RGB=label2rgb(SEGMENTS,double(mRGB)).*uint8(~repmat(mask,1,1,3));
if nargout==0
    figure();
    subplot(1,2,1);imshow(RGB);
    subplot(1,2,2);imshow(image);
end
end