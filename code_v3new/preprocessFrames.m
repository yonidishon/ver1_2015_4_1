function frs = preprocessFrames(vr, frIdx, gbvsParam, ofParam, poseletModel, cache)
% Preprocesses video frames by calculating statis saliency, optical flow,
% face and poselet detector. Can work with frame cache.
%
% frs = preprocessFrames(vr, frIdx, gbvsParam, ofParam, poseletModel, cache)
% frs = preprocessFrames(vr, frIdx, gbvsParam, ofParam, poseletModel)
%
% INPUT
%   vr              video stream as VideoReader object
%   frIdx           indices of the relevant frames inside the video stream
%                   to calculte on
%   gbvsParam       options for static saliency (GBVS) calculation. Output
%                   of configureDetectors() function
%   ofParam         options for optical flow calculation. Output of
%                   configureDetectors() function
%   poseletModel    model for poselet detection. Output of
%                   configureDetectors() function
%   cache           if set the cache will be used. This is a structure:
%       .frameRoot      root folder for the frame cache
%       .renew          if set to true the cache data will be overwritten
%
% OUTPUT
%   frs             cell array of preprocessed frames. If there is only one
%                   frame cell array is not created. Includes
%       .width, .height     the dimentions of the frame
%       .image              original frame
%       .ofx, .ofy          optical flow
%       .saliencyPCA        static saliency
%       .objectness         probability map of object in frame
%       .segments           SLIC superpixels on each frame
%       .faces              detected face rectangles
%       .poselet_hit        poselet hits
%       .index              frame index in video
%       .videoName          video file name

% TO RETRIVE INFORMATION FROM THE DIMTRY CACHE YD %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~strcmp('cgm41',getComputerName())
    DIMAResultFolder='\\CGM41\Users\gleifman\Documents\DimaCode\DIEM\cache';
    %DIMAPredictFolder='\\CGM10\Users\ydishon\Documents\Video_Saliency\DimaResults\jump_test_v7';  
     DIMAPredictFolder='\\CGM10\Users\ydishon\Documents\Video_Saliency\DimaResults\jump_test_v6_orig';  
else
    DIMAResultFolder='C:\Users\gleifman\Documents\DimaCode\DIEM\cache';
    %DIMAPredictFolder='\\CGM10\Users\ydishon\Documents\Video_Saliency\DimaResults\jump_test_v7';
     DIMAPredictFolder='\\CGM10\Users\ydishon\Documents\Video_Saliency\DimaResults\jump_test_v6_orig';  
end
onlyname=strsplit(vr.Name,'.');
onlyname=onlyname{1};
DIMEPredvfile=fullfile(DIMAPredictFolder,sprintf('%s.mat',onlyname));
predflag=0;
if exist(DIMEPredvfile,'file')
    DIMAPredmat=matfile(fullfile(DIMAPredictFolder,sprintf('%s.mat',onlyname)));
    predflag=1;
else
    predflag=0;
end
% TO RETRIVE INFORMATION FROM THE DIMTRY CACHE YD %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (exist('cache', 'var'))
    cacheDir = fullfile(fullfile(cache.frameRoot, vr.Name));
    if (~exist(cacheDir, 'dir'))
        mkdir(cacheDir);
    end
else
    cacheDir = [];
end

nfr = length(frIdx);
if nargout~=0
    frs = cell(nfr, 1);
end
NUMWINDOBJ=1000;

