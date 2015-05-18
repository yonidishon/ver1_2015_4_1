% Written by S. Hossein Khatoonabadi (skhatoon@sfu.ca)

% normalize a first two dimensions of a 3D matrix to [0 1]

function x = Normalize3d(x)

[H,W,L] = size(x);

mx = max(x,[],1);
mx = max(mx,[],2);
mn = min(x,[],1);
mn = min(mn,[],2);
mx(mn==mx) = 1;

% to save memory
mn = squeeze(mn); mx = squeeze(mx);
for i=1:L
    x(:,:,i) = (x(:,:,i)-mn(i))/(mx(i)-mn(i));
end

% mx = repmat(mx,[H,W,1]);
% mn = repmat(mn,[H,W,1]);
% x = (x-mn)./(mx-mn);