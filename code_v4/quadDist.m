function result = quadDist(h1,h2)
load simMat.mat;
h1 = repmat(h1,[size(h2,1) 1]);
X = abs(h1-h2);
% L = X(:,1:16)./(1+h2(:,1:16));
% A = X(:,17:32)./(1+h2(:,17:32));
% B = X(:,33:end)./(1+h2(:,33:end));

L = X(:,1:16);
A = X(:,17:32);
B = X(:,33:end);

result =sum(L*Lc,2) + sum(A*Cc,2) + sum(B*Cc,2);

    


end