for ifr = 1:nfr
    ind = frIdx(ifr);
    cacheFile = fullfile(cacheDir, sprintf('frame_%06d.mat', ind));
    
    if (exist('cache', 'var') && exist(cacheFile, 'file') && ~cache.renew) % load from cache
        s = load(cacheFile);
        data = s.data;
        % support image data
        if (~isfield(s.data, 'image')) % there is no image data - add it
            data.image = read(vr, ind);
            save(cacheFile, 'data');
        end
        % motion
        if ((~isfield(s.data,'ofx')) || (~isfield(s.data,'ofy')))
            % 1st or second frame no data on optical flow
            if ind==1 || ind==2
                [data.ofx, data.ofy]=deal(zeros(size(f,1),size(f,2)));
                save(cacheFile, 'data');
            else
                fp = read(vr, ind - 2);
                [data.ofx, data.ofy] = Coarse2FineTwoFrames(f, fp, ofParam);
                save(cacheFile, 'data');
            end
        end
        DimaCacheFile=fullfile(DIMAResultFolder,vr.name,sprintf('frame_%06d.mat', ind));
        DimaFlag=0;
        if exist(DimaCacheFile,'file')
            Dima_data=load(DimaCacheFile);
            DimaFlag=1;
        else
            DimaFlag=0;
        end
        if (~isfield(s.data, 'saliencyPqft')) % there is no PQFT data add it
            if DimaFlag && isfield(Dima_data.data,'saliencyPqft')
                data.saliencyPqft = Dima_data.data.saliencyPqft;
            elseif (ind > 3)
                img_3 = read(vr, ind - 3);
                [~, ~, saliencyMap] = PQFT_2(data.image, img_3, 'gaussian', 64, 'color');
                data.saliencyPqft = saliencyMap;
            else
                data.saliencyPqft = zeros(data.height, data.width);
            end
            save(cacheFile, 'data');
        end
        if (~isfield(s.data, 'saliencyHou')) % there is no Hou saliency add it
            if DimaFlag && isfield(Dima_data.data,'saliencyHou')
                data.saliencyHou =Dima_data.data.saliencyHou;
            else
                data.saliencyHou = saliencyHouNips(data.image, gbvsParam.HouNips.W);
            end
            save(cacheFile, 'data');
        end
        if (~isfield(s.data, 'index')) % add frame index
            data.index = ind;
            data.videoName = vr.name;
            save(cacheFile, 'data');
        end
        if (~isfield(s.data, 'saliencyPCA')) % there is no PCA saliency data - add it
            data.saliencyPCA = PCA_Saliency(data.image); 
            save(cacheFile, 'data');
        end
        if (~isfield(s.data, 'saliencyMotionPCA')) % there is no Motion PCA saliency data - add it
            data.saliencyMotionPCA = PCA_Motion_Saliency(data.ofx,data.ofy,data.image);
            save(cacheFile, 'data');
        end
        if (~isfield(s.data, 'saliencyMotionPCAPolar')) % there is no Motion PCA saliency data - add it
            data.saliencyMotionPCAPolar = PCA_Motion_Saliency_Polar(data.ofx,data.ofy,data.image);
            save(cacheFile, 'data');
        end
        
        if ~isfield(s.data,'saliencyDIMA') && predflag ;
            data.saliencyDIMA=DIMAPredmat.predMaps(:,:,find(DIMAPredmat.frames(1,:)==ind));
            save(cacheFile, 'data');
        end
        if (~isfield(s.data, 'saliencyGBVS')) % there is no PCA saliency data - add it
            if DimaFlag && isfield(Dima_data.data,'saliencyGBVS') 
                data.saliencyGBVS =Dima_data.data.saliencyGBVS;
            elseif DimaFlag && isfield(Dima_data.data,'saliency') % apperantly the same
                data.saliencyGBVS =Dima_data.data.saliency;
            else
                fg = rgb2gray(data.image);
                if ((max(fg(:)) - min(fg(:))) < 40 || sum(imhist(fg) == 0) > 200) % not contrast enough
                    data.saliencyGBVS = zeros(data.height, data.width);
                else
                    if (data.height < 128)
                        scale = 2;
                        ff = imresize(f, scale);
                    else
                        scale = 1;
                        ff = data.image;
                    end
                    salOut = gbvs(ff, gbvsParam);
                    if (scale > 1)
                        salOut.master_map_resized = imresize(salOut.master_map_resized, 1/scale);
                    end
                    data.saliencyGBVS = salOut.master_map_resized;
                end
            end
            save(cacheFile, 'data');
        end
        if (~isfield(s.data,'objectness'))
            data.objectness=computeObjectnessmap(data.image,NUMWINDOBJ);
            save(cacheFile, 'data');
        end
        if (~isfield(s.data,'Fused_Saliency'))
            %data.Fused_Saliency=data.saliencyMotionPCA.*data.saliencyPCA;
            data.Fused_Saliency=PCA_Fused_Saliency(data.ofx,data.ofy,data.image);
            save(cacheFile, 'data');
        end
        
                if (~isfield(s.data,'segments'))
                    if (size(data.image,3)==1) % grayscale image is treated as colored
                        I_RGB=repmat(data.image,[1 1 3]);
                        I_LAB = single(rgb2lab(I_RGB));
                    else
                        I_LAB = single(rgb2lab(data.image));
                    end
                    SEGMENTS = vl_slic(I_LAB, 16, 300,'MinRegionSize',16);
                    [~, ~, n] = unique(SEGMENTS); %Ensure no missing index
                    data.segments = reshape(n,size(SEGMENTS)); %Ensure no missing index
                end
        clear s;
        if nargout~=0
            frs{ifr} = data;
        end
        continue;
    end
    
    data.width = vr.Width;
    data.height = vr.Height;
    
    f = read(vr, ind);
    data.image = f;
    
    % motion
    % 1st or second frame no data on optical flow
    if ind==1 || ind==2
        [data.ofx, data.ofy]=deal(zeros(size(f,1),size(f,2)));
    else
        fp = read(vr, ind - 2);
        [data.ofx, data.ofy] = Coarse2FineTwoFrames(f, fp, ofParam);
    end
    
    %Objectness
    data.objectness=computeObjectnessmap(data.image,NUMWINDOBJ);
    
    %     %SLIC
    %     if (size(data.image,3)==1) % grayscale image is treated as colored
    %         I_RGB=repmat(data.image,[1 1 3]);
    %         I_LAB = single(rgb2lab(I_RGB));
    %     else
    %         I_LAB = single(rgb2lab(data.image));
    %     end
    %     SEGMENTS = vl_slic(I_LAB, 16, 300,'MinRegionSize',16);
    %     [~, ~, n] = unique(SEGMENTS); %Ensure no missing index
    %     data.segments = reshape(n,size(SEGMENTS)); %Ensure no missing index
    if  predflag
        data.saliencyDIMA=DIMAPredmat.predMaps(:,:,find(DIMAPredmat.frames(1,:)==ind));
    end
    %%%%% static saliency %%%%%%
    
    % PCA saliency
    data.saliencyPCA = PCA_Saliency(data.image);
    
    %%%%% Motion saliency %%%%%%
    data.saliencyMotionPCA = PCA_Motion_Saliency(data.ofx,data.ofy,data.image);
    
    %%%%%%%%% OTHER SALIENCY METHODS (ALREADY COMPUTED BY DIMA ON DIEM)%%%%%%%%
    DimaCacheFile=fullfile(DIMAResultFolder,vr.name,sprintf('frame_%06d.mat', ind));
    DimaFlag=0;
    if exist(DimaCacheFile,'file')
        Dima_data=load(DimaCacheFile);
        DimaFlag=1;
    else
        DimaFlag=0;
    end
    % GBVS saliency
    if DimaFlag && isfield(Dima_data.data,'saliencyGBVS')
        data.saliencyGBVS =Dima_data.data.saliencyGBVS;
    elseif DimaFlag && isfield(Dima_data.data,'saliency')
        data.saliencyGBVS =Dima_data.data.saliency;
    else
        fg = rgb2gray(f);
        if ((max(fg(:)) - min(fg(:))) < 40 || sum(imhist(fg) == 0) > 200) % not contrast enough
            data.saliencyGBVS = zeros(data.height, data.width);
        else
            if (data.height < 128)
                scale = 2;
                ff = imresize(f, scale);
            else
                scale = 1;
                ff = f;
            end
            
            salOut = gbvs(ff, gbvsParam);
            if (scale > 1)
                salOut.master_map_resized = imresize(salOut.master_map_resized, 1/scale);
            end
            data.saliencyGBVS = salOut.master_map_resized;
        end
    end
        % PQFT saliency
        if DimaFlag && isfield(Dima_data.data,'saliencyPqft')
            data.saliencyPqft =Dima_data.data.saliencyPqft;
        else
            if (ind > 3)
                img_3 = read(vr, ind - 3);
                [~, ~, saliencyMap] = PQFT_2(data.image, img_3, 'gaussian', 64, 'color');
                data.saliencyPqft = saliencyMap;
            else
                data.saliencyPqft = zeros(data.height, data.width);
            end
        end
        
        % Hou, 2008 saliency
        if DimaFlag && isfield(Dima_data.data,'saliencyHou')
            data.saliencyHou =Dima_data.data.saliencyHou;
        else
            data.saliencyHou = saliencyHouNips(data.image, gbvsParam.HouNips.W);
        end
    
    % faces
    data.faces = findfaces(f);
    
    % humans
    [data.poselet_hit, ~, ~] = detect_objects_in_image(f, poseletModel);
    
    % video data
    data.index = ind;
    data.videoName = vr.name;
    %data.saliencyGBVS = data.saliency;
    
    % Fusion Saliency map
    %data.Fused_Saliency=data.saliencyMotionPCA.*data.saliencyPCA;
    data.Fused_Saliency=PCA_Fused_Saliency(data.ofx,data.ofy,data.image);
    
    if nargout~=0
        frs{ifr} = data;
    end
    % save
    if (exist('cache', 'var'))
        save(cacheFile, 'data');
    end
end

if (nfr == 1) && nargout~=0
    frs = frs{1};
end
