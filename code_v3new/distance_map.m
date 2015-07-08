function [x_relative_center,y_relative_center]=distance_map(rows,cols)
% Function to return the map of the distance (horazonal and vertical) 
% of each pixel from the center of the image (rows/2,cols/2)
% in a noromilized fashion -> where
x_relative_center=abs(cols/2-repmat(1:cols,rows,1))/(cols/2);
y_relative_center=abs(rows/2-repmat((1:rows)',1,cols))/(rows/2);
end