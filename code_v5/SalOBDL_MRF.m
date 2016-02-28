% Written by S. Hossein Khatoonabadi (skhatoon@sfu.ca)
%
% saliency estimation based on our proposed OBDL-MRF method
%
% Input
%     obdls: (3-D matrix) raw OBDL values 
%     ONE_DEGREE_MBLKS: (integer value) the number of macroblocks in 1
%        degree visual angle
%     T_t: (integer value) coefficient of the likelihood relative to prior
%        labels (temporal consistency)
%     T_o: (integer value) coefficient of the likelihood relative to
%        observations (observation coherence)
%     T_c: (integer value) coefficient of the prior probability of the
%        current labels (compactness)
%     
% Output
%     Saliency: (3-D matrix) predicted saliency map

function Saliency = SalOBDL_MRF(obdls,ONE_DEGREE_MBLKS, T_t, T_o, T_c)

ICM_MAX_ITR = 8;
L = 2;
L_t = 14;

if nargin < 3
    T_t=1;
    T_o=1;
    T_c=1;
end

obdls = Normalize3d(obdls);
obdls = imfilter(obdls,fspecial('gauss',3,ONE_DEGREE_MBLKS*2));
obdls = Normalize3d(obdls);

flt = ones(1,1,2*L-1); flt(L+1:end) = 0;
obdl_maps = imfilter(obdls,flt,'symmetric');
obdl_maps = Normalize3d(obdl_maps);

% spatial weight
W_sp = fspecial('gauss',3,ONE_DEGREE_MBLKS*2);
W_s = W_sp/W_sp(2,2); W_s = repmat(W_s,[1 1 L_t]);
% temporal weight
W_t = fspecial('gauss',[1 2*L_t],L_t); W_t = W_t/W_t(end/2); W_t = W_t(1:end/2);
W_t = repmat(reshape(W_t,1,1,L_t),[3 3 1]);
W = W_s.*W_t;

W_pre = W(:,:,1:end-1);

sals_ex = padarray(obdl_maps,[1 1 L_t],'symmetric');

% initialization
mask_ex = imfilter(sals_ex,W_sp,'symmetric');
mask_ex = Normalize3d(mask_ex) > .5;

sal_flt = imfilter(sals_ex,W_sp);
sal_flt = Normalize3d(sal_flt);

f = [.5 1 .5;1 0 1; .5 1 .5];

E = zeros(size(mask_ex,1),size(mask_ex,2));
% find the best mask that produces minimum error base on ICM
for frame=L_t+1:size(obdl_maps,3)+L_t
    sal = sal_flt(:,:,frame);
    localMinSal = imerode(sal, true(3));
    localMaxSal = imdilate(sal, true(3));
    mask = mask_ex(:,:,frame);
    if ~mod(frame,100)
        fprintf('Processed %i Frames already\n',frame);
    end
    for i=2:size(mask_ex,1)-1
        for j=2:size(mask_ex,2)-1
            if mask(i,j)
                a = (1-mask_ex(i-1:i+1,j-1:j+1,frame-L_t+1:frame-1)).*sals_ex(i-1:i+1,j-1:j+1,frame-L_t+1:frame-1).*W_pre;
                b = sals_ex(i-1:i+1,j-1:j+1,frame-L_t+1:frame-1).*W_pre;
                e_T = sum(a(:))/sum(b(:));
                e_O = 1 - localMaxSal(i,j);
                e_C = 1-sum(sum(f.*mask(i-1:i+1,j-1:j+1)))/6;
            else
                a = mask_ex(i-1:i+1,j-1:j+1,frame-L_t+1:frame-1).*(1-sals_ex(i-1:i+1,j-1:j+1,frame-L_t+1:frame-1)).*W_pre;
                b = (1-sals_ex(i-1:i+1,j-1:j+1,frame-L_t+1:frame-1)).*W_pre;
                e_T = sum(a(:))/sum(b(:));
                e_O = localMinSal(i,j);
                e_C = sum(sum(f.*mask(i-1:i+1,j-1:j+1)))/6;
            end
            E(i,j) = T_t*e_T + T_o*e_O + T_c*e_C;
        end
    end
  
    % change the mask of each block, and keep it if it causes error reduction
    for itr=1:ICM_MAX_ITR
        E_new = E;
        for i=2:size(mask_ex,1)-1
            for j=2:size(mask_ex,2)-1
                mask_ex(i,j,frame) = ~mask(i,j);
                if mask_ex(i,j,frame)
                    a = (1-mask_ex(i-1:i+1,j-1:j+1,frame-L_t+1:frame-1)).*sals_ex(i-1:i+1,j-1:j+1,frame-L_t+1:frame-1).*W_pre;
                    b = sals_ex(i-1:i+1,j-1:j+1,frame-L_t+1:frame-1).*W_pre;
                    e_T = sum(a(:))/sum(b(:));
                    e_O = 1 - localMaxSal(i,j);
                    e_C = 1-sum(sum(f.*mask_ex(i-1:i+1,j-1:j+1,frame)))/6;
                else
                    a = mask_ex(i-1:i+1,j-1:j+1,frame-L_t+1:frame-1).*(1-sals_ex(i-1:i+1,j-1:j+1,frame-L_t+1:frame-1)).*W_pre;
                    b = (1-sals_ex(i-1:i+1,j-1:j+1,frame-L_t+1:frame-1)).*W_pre;
                    e_T = sum(a(:))/sum(b(:));
                    e_O = localMinSal(i,j);
                    e_C = sum(sum(f.*mask_ex(i-1:i+1,j-1:j+1,frame)))/6;
                end
                E_new(i,j) = T_t*e_T + T_o*e_O + T_c*e_C;
                mask_ex(i,j,frame) = ~mask_ex(i,j,frame);
            end
        end
        ind = E_new<E;
        if ~any(ind(:))
            break
        end
        mask(ind) = ~mask(ind);
        mask_ex(:,:,frame) = mask;
        E(ind) = E_new(ind);
    end
    % compute the saliency map based on saliency mask
    for i=2:size(mask_ex,1)-1
        for j=2:size(mask_ex,2)-1
            if mask_ex(i,j,frame)
                tmp = (sals_ex(i-1:i+1,j-1:j+1,frame-L_t+1:frame).*W);
                sal(i,j) = max(tmp(:));
            else
                tmp = (1-sals_ex(i-1:i+1,j-1:j+1,frame-L_t+1:frame)).*W;
                sal(i,j) = 1-max(tmp(:));
            end
        end
    end
    obdl_maps(:,:,frame-L_t) = sal(2:end-1,2:end-1);
end

S = Normalize3d(obdl_maps);

S = imresize(S,2,'bilinear');
S = Normalize3d(S);

% handle when no saliency is detected for a frame
zeroSaliency = find(sum(sum(S,1),2)==0);
if ~isempty(zeroSaliency)
    fprintf('There was no saliency for %i frames\n',sum(zeroSaliency));
    for i=1:numel(zeroSaliency)
        if zeroSaliency(i) == 1
            gaussMap = fspecial('gaussian',[size(S,1) size(S,2)],ONE_DEGREE_MBLKS/4);
            % equal to pixel-based Gaussian blob of one visual digree
            S(:,:,1) = gaussMap / max(gaussMap(:));
        else
            S(:,:,zeroSaliency(i)) = S(:,:,zeroSaliency(i)-1);
        end
    end
end

S = imresize(S,2,'nearest');
Saliency = uint8(S*255);