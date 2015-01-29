function PR = ChannelPR( vars, prm )
% The function accpets a vector 1*l of error variances of channels. It returns a
% vector 1*l of coeeficients to multiply the variances with. 

% The coeffcients reflect how likely it is that the error in the channel is
% not random, i.e. that the channel is relevant for template matching.

% Two relevance scores are supproted:
%   if prm.ChannelPRModel.FixedChannelPRior exist, it contains fixed
%   coefficients reflecting the relevance of each channel
%
%   if prm.ChannelPRModel.ChannelWeightAtLR1 exists, the channel relevance
%   depends on the error variance (lower error variance - higher channel
%   relevance). This part assumes that the total data variance is 1.
%   The coeffcients are between 1 (the channel is sure to be relevant,
%   obtained for Var=0) and prm.ChannelPRModel.ChannelWeightAtLR1 (the
%   cnahhel is not likely to be relevant, obtained for Var=1).

l=length(vars);
PR=ones(1,l);

% No Channel relevance inference
if ~isfield(prm,'ChannelPRModel') || isempty(prm.ChannelPRModel)
    return;
end

% Fixed relevance for each channel
if isfield(prm.ChannelPRModel,'FixedChannelPRior')
    PR=prm.ChannelPRModel.FixedChannelPRior(1:length(vars));
end

% Variance depedent channel relevance
if isfield(prm.ChannelPRModel,'ChannelWeightAtLR1') && ~isempty(prm.ChannelPRModel.ChannelWeightAtLR1)
    a=(1-prm.ChannelPRModel.ChannelWeightAtLR1)/(prm.ChannelPRModel.ChannelWeightAtLR1);
    PR=  PR.* 1./(1+a*vars.^0.5);
end

