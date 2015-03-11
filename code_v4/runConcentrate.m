clear all;
close all;
IN_DIR = '..\Input\Weizmann1\images\';
G_DIR = '..\Input\Weizmann1\groundTruth\';
fls = dir([IN_DIR '\*.png']);
Nimages =length(fls);
imVar = zeros(Nimages,3);
fprintf('\n');
for ind=1:3
    PCANOSAL{ind}=[];
    PCA{ind}=[];
    L1{ind} = [];
    L1NOSAL{ind} = [];
    L2{ind} = [];
    L2NOSAL{ind} = [];
    
end
for flIdx=1:100
    fprintf('Image(%i)',flIdx);
    I = double(rgb2lab(imread([IN_DIR fls(flIdx).name])));
    [pathstr, name, ext] = fileparts(fls(flIdx).name);
    G = im2bw(imread(([G_DIR name '.bmp'])));
    
    % G = padarray(im2bw(imread(([G_DIR fls(flIdx).name]))),[4 4],'replicate');
    nonSal = find(~G);
%             BW = bwmorph(G,'remove');
%         BW = bwdist(BW)<=1;
% BW=G;
BW = zeros(size(G));
    for clrCmp=1:3
        T = I(:,:,clrCmp);
        B = edge(T./max(T(:)),'canny',0.01);
        B = logical(B.*G);
        BW(B) = 1;
    end
%     figure;imshow(BW);
    
    
        Sal = find(BW);    
    for clrCmp=1:3

        vecs = im2col(padarray(I(:,:,clrCmp),[4 4],'replicate'),[9 9],'sliding')';
        vecs = vecs - repmat(mean(vecs,2),[1 81]);
        meanVec = mean(vecs,1);
        Nvecs=vecs(nonSal,:);
        Yvecs = vecs(Sal,:);
        NrmeanVec=repmat(meanVec,[size(Nvecs,1) 1]);
        
        YrmeanVec=repmat(meanVec,[size(Yvecs,1) 1]);
        rmeanVecFULL=repmat(meanVec,[size(vecs,1) 1]);
        
        sm = sum(abs(Yvecs-YrmeanVec),2);
        smN = sum(abs(Nvecs-NrmeanVec),2);
        mxSm = max([sm ; smN]);
        
        L1{clrCmp} = [L1{clrCmp}; sm/mxSm ];
        L1NOSAL{clrCmp} = [L1NOSAL{clrCmp}; smN/mxSm];
        
        sm = sqrt(sum((Yvecs-YrmeanVec).^2,2));
        smN = sqrt(sum((Nvecs-NrmeanVec).^2,2));
        mxSm = max([sm ; smN]);
        
        L2{clrCmp} = [L2{clrCmp}; sm/mxSm  ];
        L2NOSAL{clrCmp} = [L2{clrCmp}; smN/mxSm ];
        [COEFF] = princomp(vecs-rmeanVecFULL);
        
        out = Yvecs*COEFF;
        sm = sum(abs((out)),2);
        outN = Nvecs*COEFF;
        smN = sum(abs((outN)),2);
        mxSm = max([sm ; smN]);
        PCA{clrCmp} = [PCA{clrCmp}; sm./mxSm ];
        
        PCANOSAL{clrCmp} = [PCANOSAL{clrCmp}; smN./mxSm ];
        fprintf('.');
    end
    fprintf('\n');
    
end
return;
%%


SAL = PCA; NOSAL = PCANOSAL;
S = zeros(size(SAL{1}));
NOS = zeros(size(NOSAL{1}));
[nD nNOTD] = deal(0);
for clrcmp=1:3
    nD= nD + numel(SAL{clrcmp});
    nNOTD = nNOTD + numel(NOSAL{clrcmp});
    S = S+SAL{clrcmp};
    NOS = NOS+NOSAL{clrcmp};
end
S = S/3;
NOS = NOS/3;

    ind =1;
    for th=0:0.01:1
        A = sum(S<=th);
        B = sum(NOS<=th);
        Ls(ind) = A./(numel(S));
        
        Ln(ind) = B./(numel(NOS));
        ind = ind+1;
    end
plt = [Ls' Ln'];


SAL = L1; NOSAL = L1NOSAL;
S = zeros(size(SAL{1}));
NOS = zeros(size(NOSAL{1}));
[nD nNOTD] = deal(0);
for clrcmp=1:3
    nD= nD + numel(SAL{clrcmp});
    nNOTD = nNOTD + numel(NOSAL{clrcmp});
    S = S+SAL{clrcmp};
    NOS = NOS+NOSAL{clrcmp};
end
S = S/3;
NOS = NOS/3;

    ind =1;
    for th=0:0.01:1
        A = sum(S<=th);
        B = sum(NOS<=th);
        Ls(ind) = A./(numel(S));
        
        Ln(ind) = B./(numel(NOS));
        ind = ind+1;
    end
plt = [plt Ls' Ln'];



SAL = L2; NOSAL = L2NOSAL;
S = zeros(size(SAL{1}));
NOS = zeros(size(NOSAL{1}));
[nD nNOTD] = deal(0);
for clrcmp=1:3
    nD= nD + numel(SAL{clrcmp});
    nNOTD = nNOTD + numel(NOSAL{clrcmp});
    S = S+SAL{clrcmp};
    NOS = NOS+NOSAL{clrcmp};
end
S = S/3;
NOS = NOS/3;

    ind =1;
    for th=0:0.01:1
        A = sum(S<=th);
        B = sum(NOS<=th);
        Ls(ind) = A./(numel(S));
        
        Ln(ind) = B./(numel(NOS));
        ind = ind+1;
    end
plt = [plt Ls' Ln'];

% csvwrite('PCAout.csv',plt);
csvwrite('Bothout.csv',plt);




%%
%
% % L=L./(Lmax);
% [n,xout]=hist(L,1000);
% l=cumsum(n);
% l=l./max(l(:));
%
%
% L = PCANOSAL{1};
% % L=L./(Lmax);
% [n,xout]=hist(L,1000);
% l2=cumsum(n);
% l2=l2./max(l2(:));
%
% Amax = max([PCA{2} ;PCANOSAL{2}]);
%
% A = PCA{2};
% % A=A./(Amax);
% [n,xout]=hist(A,1000);
% a=cumsum(n);
% a=a./max(a(:));
%
% A = PCANOSAL{2};
% % A=A./(Amax);
% [n,xout]=hist(A,1000);
% a2=cumsum(n);
% a2=a2./max(a2(:));
%
% B = PCA{3};
% % B=B./(81*256);
% [n,xout]=hist(B,1000);
% b=cumsum(n);
% b=b./max(b(:));
%
% B = PCANOSAL{3};
% % B=B./(81*256);
% [n,xout]=hist(B,1000);
% b2=cumsum(n);
% b2=b2./max(b2(:));
%
%
%
% figure;plot(xout,[l' a' b'],'Linewidth',5);
% figure;plot(xout,[l' l2'],'Linewidth',5);
% figure;plot(xout,[a' a2'],'Linewidth',5);
%
% legend('Lsal','LnoSal');