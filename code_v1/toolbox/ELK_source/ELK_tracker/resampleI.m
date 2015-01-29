function [resI] =  resampleI (I,XY,S,extrapMode)
% Reasmple input image I at coords. XY and reshape to size S

resI = vgg_interp2(I,XY(1,:),XY(2,:),'linear');
switch extrapMode
    case 'zero'
        resI(isnan(resI(:))) = 0;
    case 'one'
        resI(isnan(resI(:))) = 1;
    case 'mean'
        resI(isnan(resI(:))) = mean(resI(~isnan(resI(:))));
end
resI = reshape(resI,S);
mn = min(I(:));
mx = max(I(:));
resI(resI<mn) = mn;
resI(resI>mx) = mx;