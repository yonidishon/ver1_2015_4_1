function [responses_mat,data_mat]=load_train_set_feat_pred1(data_folder,train_set,sperim)
if nargin<3
    sperim=-1;
end
folders=dir(data_folder);
STORED_SALIENCY='\\CGM10\D\Video_Saliency_cache_Backup';
addpath(genpath('\\cgm10\Users\ydishon\Documents\Video_Saliency\code_v3\toolbox\PCA_Saliency'));
folders=folders(~ismember({folders.name},{'.','..'})');folders=extractfield(folders,'name')';
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
            fileDATAMAT=load(fullfile(STORED_SALIENCY,[folders{ind},'.avi'],files(jj).name));
            fileDATAMAT=fileDATAMAT.data;
            [~,rSpatial,rMotion] = PCA_Saliency_all(fileDATAMAT.ofx,fileDATAMAT.ofy,fileDATAMAT.image);
            PCAS=rSpatial(:);PCAM=rMotion(:);
            if sperim~=-1
                rperm=randperm(length(filedata.responeses));
                data_mat{jj}=[PCAS(rperm(1:sperim)),PCAM(rperm(1:sperim))];
                responses_mat{jj}=filedata.responeses(rperm(1:sperim));
            else
                data_mat{jj}=[PCAS,PCAM];
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
        fileDATAMAT=load(fullfile(STORED_SALIENCY,[folders{ind},'.avi'],files(jj).name));
        [~,rSpatial,rMotion] = PCA_Saliency_all(fileDATAMAT.ofx,fileDATAMAT.ofy,fileDATAMAT.image);
        PCAS=rSpatial(:);PCAM=rMotion(:);
        if sperim~=-1
            rperm=randperm(length(filedata.responeses));         
            data_mat{jj}=[PCAS(rperm(1:sperim)),PCAM(rperm(1:sperim))];
            responses_mat{jj}=filedata.responeses(rperm(1:sperim));
        else
            data_mat{jj}=[PCAS,PCAM];
            responses_mat{jj}=filedata.responeses;
        end
    end
    fprintf('Finished loading frames from movie %s\n',train_set);
end