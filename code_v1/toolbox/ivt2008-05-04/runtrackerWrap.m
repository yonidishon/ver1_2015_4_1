function next_BB = runtrackerWrap(BB,frame)
% Yonatan Dishon -Created 19/1/2015
% runtrackerWrap take the current BB and frame and calculate the BB in the
% next frame
%Inputs:
%Outputs:
opt = struct('numsample',600, 'condenssig',0.25, 'ff',1, ...
    'batchsize',5, 'affsig',[9,9,.05,.05,.005,.001]);
opt.dump = dump_frames;

end

