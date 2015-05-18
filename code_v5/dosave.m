function dosave(fname,varargin)
    for ii = 1:length(varargin)/2
        theargs.(varargin{ii*2-1}) = varargin{ii*2};
    end
    save(fname,'-struct','theargs');
end


