function [vx,vy] = rect2vert(rect)
x1 = rect(1);
y1 = rect(2);
x2 = rect(1)+rect(3)-1;
y2 = rect(2)+rect(4)-1;
vx = [x1,x2,x2,x1];
vy = [y1,y1,y2,y2];