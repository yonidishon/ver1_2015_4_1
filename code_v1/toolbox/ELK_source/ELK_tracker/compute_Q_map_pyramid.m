% compute LK Q function values exhaustively (for 2D-Tr only) given image and tempalte
% return max(Qtot) position including log-likelihood terms and max(Qtemplate) w/o log-likelihood terms 
function [Q_x_max,Q_y_max,Qtmp_x_max,Qtmp_y_max] = compute_Q_map_pyramid(I,pr_I_fg,pr_I_bg,T,w,w_fg,w_bg,Vars,x0,y0,verbose)

max_level = 2;
levels = 3;
II{1} = I;
IF{1} = pr_I_fg;
IB{1} = pr_I_bg;
TT{1} = T;
W{1} = w;
WF{1} = w_fg;
WB{1} = w_bg;
Q_y_max = y0;
Q_x_max = x0;
Qtmp_y_max = y0;
Qtmp_x_max = x0;

for l = 2:levels
    II{l} = imresize(II{l-1},0.5);
    IF{l} = imresize(IF{l-1},0.5);
    IB{l} = imresize(IB{l-1},0.5);
    TT{l} = imresize(TT{l-1},0.5);
    W{l}  = imresize(W{l-1},0.5);
    WF{l} = imresize(WF{l-1},0.5);
    WB{l} = imresize(WB{l-1},0.5);
    Q_y_max     = Q_y_max/2;
    Q_x_max     = Q_x_max/2;
    Qtmp_y_max  = Qtmp_y_max/2;
    Qtmp_x_max  = Qtmp_x_max/2;
    
end

win = 50;
for l = levels:-1:1
    if l>=max_level
        T = TT{l};
        szI = size(II{l});
        szT = size(T);
        r = round([ max(1,Q_x_max-win),max(1,Q_y_max-win),min(Q_x_max+win+szT(2),szI(2)),min(Q_y_max+win+szT(1),szI(1))]);
        if prod(r(3:4))<=180^2
            w_fg = WF{l}(:);
            w_bg = WB{l}(:);
            w = W{l}(:);
            w_sum = sum(w(:));
            if numel(szT)==2
                szT(3) = 1;
            end
            
            w = repmat(w,[szT(3),1]);
            N = szT(1)*szT(2);
            for f = 1:numel(Vars)
                w((f-1)*N+1:f*N) = w((f-1)*N+1:f*N)/(2*Vars(f));
            end
            
            Tcol  = im2col_ndim_fast_mex(T                                , szT(1),szT(2));
            Icol  = im2col_ndim_fast_mex(II{l}(r(2):r(4),r(1):r(3),:)     , szT(1),szT(2));
            IFcol = im2col_ndim_fast_mex(log(IF{l}(r(2):r(4),r(1):r(3),:)), szT(1),szT(2));
            IBcol = im2col_ndim_fast_mex(log(IB{l}(r(2):r(4),r(1):r(3),:)), szT(1),szT(2));
            
            o = ones(1,size(Icol,2));
            Qtmp = -w'*(Icol-Tcol*o).^2 - sum(0.5*log(Vars)*w_sum);
            Q = w_fg'*IFcol + w_bg'*IBcol + Qtmp;
            
            outSz = [r(4)-r(2)-szT(1)+2,r(3)-r(1)-szT(2)+2];
            % find Q-function max including LL-terms
            [~,Qidx] = max(Q);
            [Q_y_max,Q_x_max] = ind2sub(outSz(1:2),Qidx);
            Q_y_max = Q_y_max+r(2)-1;
            Q_x_max = Q_x_max+r(1)-1;
            % find Q-function max including Template matching terms only 
            [~,Qtmpidx] = max(Qtmp);
            [Qtmp_y_max,Qtmp_x_max] = ind2sub(outSz(1:2),Qtmpidx);
            Qtmp_y_max = Qtmp_y_max+r(2)-1;
            Qtmp_x_max = Qtmp_x_max+r(1)-1;
            
            if verbose
                figure(1);
                subplot(1,2,1);imagesc(II{l}(:,:,1)*2*Vars(1));
                rectangle('position',[r(1),r(2),r(3)-r(1),r(4)-r(2)],'linewidth',2,'edgecolor','b');
                rectangle('position',[Q_x_max,Q_y_max,szT(2),szT(1)],'linewidth',2,'edgecolor','g');
                rectangle('position',[Qtmp_x_max,Qtmp_y_max,szT(2),szT(1)],'linewidth',2,'edgecolor','y');
                subplot(1,2,2);imagesc(reshape(Q,outSz));
                rectangle('position',[Q_x_max-r(1)+1,Q_y_max-r(2)+1,0.5,0.5],'linewidth',2,'edgecolor','g');
                rectangle('position',[Qtmp_x_max,Qtmp_y_max,szT(2),szT(1)],'linewidth',2,'edgecolor','y');
                colormap gray;
                drawnow;
                'w';
            end
        end
    end
        
    if l>1
        Q_x_max = Q_x_max*2;
        Q_y_max = Q_y_max*2;
        Qtmp_x_max = Qtmp_x_max*2;
        Qtmp_y_max = Qtmp_y_max*2;
        
    end
end