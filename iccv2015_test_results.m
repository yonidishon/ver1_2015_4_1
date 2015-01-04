%  iccv2015_test_results 28/12/2014 Yonatan Dishon
%  This is the testing of the model.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% VERSIONS
% V0 -> STARTUP MODEL for research
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Run Setup
setup_videoSaliency;
%% settings
DataRoot = diemDataRoot; % DIEM dataset is the data
uncVideoRoot = fullfile(DataRoot, 'video_unc'); % uncompress video.
gazeDataRoot = fullfile(DataRoot, 'gaze'); % gaze data from the DIEM.
% visualizations results
% visRoot = fullfileCreate(DataRoot, 'cvpr13', 'jump_test_v6');
visRoot = saveRoot;

% modelFile = fullfile(uncVideoRoot, '00_trained_model_validation_v5_3.mat'); % validation
%modelFile = fullfile(uncVideoRoot, '00_trained_model_cvpr13_v5_3.mat'); % CVPR13

jumpType = 'all'; % 'cut' or 'gaze_jump' or 'random' or 'all'
sourceType = 'rect';
% measures = {'chisq', 'auc', 'cc', 'nss'};
measures = {'chisq', 'auc'};
methods = {'PCA','Dimtry','self', 'center', 'GBVS', 'PQFT', 'Hou'};

% cache settings - NA for my implementation 
% cache.root = fullfile(DataRoot, 'cache');
cache.frameRoot = fullfile(saveRoot, 'cache');
% cache.featureRoot = fullfileCreate(cache.root, '00_features_v6');
% cache.gazeRoot = fullfileCreate(cache.root, '00_gaze');
% cache.renew = true; % use in case the preprocessing mechanism updated
% cache.renewFeatures = true; % use in case the feature extraction is updated
% cache.renewJumps = true; % recalculate the final result

% gaze settings
gazeParam.pointSigma = 10;

% training and testing settings
%testIdx = [6,8,10,11,12,14,15,16,34,42,44,48,53,54,55,59,70,74,83,84]; % used by Borji

% testSubset = 11:length(testIdx);
% testSubset = 9;
%jumpFromType = 'prev-int'; % 'center', 'gaze', 'prev-cand', 'prev-int'
visVideo = true;
 candScale = 2; % Guassian scale index for candidate2map func.

% visualization
cmap = jet(256);
colors = [1 0 0;
    0 1 0;
    0 0 1;
    1 1 0;
    1 0 1;
    0.5 0.5 0.5;
    0 1 1];

%% prepare
videos = videoListLoad(DataRoot, 'DIEM');
nv = length(videos);

%testIdx = 2:2:nv;
testIdx = 2:2:nv-(nv-7);
testSubset = 1:length(testIdx);


% configure all detectors
[gbvsParam, ofParam, poseletModel] = configureDetectors();

% load model - NA for my implementation
% s = load(modelFile);
% rf = s.rf;
% options = s.options;
% options.useLabel = false; % no need in label while testing
% clear s;

nt = length(testSubset);

vers = version('-release');
verNum = str2double(vers(1:4));

if (~exist(visRoot, 'dir'))
    mkdir(visRoot);
end

sim = cell(nt, 1);

%% test
for i = 1:nt % number of videos to be tested
    iv = testIdx(testSubset(i));
    fprintf('Processing %s... ', videos{iv}); tic;
    
    % prepare video
    if (isunix) % use matlab video reader on Unix
        vr = VideoReaderMatlab(fullfile(uncVideoRoot, sprintf('%s.mat', videos{iv})));
    else
        if (verNum < 2011)
            vr = mmreader(fullfile(uncVideoRoot, sprintf('%s.avi', videos{iv})));
        else
            vr = VideoReader(fullfile(uncVideoRoot, sprintf('%s.avi', videos{iv})));
        end
    end
    m = vr.Height;
    n = vr.Width;
    videoLen = vr.numberOfFrames;
    param = struct('videoReader', vr); 
    
    % load jump frames - NA for my implementation
    %[jumpFrames, before, after] = jumpFramesLoad(DataRoot, iv, jumpType, 50, 30, videoLen - 30);
    % Going on all videos frames from 1 to VideoLen (Dmitry went from 30 to
    % VideoLen-30)
    [jumpFrames, before, after] = jumpFramesLoad(DataRoot, iv, jumpType, 50, 1, videoLen);
    nc = length(jumpFrames);
    
    % load gaze data
    s = load(fullfile(gazeDataRoot, sprintf('%s.mat', videos{iv}))); %george 
    gazeData = s.data;
    clear s;
    gazeParam.gazeData = gazeData.points;
    % NA in my implementation
