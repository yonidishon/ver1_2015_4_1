%clear all;close all;clc;
% CheckAndUpdateSource  - Check on each active host if the code is updated and if not
% Copy code to it.
% then run the distributed_main on each of them.
% hosts = {'CGM-AYELLET-1',...
%          'CGM16',...
%          'CGM22',...
%          'CGM41',...
%          'CGM45',...
%          'CGM46',...
%          'CGM47'};
hosts = {'CGM-AYELLET-1',...
         'CGM7',...
         'CGM16',...
         'CGM22',...
         'CGM38',...
         'CGM41',...
         'CGM45',...
         'CGM46',...
         'CGM47'};
%'CGM44'% - Uri uses it,...
Source_server_folder='C:\Users\ydishon\Documents\Video_Saliency\code_v3';
%Source_server_folder='C:\Users\ydishon\Documents\Video_Saliency\code_v1';
Source_perent_folder='C:\Users\ydishon\Documents\MATLAB\Video_Saliency';
dima_server='C:\Users\ydishon\Documents\Video_Saliency\Dimarudoy_saliency\';
Source_dist_folder='\Users\ydishon\Documents\MATLAB\Video_Saliency\code_v3';
Source_dist_perent_fold='\Users\ydishon\Documents\MATLAB\Video_Saliency';
%Source_dist_folder='\Users\ydishon\Documents\MATLAB\Video_Saliency\code_v1';
dima_dist_host='\Users\ydishon\Documents\MATLAB\Video_Saliency\Dimarudoy_saliency';
serv_code=dir(Source_server_folder);serv_code(1:2)=[];% remove the '.','..', and '.git' folder
serv_code_names={serv_code.name};% 1xn str representation
serv_dima=dir(dima_server);
active_hosts=hosts;

%parpool
for ii=1:length(active_hosts);
    dist_host_code=['\\',active_hosts{ii},Source_dist_folder];
    dist_host_proj=['\\',active_hosts{ii},Source_dist_perent_fold];
    dist_host_dima=['\\',active_hosts{ii},dima_dist_host];
    dir_list_code=dir(dist_host_code);
    dima_list_dist=dir(dist_host_dima);
    % if the server is more updated than the local source
    % (reffering to  serv(1)  cause it's the current folder data
    if isempty(dima_list_dist)
%         if ~exist(dist_host_dima,'dir')
%             mkdir(dist_host_dima)
%         end
        copyfile([dima_server,'\*'],dist_host_dima,'f');
        fprintf('Copy of Dimtry_saliency has been done to host %s\n',active_hosts{ii});
        dima_list_dist=dir(dist_host_dima);
    end
    if isempty(dir_list_code)
        fprintf('Copy of code has been done to host %s\n',active_hosts{ii});
        %copyfile([Source_server_folder,'\*'],dist_host_code);
        dirforremove=dir([dist_host_proj,'\code*']);
        if ~isempty(dirforremove)
            for k=1:length(dirforremove)
                rmdir([dist_host_proj,'\',dirforremove(k).name],'s');
            end
        end
        mkdir(dist_host_code);
        cellfun(@(x,y)copyfile(x,y),strcat(repmat({[Source_server_folder,'\']},1,length(serv_code_names)),serv_code_names)',...
            strcat(repmat({dist_host_code},1,length(serv_code_names)),'\',serv_code_names)');
        continue
    end
    formatIn='dd-mmm-yyyy HH:MM:SS';
    format long
    serv_code_times=[serv_code.datenum]';serv_code_times(2)=[];
    dist_code_times=[dir_list_code.datenum]';dist_code_times(2)=[];
    if max(serv_code_times)>max(dist_code_times)      
        fprintf('Remove then Copy code has been initiated to host %s\n',active_hosts{ii});
        dirforremove=dir([dist_host_proj,'\code*']);
        if ~isempty(dirforremove)
            for k=1:length(dirforremove)
                rmdir([dist_host_proj,'\',dirforremove(k).name],'s');
            end
        end
        mkdir(dist_host_code);
        %copyfile(Source_server_folder,dist_host_code);
        cellfun(@(x,y)copyfile(x,y),strcat(repmat({[Source_server_folder,'\']},1,length(serv_code_names)),serv_code_names)',...
            strcat(repmat({dist_host_code},1,length(serv_code_names)),'\',serv_code_names)');
    end
    serv_dima_times=[serv_dima.datenum]';serv_dima_times(2)=[];
    dist_dima_times=[dima_list_dist.datenum]';dist_dima_times(2)=[];
%     if max(serv_dima_times)>max(dist_dima_times)
%         fprintf('Remove then Copy Dimtry_Saliency been initiated to host %s\n',active_hosts{ii});
%         %rmdir([dist_host_dima,'\*']);
%         %delete([dist_host_dima,'\*']);
%         copyfile([dima_server,'\*'],dist_host_dima);
%     end
end
fprintf('Finished copying on all active hosts\n');
%run('distributed_main');