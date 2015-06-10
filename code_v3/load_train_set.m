function [responses_mat,data_mat]=load_train_set(data_folder,train_set,sperim)
if nargin<3
    sperim=-1;
end
folders=dir(data_folder);
folders=folders(3:end);folders=extractfield(folders,'name')';
totnumfiles=0;
if isa(train_set,'cell')
    for ii=1:length(train_set)
        ind=find(ismember(folders,train_set{ii}));
        if isempty(ind)
            fprintf('The movie: %s isn''t in the datafolder!!\n',train_set{ii});
        end
        files=dir(fullfile(data_folder,folders{ind},'\*.mat'));
        totnumfiles=totnumfiles+length(files);
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
if isa(train_set,'cell')
    for ii=1:length(train_set)
        ind=find(ismember(folders,train_set{ii}));
        files=dir(fullfile(data_folder,folders{ind},'\*.mat'));
        for jj=1:length(files)
            filedata=load(fullfile(data_folder,folders{ind},files(jj).name));
            
            if sperim~=-1
                IX_zeros=find(filedata.responeses<0.4);
                IX_others=find(filedata.responeses>=0.7);
                if length(IX_others)<sperim/2 || length(IX_zeros)<sperim/2
                    sperim=2*min(length(IX_others),length(IX_zeros));
                end
                rperm_zeros=randperm(length(IX_zeros));
                rperm_others=randperm(length(IX_others));
                tmp=filedata.responeses;
                tmp(IX_zeros)=0;
                data_mat{jj}=[filedata.data(IX_zeros(rperm_zeros(1:sperim/2)),:);filedata.data(IX_others(rperm_others(1:sperim/2)),:)];
                responses_mat{jj}=[tmp(IX_zeros(rperm_zeros(1:sperim/2)));tmp(IX_others(rperm_others(1:sperim/2)))];
            else
                data_mat{jj}=filedata.data;
                responses_mat{jj}=filedata.responeses;
            end
        end
        fprintf('Finished loading frames from movie %s\n',train_set{ii});
    end
else
    ind=find(ismember(folders,train_set));
    files=dir(fullfile(data_folder,folders{ind},'\*.mat'));
    for jj=1:length(files)
        filedata=load(fullfile(data_folder,folders{ind},files(jj).name));
        if sperim~=-1
            IX_zeros=find(filedata.responeses<0.4);
            IX_others=find(filedata.responeses>=0.7);
            if length(IX_others)<sperim/2 || length(IX_zeros)<sperim/2
                sperim=2*min(length(IX_others),length(IX_zeros));
            end
            rperm_zeros=randperm(length(IX_zeros));
            rperm_others=randperm(length(IX_others));
            tmp=filedata.responeses;
            tmp(IX_zeros)=0;
            data_mat{jj}=[filedata.data(IX_zeros(rperm_zeros(1:sperim/2)),:);filedata.data(IX_others(rperm_others(1:sperim/2)),:)];
            responses_mat{jj}=[tmp(IX_zeros(rperm_zeros(1:sperim/2)));tmp(IX_others(rperm_others(1:sperim/2)))];
        else
            data_mat{jj}=filedata.data;
            responses_mat{jj}=filedata.responeses;
        end
    end
    fprintf('Finished loading frames from movie %s\n',train_set);
end