

function [target0] = get_initial_target_from_user(im,prm)

if isempty(prm.target0)
        figure(1);
        [T,target0] = imcrop(im);
        close(1);
else
        target0 = prm.target0;
end



