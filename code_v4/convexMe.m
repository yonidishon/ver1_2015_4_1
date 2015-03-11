function out = convexMe(sMap)
in = stableNormalize(sMap)>=0.4;
figure;imshow(in);
in = uint8(in);
s = regionprops(in, 'BoundingBox', 'ConvexImage');

m = s.BoundingBox(4);
n = s.BoundingBox(3);
r1 = s.BoundingBox(2) + 0.5;
c1 = s.BoundingBox(1) + 0.5;
r = (1:m) + r1 - 1;
c = (1:n) + c1 - 1;

out = false(size(in));
out(r,c) = s.ConvexImage;
end