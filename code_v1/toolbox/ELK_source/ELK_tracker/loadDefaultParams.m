% Set default parameters

function [prm] = loadDefaultParams

%% general and I/O
prm.ver = 'ELK_public';
prm.runName = 'Deer';
% For demo only
cdir = cd('..');
prm.inputDir = fullfile(pwd,prm.runName,'img');
prm.outputDir = fullfile(pwd,'Deer_Results');
prm.annFile = fullfile(pwd,prm.runName,'groundtruth_rect.txt');
cd(cdir);
prm.add_tstamp = 0;
prm.initFrame = 1 ; % initial frame 
prm.finFrame = -1;  % final frame or -1 to process all
prm.target0 = [];   % target bbox at initFrame if empty will manually get from user (unless START_FROM_GT = 1)
prm.START_FROM_GT = 1; % init tracking from ground truth

%% debug flags
prm.occDispResults = 0;
prm.DisplayGT = 1;

%% template upadate and occlusion params
prm.template_update_freq  = 5;
prm.fgbg_update_freq = 7;
prm.w_percentile = 5;
prm.w_percentile_th = 0.75;
prm.DO_OCC = 1; % use occlusion handling module
prm.ADDAPTIVE_OCC_TH = 1;
prm.occ_th_min = 0.075;
prm.occ_th_max = 5;
prm.occ_med_samples = 15;
prm.occ_th = 0.2;
prm.occ_recovery_th_gain = 1.5;
prm.occ_recovery_min_interval_for_update = 4;
prm.occCheckTemplateAndLL = 0;
prm.occTHGain = 2;
prm.occExhasutSearchWithOldTemplates = 1;
prm.occResizeTemplate = 0;
% Check Previous templates
prm.CheckOldTemplatesBeforeUpdate=1;
prm.UsePrevTemplatesThemselves = 0;
prm.KeepPrevTemplate=1;

%% kalman filter params
prm.USE_KALMAN = 1;
% prm.kalman_dynamic_model = 'zero_motion';
prm.kalman_dynamic_model = 'const_speed';
switch prm.kalman_dynamic_model
    case 'zero_motion'
        % X = [x,y,scl]
        prm.Q_kf = [1, 1, 1]; % process noise Q = diag(Q_kf)
        prm.P_kf = 0.01*[1, 1, 1]; % initial noise est P0 = diag(P_kf)
        prm.R_kf = [1, 1, 1];     % measurment noise gains        
    case 'const_speed'
        % X = [x,x_dot,y,y_dot,scl]
        prm.Q_kf = [1, 1, 1, 1, 1]; % process noise Q = diag(Q_kf)
        prm.P_kf = 0.01*[1, 1, 1, 1, 1]; % initial noise est P0 = diag(P_kf)
        prm.R_kf = [0.1, 0.1, 0.1, 0.1, 1];     % measurment noise gains
end

%% LK params
prm.lkprm.lkROI = 0.5; % ROI for LK is lkROI*max(size(target)) in each direction
prm.lkprm.lkA0 = -1;   %desired target area in pixels (for acceleration - damages performance) -1 to disable
prm.lkprm.warpMat =[... % T,T+U-scale,T+NU-scale,Sim,Affine
    1,1,0,0,0 ;... % Transforms for Level 1
    1,0,0,0,0];    % Transforms for Level 2 
prm.lkprm.lkDoExhuastiveFromLevel = 2;
prm.lkprm.lkEpsilon = 0.001; 
prm.lkprm.lkMaxIter = 5;   
prm.lkprm.ChannelsUsed=[ 1 1 1];  % which image channels to use during tracking. Three flags
prm.lkprm.USE_LOG_TERMS = 1;
prm.lkprm.updateVarInLK=1;
prm.lkprm.TotalSTD=1; % the [template,image] are rescaled to have std of TotalSTD 
prm.lkprm.ErrorSTD_multiplier = 1; % the error std is set to ErrorSTD_multiplier*(the actual STD). The default is 1.
prm.lkprm.FGBGPriors = 2;     % 0 - no FGBG prior  (they equal 0.5 each)  
%                             1 - fixed prior according to prm.lkprm.InitPriors
%                             2 - adaptive prior (regulated by their own meta prior) - to support in the future)
prm.lkprm.InitFGPrior=0.8;
prm.lkprm.LowestFGPrior=0.7;        % A lower bound on onjecthood prior. Applies only if adaptive priors is on (FGBGPriors=2)
prm.lkprm.GaussNewton=1;    % 1 - Standard Gauss Newton  2 - Levenberg-Marquardt
% Add cahnnel relevance probability logic
prm.lkprm.ChannelPRModel.ChannelWeightAtLR1=0.2;
prm.lkprm.ChannelPRModel.FixedChannelPRior=[ 1 1 1 ];

% Parameters for probabilistic model
prm.PercentileForUniform=0.1;
prm.USE_LOG_TERMS = prm.lkprm.USE_LOG_TERMS;
prm.ESTIMATE_SIG_ERR = 1;   % if 0 sigmas are not adaptively estimated, but kept fix.

%% params for FG/BG segmentation model
% general
prm.fgbg.neg_region = 0.5;
prm.fgbg.patch_size = 8;
prm.fgbg.min_pr_val = 0;
% sift
prm.fgbg.USE_SIFT = 1;
prm.fgbg.SIFT_LOW_PASS = 1; % do gaussian low pass before sift
prm.fgbg.sift_step = 1;
prm.fgbg.sift_size = 4;
prm.fgbg.sift_geomerty =  [2 2 8]; %[2 2 8];
prm.FGBGupdateWithWeights=1;    % Use objecthood weights when doing FG/BG model update
prm.fgbg.FGweight=0.5;          % When objechood weights are used: dtetrmine the total weight of foreground pixel 
% adaboost
pTree.nBins       = [64]   ;     %maximum number of quanizaton bins (<=256)
pTree.maxDepth    = [1]    ;     %maximum depth of tree
pTree.minWeight   = [.05]  ;     %minimum sample weigth to allow split
pTree.fracFtrs    = [0.5]  ;     %fraction of features to sample for each node split
pTree.nThreads    = [inf]  ;     %max number of computational threads to use
prm.fgbg.pBoost.pTree      = pTree  ;     %parameters for binaryTreeTrain
prm.fgbg.pBoost.nWeak      = [32]  ;     %number of trees to learn
prm.fgbg.pBoost.discrete   = [1]    ;     %train Discrete-AdaBoost or Real-AdaBoost
prm.fgbg.pBoost.verbose    = [0]    ;     %if true print status information
% sigmoid
prm.fgbg.sigmoid_a = 5;
prm.fgbg.sigmoid_b = 0.3;