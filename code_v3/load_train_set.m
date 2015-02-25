function [responses_mat,data_mat]=load_train_set(data_folder,train_set,sperim)
folders=dir(data_folder);
folders=folders(3:end);folders=extractfield(folders,'name')';
totnumfiles=0;
for ii=1:length(train_set)
    ind=find(ismember(folders,train_set{ii}));
    if ind==0
        fprintf('The movie: %s isn''t in the datafolder!!\n',train_set{ii});
    end
    files=dir(fullfile(data_folder,folders{ind},'\*.mat'));
    totnumfiles=totnumfiles+length(files);
end
data_mat=cell(totnumfiles,1);
responses_mat=cell(totnumfiles,1);
for ii=1:length(train_set)
    ind=find(ismember(folders,train_set{ii}));
    files=dir(fullfile(data_folder,folders{ind},'\*.mat'));
    for jj=1:length(files)
        filedata=load(fullfile(data_folder,folders{ind},files(jj).name));
        rperm=randperm(length(filedata.responeses));
        data_mat{jj}=filedata.data(rperm(1:sperim),:);
        responses_mat{jj}=filedata.responeses(rperm(1:sperim));
    end
    fprintf('Finished loading frames from movie %s\n',train_set{ii});
end