% Find a 2D warp between Image I and template T using 
% Multi-Scale Multi-transform Color Lucas-Kanade
% 
% Input:
%   I -the Image
%   T- the template
%   pr_I_fg,pr_I_bg - the foreground and background likjlihood of the current image I
%   Q.wI - the objecthood probability mask expected for the image, according to previous EM rounds
%   Q.w - the objecthood probability of both template and image, according to previous EM rounds.
%   prm - th LK parameters
%   Vars - the variances of the channels used.
%   p - initial guess
%
% Output:
%   p - the parameters of the found transformation

function [p,varargout] = multiScaleLK(I,T,pr_I_fg,pr_I_bg,Q,p,prm,Vars)

% Normalize the data range
[ T, I, StandardDev , Scales]=rescale_TandI(T,I,prm);
    
% Compute error variances if not given (bad estimate based on total varaiance)
if ~exist('Vars','var') || isempty(Vars)
    for f=1:size(T,3);
        Vars(f)=var(reshape(T(:,:,f),[],1));
    end
end

warpMat = prm.warpMat;
% resize input image
Torig = T;
[Sy,Sx,Sf] = size(T);
A = Sy*Sx;
if  prm.lkA0 <= 0
    DS = 1;
else
    lkA0 = prm.lkA0;
    DS = min(max(lkA0/A,0.25),2);
end
%DS = 1;
% fprintf('Resizing with facotr %.2f\n',DS);
I = imresize(I,DS,'bilinear');
T = imresize(T,DS,'bilinear');
p(5:6) = p(5:6)*DS;

% Convert variable types 
pr_I_fg = imresize(pr_I_fg,DS,'bilinear');
pr_I_bg = imresize(pr_I_bg,DS,'bilinear');
Q.wI = imresize(Q.wI ,DS,'bilinear');
Q.wI(Q.wI>1) = 1;
Q.w = imresize(Q.w ,DS,'bilinear');

% Set number of pyramid levels
nLevel = size(warpMat,1);
% Build pyramids for Image,Template and masks
pyrI = gaussianPyramid(I,nLevel);
pyrT = gaussianPyramid(T,nLevel);
pyr_pr_I_fg = gaussianPyramid(pr_I_fg,nLevel);
pyr_pr_I_bg = gaussianPyramid(pr_I_bg,nLevel);
pyr_Q_wI = gaussianPyramid(Q.wI,nLevel);
pyr_Q_w = gaussianPyramid(Q.w,nLevel);


for l = nLevel:-1:1
    % Scale warp params according to pyramid level
    p(5:6) = p(5:6)/2^(l-1);    
    % Perform LK
    [Tout,p,w, Stats,logicalCoords ] = colorLK_inv_comp_fast(pyrI{l},pyrT{l},...
		pyr_pr_I_fg{l},pyr_pr_I_bg{l},pyr_Q_wI{l},pyr_Q_w{l},p,warpMat(l,:),prm,Vars,l);
    % Scale warp params back to original scale
    p(5:6) = p(5:6)*2^(l-1);
end
p(5:6) = p(5:6)/DS;

%Tout_IS=Tout;   % Tout_IS is the intensity-scaled Tout. We keep it to compute pr_err

if nargout>=1
    %Tout = imresize(Tout,[Sy Sx]);
    for f = 1:size(T,3)
        OrigI=I(:,:,f)*StandardDev(f)/prm.TotalSTD; % original image (before intensity scaling)
        Tout(:,:,f) = resampleI(OrigI,logicalCoords,[size(Tout,1) size(Tout,2) ],'zero');
    end
    if DS~=1
        Tout = imresize(Tout,[Sy Sx],'bilinear');
    end
    varargout{1} = Tout;
end
if nargout>=2
    rmse = sqrt(sum((Tout(:)-Torig(:)).^2)/(Sy*Sx));
    varargout{2} = rmse;
end 
if nargout>=3
    w = imresize(w,[Sy Sx]);
    varargout{3} = w;
end
if nargout>=4
   varargout{4} = Stats;
end
if nargout>=5
    varargout{5}=Stats.OptVars(end,:);
end
if nargout>=6
    varargout{6}=Scales;
end


%% =================================================================================
function [pyrI] = gaussianPyramid(I,N)

pyrI{1} = I;
for n=2:N
        I = downSampleI(I,2);
        pyrI{n} = I;
end

%% =================================================================================
function dsI = downSampleI(I,DS)
% Down sample image I by DS factor( DS should be of size 2^N ). DS is done in a 
% gaussian pyramid like manner where I is blurred then DS by factor of 2 repeatedly

h = buildResamplingFilter;
dsI = I;
while DS > 1
        dsI = imfilter(dsI,h,'replicate');
        dsI = dsI(1:2:end,1:2:end,:);        
        DS = DS/2;
end

%% =================================================================================
function [h] = buildResamplingFilter
% Build a normalized, symetric and equal contribution filter (of size 5x5).
% Based on: "The Laplacian Pyramid as aCompact Image Code" (Burt & Adelson 1983)

a = 0.4;
b = 1/4;
c = 1/4 - a/2;
h = [c b a b c];
h = h'*h;