function [jaccard_idx] = measure_jaccard_index(vx,vy,ux,uy)

try
    [x1,y1] = poly2cw([vx,vx(1)],[vy,vy(1)]);
    [x2,y2] = poly2cw([ux,ux(1)],[uy,uy(1)]);
catch
    warning('poly2cw failed jaccard_idx set to 0');
    jaccard_idx = 0 ;
    return;
end
[xI,yI] = polybool('intersection',x1,y1,x2,y2);
[xU,yU] = polybool('union',x1,y1,x2,y2);
Iarea = polyarea(xI,yI);
Uarea = polyarea(xU,yU);
jaccard_idx = Iarea/Uarea;

if isnan(jaccard_idx)
    jaccard_idx = 0;
end