%    videoLen = min(videoLen, length(gazeData.points)); %George
    
    resFile = fullfile(visRoot, sprintf('%s.mat', videos{iv}));
    if (exist(resFile, 'file')) % load from RESULT FILE if exist
        fprintf('(loading)... ');
        s = load(resFile);
        frames = s.frames;
        indFr = s.indFr;
        %cands = s.cands; NA in my implementation
        predMaps = s.predMaps;
        clear s;
        
    else % calculate the saliency maps from scrath
        cands = cell(nc, 1); % candidates per frame
        predMaps = zeros(m, n, nc); % dense maps
        Saliency_movie_v0(param.videoReader);
%         for ic = 1:nc
%             %if ((jumpFrames(ic) + before >= 3) && (jumpFrames(ic) + after <= videoLen))
%                 % source frame
% %                 if (strcmp(jumpFromType, 'center')) % jump from center
% %                     srcCands = {struct('point', [n/2, m/2], 'score', 1, 'type', 1, 'candCov', [(m/8)^2, 0; 0, (m/8)^2])}; % dummy source at center
% %                 elseif (strcmp(jumpFromType, 'gaze')) % jump from gaze map
% %                     srcGazeMap = points2GaussMap(gazeParam.gazeData{jumpFrames(ic)+before}', ones(1, size(gazeParam.gazeData{jumpFrames(ic)+before}, 1)), 0, [n, m], gazeParam.pointSigma);
% %                     [srcCands, ~, ~, ~] = sourceCandidates([], srcGazeMap, options, sourceType);
% %                 elseif (strcmp(jumpFromType, 'prev-cand')) % jump from previous candidate set
% %                     if (ic == 1 || isempty(cands{ic-1})) % first or empty previous
% %                         srcCands = {struct('point', [n/2, m/2], 'score', 1, 'type', 1, 'candCov', [(m/8)^2, 0; 0, (m/8)^2])}; % dummy source at center
% %                     else
% %                         srcCands = cands{ic-1};
% %                     end
% %                 elseif (strcmp(jumpFromType, 'prev-int')) % jump from previous integrated map
% %                     if (ic == 1 || isempty(cands{ic-1})) % first or empty previous
% %                         srcCands = {struct('point', [n/2, m/2], 'score', 1, 'type', 1, 'candCov', [(m/8)^2, 0; 0, (m/8)^2])}; % dummy source at center
% %                     else
% %                         srcCands = sourceCandidates([], predMaps(:,:,ic-1), options, sourceType);
% %                     end
% %                 else
% %                     error('Unsupported jump from type: %s', jumpFromType);
% %                 end
% %                 
% %                 %ic
% %                 dstCands = jumpPerform6(srcCands, jumpFrames(ic)+before, jumpFrames(ic)+after, param, options, gbvsParam, ofParam, poseletModel, rf, cache);
%                   predMaps(:,:,ic) = candidate2map(dstCands, [n, m], candScale);
% 
% 
% %                 cands{ic} = dstCands;
%             %end
%         end
        
        % compare - NA in my implementation
         frames = jumpFrames + after;
         indFr = find(frames <= videoLen);
        
        % save
        %save(fullfile(visRoot, sprintf('%s.mat', videos{iv})), 'frames', 'indFr', 'cands', 'predMaps');
        save(fullfile(visRoot, sprintf('%s.mat', videos{iv})),'frames', 'indFr','predMaps');
    
    end
    
    % visualize
    videoFile = fullfile(visRoot, sprintf('%s.avi', videos{iv}));
    saveVideo = visVideo && (~exist(videoFile, 'file'));
        
    sim{i} = zeros(length(methods), length(measures), length(indFr));
    if (saveVideo && verNum >= 2012)
        vw = VideoWriter(videoFile, 'Motion JPEG AVI'); % 'Motion JPEG AVI' or 'Uncompressed AVI' or 'MPEG-4' on 2012a.
        open(vw);
    end
    
    try
        for ifr = 1:length(indFr)
            fr = preprocessFrames(param.videoReader, frames(indFr(ifr)), gbvsParam, ofParam, poseletModel, cache);
            gazeData.index = frames(indFr(ifr));
            %%%%%%%%%%%%%%%%%%%%%%%%% YONATAN 28/12/2014%%%%%%%%%%%%%%%%%%%%%
            % Dimtry's results aren't obtain for the video visualization but
            % are obtained for the graphes!
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            [sim{i}(:,:,ifr), outMaps] = similarityFrame3(predMaps(:,:,indFr(ifr)), gazeData, measures, ...
                'self', ...
                struct('method', 'center', 'cov', [(n/16)^2, 0; 0, (n/16)^2]), ...
                struct('method', 'saliency_GBVS', 'map', fr.saliencyGBVS), ...
                struct('method', 'saliency_PQFT', 'map', fr.saliencyPqft), ...
                struct('method', 'saliency_Hou', 'map', fr.saliencyHou));
%             [sim{i}(:,:,ifr), outMaps, extra] = similarityFrame2(predMaps(:,:,indFr(ifr)), gazeParam.gazeData{frames(indFr(ifr))}, gazeParam.gazeData(frames(indFr([1:indFr(ifr)-1, indFr(ifr)+1:end]))), measures, ...
%                 'self', ...
%                 struct('method', 'center', 'cov', [(n/16)^2, 0; 0, (n/16)^2]), ...
%                 struct('method', 'saliency_GBVS', 'map', fr.saliency), ...
%                 struct('method', 'saliency_PQFT', 'map', fr.saliencyPqft), ...
%                 struct('method', 'saliency_Hou', 'map', fr.saliencyHou));
            if (saveVideo && verNum >= 2012)
                measnms={'Proposed','Center','GBVS','PQFT','Hou'};
                outfr = renderSideBySide(fr.image, outMaps, colors, cmap, sim{i}(:,:,ifr),measnms);
                writeVideo(vw, outfr);
            end
        end
    catch me
        if (saveVideo && verNum >= 2012)
            close(vw);
        end
        rethrow(me);
    end
    
    if (saveVideo && verNum >= 2012)
        close(vw);
    end

    fprintf('%f sec\n', toc);
end

save(fullfile(visRoot, '00_similarity.mat'), 'sim', 'measures', 'methods', 'testIdx', 'testSubset');

%% visualize
nmeas = length(measures);
for im = 1:length(measures)
    meanChiSq = nan(nt, length(methods));
    for i = 1:nt
        for j = 1:length(methods)
            chiSq = sim{i}(j,im,:);
            meanChiSq(i, j) = mean(chiSq(~isnan(chiSq)));
        end
    end
    
    ind = find(~isnan(meanChiSq(:,1)));
    meanChiSq = meanChiSq(ind, :);
    meanMeas = mean(meanChiSq, 1);
    lbl = videos(testIdx(testSubset(ind)));
    
    % add dummy if there is only one test
    if (size(meanChiSq, 1) == 1), meanChiSq = [meanChiSq; zeros(1, length(methods))]; end;
    
    figure, bar(meanChiSq);
    imLabel(lbl, 'bottom', -90, {'FontSize',8, 'Interpreter', 'None'});
    ylabel(measures{im});
    title(sprintf('Mean %s', mat2str(meanMeas, 2)));
    legend(methods);
    
    print('-dpng', fullfile(visRoot, sprintf('overall_%s.png', measures{im})));
end

% histogram
visCompareMethods(sim, methods, measures, videos, testIdx(testSubset), 'boxplot', visRoot);
