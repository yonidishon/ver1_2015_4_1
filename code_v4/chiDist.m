function result = chiDist(h1,h2)
h1 = repmat(h1,[size(h2,1) 1]);
result = sum((h1-h2).^2 ./ (h2+h1+eps),2) / 2;
end