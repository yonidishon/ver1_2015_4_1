function [ Q, LL , Theta ] =calculateP_andLL(Image,Template,Theta,Scales,prm,classifier,pr_T_fg,pr_T_bg, lk_im)
% Compute the objecthood probabilities and the log likelihood of the model 
% for given Image Patch and Template.
% Input: 
%   Image - the image patch (of the same size as the template patch)
%   Template - the template patch
%   Theta - a parameter vector of the current model. Fields are
%           Vars - a vector of f*1 of variances of the channels 1,..,f. 
%                  If not given (empty) it is roughly estimated inside, as the
%                  variance of object pixels of the template only (to be used an the intial conditions, when template and image are the same)
%           FGPrior - the prior probability of a pixel in the object rectangle to be foreground.
%   Scales - a vector of f*1 of scaling factors. The image and  template channels are divided 
%                 by the corresponding scaling factors before posterior and LL computation.
%   prm - a parameter sturcture of the algorithm
%   pr_T_fg,pr_T_bg (optional) - the likelihood of the template under the foreground and background models.
%                                If given, is saves recomputation of them in this function
%   lk_im - the image neighborhood used for obtainiing bg/fg model. It is
%   only used for visual debugging.

% Output:
%  Q -  a structure containing the objecthood probabilities:
%       Q.wI - the object probability for the image pixels
%       Q.wT - the object probabilities for the template pixels
%       Q.w - the object probabilites for both template and image
%  LL - the log likelihood of the current template and image
%  Vars - the variances of error in the feature channels (computed inside if not given)

Vars=Theta.Vars;
FGP=Theta.FGPrior;

% compute target FG/BG liklihood
if ~exist('pr_T_fg','var') || ~exist('pr_T_bg','var')
    [pr_T_fg,pr_T_bg,~] = FG_BG_model(Template,'test',prm.fgbg,[],classifier,[]);
end
% compute image FG/BG liklihood
[pr_I_fg,pr_I_bg,~] = FG_BG_model(Image,'test',prm.fgbg,[],classifier,[]);

% The squared error term P(T-I)
if isempty(Vars)
    pr_err=ones(size(Template,1),size(Template,2));
    Theta.Vars = ones(1,size(Template,3));
else
    % Normalize the data range
    [ Template, Image]=rescale_TandI(Template,Image,[],Scales);
    
    % Compute the template matching contribution to the objecthood probability
    szT = size(Template);
    WVars= ChannelPR( Vars, prm.lkprm ).*Vars; % multiply variances by channel relevance probability
    SigMat=reshape(ones(szT(1)*szT(2),1)*WVars,szT(1),szT(2),numel(WVars)); % Three sigma matrices, one per channel
    pr_err = (1./sqrt(2*pi*SigMat)).*exp(-((Image-Template).^2)./(2*SigMat));
    pr_err = prod(pr_err(:,:,find(prm.lkprm.ChannelsUsed)),3);    
end


% Compute objecthood weights 
if prm.USE_LOG_TERMS
    P11 = FGP^2*pr_I_fg.*pr_T_fg.*pr_err;
else
    P11 = FGP^2*pr_I_fg.*pr_T_fg;
end
Denom = P11 + FGP*(1-FGP)*pr_I_fg.*pr_T_bg + FGP*(1-FGP)*pr_I_bg.*pr_T_fg + (1-FGP)^2*pr_I_bg.*pr_T_bg + eps;
Q.wI= (P11 + FGP*(1-FGP)*pr_I_fg.*pr_T_bg)./ Denom; % object probability of Image pixels
Q.wT= (P11 + FGP*(1-FGP)*pr_T_fg.*pr_I_bg)./ Denom; % Object probability for template pixels
Q.w= P11./Denom; % probability that both image and template pixels are object

% Compute log-likelihood
LLperPixel = log(Denom);
LL=sum(sum(LLperPixel));

% Adaptive priors
if prm.lkprm.FGBGPriors==2 
    Theta.FGPrior = sum(sum(Q.wI+Q.wT))/(2*numel(Q.wI));
    Theta.FGPrior = max (Theta.FGPrior, prm.lkprm.LowestFGPrior);
end

