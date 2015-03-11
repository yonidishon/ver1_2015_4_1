imSize= size(V);
[X, Y] = meshgrid(1:15:imSize(2),1:15:imSize(1));
h= figure;imagesc(frameCurrent);axis image;axis off;
hold on
quiver(X,Y,H(1:15:end,1:15:end),V(1:15:end,1:15:end),1,'LineWidth',2');
colormap hsv
hold off
print(h,'-dpng','quiver.png');