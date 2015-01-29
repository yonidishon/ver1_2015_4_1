% im            - n x m x 3
% mode          - 'train or 'test'
% prm           - params struct
% bbox          - for 'train' target bbox
% classifier    - classifier data struct

function [pr_fg,pr_bg,classifier] = FG_BG_model(im,mode,prm,bbox,classifier,mask)

pr_fg = [];
pr_bg = [];

% get patch size and image size
N = prm.patch_size;

im_sz = size(im);
if numel(im_sz)==2
    im_sz(3) = 1;
end

% pad image so SIFT returns proper size
im_tmp = padarray(im,[3,3,0],'symmetric','pre');
im_tmp = padarray(im_tmp,[4,4,0],'symmetric','post');
% allocat memory
dims = prm.USE_SIFT*prod(prm.sift_geomerty)+N^2*im_sz(3);
P = zeros(dims,prod(im_sz(1:2)));

% compute dense sift
if prm.USE_SIFT
    im_gray = padarray(single(im(:,:,1)),[2,2],'symmetric','both');
    if prm.SIFT_LOW_PASS
        im_gray = imfilter(im_gray,fspecial('gaussian',N/2));
    end
    [F,dsift] = vl_dsift(im_gray,'size',prm.sift_size,'step',prm.sift_step,...
        'geometry',prm.sift_geomerty,'fast','FloatDescriptors','norm');
end

% concatinate dsift and color neighborhood for each pixel
P(1:im_sz(3)*N^2,:) = my_im2col_color_fast_mex(im_tmp,N);
if prm.USE_SIFT
    P(im_sz(3)*N^2+1:end,:) = double(dsift);
end

switch mode
    case 'train'
        % prepare positive and negative example regions
        v = prm.neg_region;
        w = bbox(3)-bbox(1);
        h = bbox(4)-bbox(2);
        if isempty(mask)
            W=[];   WeightsFlag=0;
            mask = zeros(im_sz(1:2));
            y0 = max(1,bbox(2)-floor(h*v));
            y1 = min(bbox(2)+floor((1+v)*h),im_sz(1));
            x0 = max(1,bbox(1)-floor(w*v));
            x1 = min(bbox(1)+floor((1+v)*w),im_sz(2));
            mask(y0:y1,x0:x1) = 1;
            mask(bbox(2):bbox(4),bbox(1):bbox(3)) = 2;
        else
            WeightsFlag=1;
            Inmask=mask;
            % Outside the bounding box it is background
            y0 = max(1,bbox(2)-floor(h*v));
            y1 = min(bbox(2)+floor((1+v)*h),im_sz(1));
            x0 = max(1,bbox(1)-floor(w*v));
            x1 = min(bbox(1)+floor((1+v)*w),im_sz(2));
            maskW=nan*ones(im_sz(1:2));
            maskW(y0:y1,x0:x1) = -1;    % maskW is a signed (according to the label) weighted pixel map
            % Inside the bounding box pixel label depends on the objecthood mask
            maskW(bbox(2):bbox(4),bbox(1):bbox(3)) = Inmask*2-1;
            % set mask so  Of,Bf will be configured correctly
            mask = 0.5*( sign(maskW) )+1.5; % labels such that forground pixels are 2, background are 1)
        end
        Of = P(:,mask(:)==2); % bag of FG patches
        Ob = P(:,mask(:)==1); % bag of BG patches
        
        % Normalize the pixel weights
        if WeightsFlag
            indsBG=find(mask==1);
            Wb=(1-prm.FGweight)*maskW(indsBG)/sum(maskW(indsBG));
            indsFG=find(mask==2);
            Wf=prm.FGweight*maskW(indsFG)/sum(maskW(indsFG));
            assert( all(Wb>=0) && all(Wf>=0));
            W=[ Wb ; Wf];
        end
        
        % train classifier
        classifier = adaBoostTrain(Ob', Of', W,prm.pBoost);
        
    case 'test'
        % classify samples
        pr = double(adaBoostApply( P', classifier, [], [], []));
        pr = reshape(pr,[im_sz(1:2)]);
        % adjust margins using sigmoid
        pr_fg = 1./(1+exp(-prm.sigmoid_a*(pr-prm.sigmoid_b)));
        pr_fg(pr_fg<prm.min_pr_val) = prm.min_pr_val;
        pr_bg = 1./(1+exp(-prm.sigmoid_a*(-pr-prm.sigmoid_b)));
        pr_bg(pr_bg<prm.min_pr_val) = prm.min_pr_val;
end