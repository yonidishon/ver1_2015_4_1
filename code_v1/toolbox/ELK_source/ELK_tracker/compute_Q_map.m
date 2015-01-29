function [x_max,y_max,Q,varargout] = compute_Q_map(I,pr_I_fg,pr_I_bg,T,w,w_fg,w_bg,Vars)

w_fg = w_fg(:);
w_bg = w_bg(:);
w = w(:);
w_sum = sum(w(:));
szT = size(T);
if numel(szT)==2
    szT(3) = 1;
end

w = repmat(w,[szT(3),1]);
N = szT(1)*szT(2);
for f = 1:numel(Vars)
    w((f-1)*N+1:f*N) = w((f-1)*N+1:f*N)/(2*Vars(f));
end

Tcol  = im2col_ndim_fast_mex(T,       szT(1),szT(2));
Icol  = im2col_ndim_fast_mex(I,       szT(1),szT(2));
IFcol = im2col_ndim_fast_mex(log(pr_I_fg), szT(1),szT(2));
IBcol = im2col_ndim_fast_mex(log(pr_I_bg), szT(1),szT(2));

o = ones(1,size(Icol,2));

Q = w_fg'*IFcol + w_bg'*IBcol -w'*(Icol-Tcol*o).^2 - sum(0.5*log(Vars)*w_sum);

outSz = size(I)-size(T)+1;

[~,idx] = max(Q);

[y_max,x_max] = ind2sub(outSz(1:2),idx);

Q = reshape(Q,outSz(1:2));

if nargout > 3
    varargout{1} = reshape(-w'*(Icol-Tcol*o).^2 - sum(0.5*log(Vars)*w_sum),outSz(1:2));
    varargout{2} = reshape(w_fg'*IFcol,outSz(1:2));
    varargout{3} = reshape(w_bg'*IBcol,outSz(1:2));
end