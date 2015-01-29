% measure jaccard index for all frames in res_file relative to ann_file
% res_idx,ann_idx indicate from what columns to read the data [c0,c1]
% if data is spaned in 4 columns assume rect [x,y,w,h]
% if data is spaned in 8 columns assume vert [x0,..,x3,y0,..,y3]
 
function [J] = measure_jaccard_for_seq(res_file,res_idx,ann_file,ann_idx)

% load results and annotations
try
    if ischar(res_file)
        res = load(res_file);
    else
        res = res_file;
        res_file = '';
    end
catch
    warning('unable to load results file\n(%s)',res_file);
    J = [];
    return;
end
try
    ann = load(ann_file);
catch
    warning('unable to load annotations file\n(%s)',ann_file);
    J = [];
    return;
end


% set result type
switch diff(res_idx)
    case 3
        res_type = 'rect';
    case 7
        res_type = 'vert';
    otherwise
        error('Results spanning %d columns are not supported, should either be rect(4) or vert(8)',diff(res_idx)+1);
end

% set annotaion type
switch diff(ann_idx)
    case 3
        ann_type = 'rect';
    case 7
        ann_type = 'vert';
    otherwise
        error('Annotations spanning %d columns are not supported, should either be rect(4) or vert(8)',diff(res_idx)+1);
end

n_res = size(res,1);
n_ann = size(ann,1);

N = n_res;
if n_res < n_ann    
    warning('result length is shorter than annotation length (%s)',res_file);
elseif n_res > n_ann
    N = n_ann;
    warning('annotation length is shorter than result length (%s)',res_file);
end
   
J = zeros(n_ann,1);
for n = 1:N
    
    switch res_type
        case 'rect'
            [vx,vy] = rect2vert(res(n,res_idx(1):res_idx(2)));
        case 'vert'
            vx = res(n,res_idx(1):res_idx(1)+3);
            vy = res(n,res_idx(1)+4:res_idx(2));
    end
    
    switch ann_type
        case 'rect'
            [ux,uy] = rect2vert(ann(n,ann_idx(1):ann_idx(2)));
        case 'vert'
            ux = ann(n,ann_idx(1):ann_idx(1)+3);
            uy = ann(n,ann_idx(1)+4:ann_idx(2));
    end
    
    J(n) = measure_jaccard_index(vx,vy,ux,uy);
    if isnan(J(n))
        J(n) = 0;
    end
end