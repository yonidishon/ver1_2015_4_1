function BoundingBox = gazedataToBoundingBox(gzpoints,h,w)
%gazedataToBoundingBox - doing non maximum suppresion and return maximum
% around bounding box
%Inputs:
%   gzpoints - GT gaze points stored in the dataset
%   h,w height and width of the frame
%Outputs:
%   BoundingBox - [x,y,h,w] of the bounding box around the maximum of the
%   gaussian map made out of the GT gaze points
gazePts = gzpoints(~isnan(gzpoints(:,1)),:);
[X,Y] = meshgrid(1:w,1:h);
if isempty(gazePts) 
    BoundingBox=[round(w/3),round(h/3),round(w/3),round(h/3)];
    return
end
if size(gazePts,1)==1 % one point - > BoundingBox is 100x100 centered in gazePts
    BoundingBox=[gazePts(2)-50,gazePts(1)-50,100,100];
    return
end
if size(gazePts,1)==2 % two points - > BoundingBox is 100x100 centered in gazePts ave
    BoundingBox=[round(mean(gazePts(:,2))-50),round(gazePts(1)-50),100,100];
    return
end
GMModel = fitgmdist(gazePts,1);
W = reshape(pdf(GMModel, [X(:),Y(:)]),[h,w]);
if max(W(:))>0
    W_norm=W./max(W(:));
else
    W_norm=W;
end
bw=zeros(size(W_norm));
bw(W_norm>0.023)=1;
tmp=regionprops(bw,'BoundingBox');
BoundingBox=tmp.BoundingBox;   
% How to preform BoundingBox to Heatmap again
% 6 - is a empirical parameter related to sigma
% fg=exp(-((X - BoundingBox(1)).^2/2/(BoundingBox(3)/6)^2 + (Y - BoundingBox(2)).^2/2/(BoundingBox(4)/6)^2));
% fg=fg./max(fg(:));


end

