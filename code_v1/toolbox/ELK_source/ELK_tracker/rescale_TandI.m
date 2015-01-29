function [ T, I, StandardDev, Scales]=rescale_TandI(T,I,prm,Scales)
% Scale T and I
% If Scales are given, they are used
% Otherwise the scales are et such that the dtaa will have std of prm.TotalSTD

if ~exist('Scales','var') || isempty(Scales)
    ComputeScales=1;
else
    ComputeScales=0;
end

for f=1:size(T,3)
    if ComputeScales
        StandardDev(f)=std( [ reshape(I(:,:,f),[],1) ; reshape(T(:,:,f),[],1) ]);
        Scales(f)= StandardDev(f)/prm.TotalSTD;
    end
    I(:,:,f)=I(:,:,f)/Scales(f);
    T(:,:,f)=T(:,:,f)/Scales(f);
end

