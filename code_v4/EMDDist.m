function result = EMDDist(h1,h2)
result = zeros(size(h2,1),1);
L = h1(1:16);
A = h1(17:32);
B = h1(33:end);
load('simMat.mat');

for indx=1:size(h2,1)
    
    rL = calculateEMD(L',h2(indx,1:16)',Lc);
    rA = calculateEMD(A',h2(indx,17:32)',Cc);
    rB = calculateEMD(B',h2(indx,33:end)',Cc);
    result(indx) = rL+rA+rB;
    
end

end