function [roi,inbox,dxy] = setROI(target,d)
v = target.verticesOut;
vx = round(v(1,:));
vy = round(v(2,:));
x = max(1,min(vx));
y = max(1,min(vy));
h = max(vy)-min(vy);
w = max(vx)-min(vx);
inbox = [x,y,max(2,min(target.imX,x+w)),max(2,min(target.imY,y+h))];
x1 = min(max(1,x-d),target.imX-1);
x2 = max(2,min(target.imX,x+w+d-1));
y1 = min(max(1,y-d),target.imY-1);
y2 = max(2,min(target.imY,y+h+d-1));
roi = [x1,y1,x2,y2];
dxy = zeros(size(target.p));
dxy(end-1) = x1-1;
dxy(end) = y1-1;
inbox = inbox - [x1,y1,x1,y1] - 1;
inbox(1:2) = max(inbox(1:2),1);
inbox(3:4) = max(inbox(3:4),2);


