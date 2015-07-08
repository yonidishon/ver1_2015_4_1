function [responses_mat,data_mat]=load_train_set_sel(data_folder,train_set,sperim,DOWNSAMPLE)
if nargin<3
    sperim=-1;
end
folders=dir(data_folder);
folders=folders(3:end);folders=extractfield(folders,'name')';
totnumfiles=0;
% Getting number of files that are going to be the training set.
if isa(train_set,'cell')
    for ii=1:length(train_set)
        ind=find(ismember(folders,train_set{ii}));
        if isempty(ind)
            fprintf('The movie: %s isn''t in the datafolder!!\n',train_set{ii});
        end
        files=dir(fullfile(data_folder,folders{ind},'\*.mat'));
        totnumfiles=totnumfiles+length(1:DOWNSAMPLE:length(files));
    end
else
    ind=find(ismember(folders,train_set));
    if isempty(ind)
        fprintf('The movie: %s isn''t in the datafolder!!\n',train_set);
    end
    files=dir(fullfile(data_folder,folders{ind},'\*.mat'));
    totnumfiles=length(files);
end

data_mat=cell(totnumfiles,1);
responses_mat=cell(totnumfiles,1);

% Collecting training set file to memory.
if isa(train_set,'cell')
    offset=0;
    for ii=1:length(train_set)
        ind=find(ismember(folders,train_set{ii}));
        files=dir(fullfile(data_folder,folders{ind},'\*.mat'));
        for jj=1:length(1:DOWNSAMPLE:length(files))
            filedata=load(fullfile(data_folder,folders{ind},files(1+(jj-1)*DOWNSAMPLE).name));
            
            if sperim~=-1
                IX_zeros=find(filedata.responeses<0.4);
                IX_others=find(filedata.responeses>=0.7);
                hold_sperim=sperim;
                if length(IX_others)<sperim/2 || length(IX_zeros)<sperim/2
                    sperim=2*min(length(IX_others),length(IX_zeros));
                end
                
                tmp=filedata.responeses;
                tmp(IX_zeros)=0;
                
                data_mat_tmp=[filedata.data(IX_zeros(1:floor(sperim/2)),:);filedata.data(IX_others(1:floor(sperim/2)),:)];
                responses_mat_tmp=[tmp(IX_zeros(1:floor(sperim/2)));tmp(IX_others(1:floor(sperim/2)))];
                % Randomize the data and responeses respectively.
                rperm_rows=randperm(length(responses_mat_tmp));
                data_mat{offset+jj}=data_mat_tmp(rperm_rows,:);
                responses_mat{offset+jj}=responses_mat_tmp(rperm_rows);
            else
                data_mat{offset+jj}=filedata.data;
                responses_mat{offset+jj}=filedata.responeses;
            end
            sperim=hold_sperim;
        end
        offset=offset+length(1:DOWNSAMPLE:length(files));
        fprintf('Finished loading frames from movie %s\n',train_set{ii});
    end
else % not part of training set so just do it for all the file.
    ind=find(ismember(folders,train_set));
    files=dir(fullfile(data_folder,folders{ind},'\*.mat'));
    for jj=1:length(files)
        filedata=load(fullfile(data_folder,folders{ind},files(jj).name));
        if sperim~=-1
             IX_zeros=find(filedata.responeses<0.4);
            IX_others=find(filedata.responeses>=0.7);
            if length(IX_others)<sperim/2 || length(IX_zeros)<sperim/2
                hold_sperim=sperim;
                sperim=2*min(length(IX_others),length(IX_zeros));
            end
            tmp=filedata.responeses;
            tmp(IX_zeros)=0;
            
            data_mat_tmp=[filedata.data(IX_zeros(1:floor(sperim/2)),:);filedata.data(IX_others(1:floor(sperim/2)),:)];
            responses_mat_tmp=[tmp(IX_zeros(1:floor(sperim/2)));tmp(IX_others(1:floor(sperim/2)))];
            rperm_rows=randperm(length(responses_mat_tmp));
            data_mat{jj}=data_mat_tmp(rperm_rows,:);
            responses_mat{jj}=responses_mat_tmp(rperm_rows);
        else
            data_mat{jj}=filedata.data;
            responses_mat{jj}=filedata.responeses;
        end
        sperim=hold_sperim;
    end
    fprintf('Finished loading frames from movie %s\n',train_set);
end