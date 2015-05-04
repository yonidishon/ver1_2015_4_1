% Prediction versus GT values histogram analysis

% Load Prediction Folder:
PredFolder = 'D:\Video_Saliency_Results\FinalResults3\TreeEnsamble_v3_hough_and_clean';
PredFiles = dir([PredFolder,'\*.mat']);
    % Scaning through the files and get only the predictions 
ind = strfind(extractfield(PredFiles,'name'),'_similarity');
ind = cellfun(@(x)isempty(x),ind);
PredFiles = extractfield(PredFiles(ind),'name')';
% Load Ground Truth Folder:
GTFolder = '\\CGM41\Users\gleifman\Documents\DimaCode\DIEM\gaze';
% Calculate number of frames diffs
frms=zeros(length(PredFiles),1);
%figure();
for ii=1:length(PredFiles)
    Predmaps=load(fullfile(PredFolder,PredFiles{ii}));
    frms(ii)=length(Predmaps.frames);
    %Just for debugging
%     title(PredFiles{ii});
%     for jj=1:length(Predmaps.frames)
%         aa=Predmaps.predMaps(:,:,jj);
%         imshow(aa>0.1353);
%         drawnow;
%     end
end

absdiff=cell(sum(frms),3);
inner_ind=0;
for ii=1:length(PredFiles)
    Predmaps=load(fullfile(PredFolder,PredFiles{ii}));
    [m,n,~]= size(Predmaps.predMaps_tree);
    % Choose Nearest-Neigbour fixation point:
    [X,Y]=meshgrid(1:n,1:m);
    s = load(fullfile(GTFolder, sprintf('%s', PredFiles{ii}))); %george
    gazeData = s.data;
    %h=figure();
    for ifr=1:length(Predmaps.frames)
        gzPts=gazeData.points{Predmaps.frames(Predmaps.indFr(ifr))};
        curpredMap=Predmaps.predMaps_tree(:,:,Predmaps.indFr(ifr));
        if ~isempty(gzPts)
            [IDX,D] = knnsearch([gzPts(:,2),gzPts(:,1)],[Y(:),X(:)]);
            % Calculate GT respones:
            D_g=exp((-(D./gazeData.pointSigma).^2)./2);
            %imshow(reshape(D_g,m,n),[]);
            %drawnow
            absdiff{ifr+inner_ind,1}=abs(D_g(:)-curpredMap(:));
            absdiff{ifr+inner_ind,2}=D_g(:);
            absdiff{ifr+inner_ind,3}=curpredMap(:);
        else
            absdiff{ifr+inner_ind,1}=NaN;
            absdiff{ifr+inner_ind,2}=NaN;
            absdiff{ifr+inner_ind,3}=NaN;
        end
        % Calculate Absolute Difference between GT response and Prediction
        % response:
%         absdiff{ifr+inner_ind,1}=abs(D_g(:)-curpredMap(:));
%         absdiff{ifr+inner_ind,2}=D_g(:);
        % Produce Histogram of Values:
    end
    %close(h);
    inner_ind=inner_ind+frms(ii);
end
save(fullfile(PredFolder,'vis\absdiff_trainset.mat'),'absdiff');
%histogram(cell2mat(absdiff));