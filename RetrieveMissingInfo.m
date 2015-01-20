% This script is intend to be implemented on ea. host with relevant movies
% That will take from the Dmitry cache on Computer CGM41 all the Saliency
% maps of the other algorithms (Hou,PQFT,GVBS,Dmitry)
localResultFolder='C:\Users\ydishon\Documents\MATLAB\Video_Saliency\Results_v0\cache\';
if ~strcmp('cgm41',getComputerName())
    DIMAResultFolder='\\CGM41\Users\gleifman\Documents\DimaCode\DIEM\cache\';
else
    DIMAResultFolder='C:\Users\gleifman\Documents\DimaCode\DIEM\cache\';
end
%VideosLocal=dir([localResultFolder,'*.avi']);
lockFileFolder='\\CGM10\Users\ydishon\Documents\Video_Saliency\lockfiles\2015_01_04\';
lockfiles=dir([lockFileFolder,'*lockfile*']);
VideosLocal=[];
for k=1:length(lockfiles)
    runData=load([lockFileFolder,lockfiles(k).name]);
    if strcmp(runData.compname,getComputerName())
        str1=strsplit(lockfiles(k).name,'_lockfile');
        str1=strcat(str1(1),'.avi');
        VideosLocal=[VideosLocal;str1];
    end
end
%%
for ii=1:length(VideosLocal)
    fprintf('Started working on %s....    \n',VideosLocal{ii});
    localframesfname=dir([localResultFolder,VideoLocal{ii},'\frame*']);
    % ONLY FROM FRAME#30 UNTIL LENGTH-30 (LIKE DIMA DID)
    for jj=30:(length(localframesfname)-30);
        localFramePath=[localResultFolder,VideosLocal{ii},'\',localframesfname(jj).name];
        frame_data=load(localFramePath,'data');
        data=frame_data.data; clear frame_data;
        dimaFrameData=load([DIMAResultFolder,VideoLocal{ii},'\',localframesfname(jj).name]);
        if ~isfield(data,'saliencyPqft');
            data.saliencyPqft=dimaFrameData.data.saliencyPqft;
        end
        if ~isfield(data,'saliencyHou');
            data.saliencyHou=dimaFrameData.data.saliencyHou;
        end
        if ~isfield(data,'saliencyGBVS');
            data.saliencyGBVS=dimaFrameData.data.saliencyGBVS;
        end
        if ~isfield(data,'saliencyDIMA');
            data.saliencyDIMA=dimaFrameData.data.saliency;
        end
        save(localFramePath,'data');
    end
    fprintf('Finished movie %s\n this is %i\%i movie\n',VideosLocal{ii},ii,length(VideosLocal))
end
fprintf('Finished script ready for test\n');