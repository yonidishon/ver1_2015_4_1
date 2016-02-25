
% Author: Yonatan Dishon
% Date: 05/01/2016
% Purpose : read tree file (HoughForest) and Get nodes
% 1st line of file shows you the : 
% depth of tree , # number of leafs ,dummy number
% next 2^(depth of tree+1) = 65536 gives you tree nodes
% empty line
%  # number of leafs lines in the form:
% leafindex pfg #offsets array[#offsets*2] -> array of offsets
% exp_title = 'Analysis on tree trained over 1 image';
clear all;close all; clc
% open the file
fid = fopen('D:\head_pose_estimation\trees\trees_25_02_2016_Pcas_and_GT_conf_0_8_16\000.txt');
%fid = fopen('D:\head_pose_estimation\trees\trees_2015_11_11_wColor\000.txt');
tline = fgetl(fid);
header=str2num(tline);

treedepth=header(1);
nodenum=2^(treedepth+1)-1;
% going through all the nodes of the tree without doing anything
nodecell = cell(nodenum,1);
%%
for ii=1:nodenum 
    tline = fgetl(fid);
    nodecell{ii} = str2num(tline);
end
% get the channel that was used 
chan = zeros(nodenum,2);
for ii=1:nodenum
    chan(ii,:)=[nodecell{ii}(3),nodecell{ii}(8)];
end

%% histogram of chan sizes
figure();
histogram(chan(chan(:,1)==-1,2),32)
xlabel('Chan in node');
ylabel('# of nodes');
title('Histogram of feature frequencies');
%% histogram of leaf sizes
figure();
histogram(pfgvssz(:,2),[1:1:100])
xlabel('Size of leaf');
ylabel('# of leafs');
title('Histogram of leaf sizes');

%% histogram of leaf confidence
figure();
histogram(pfgvssz(:,1),[0:0.01:1])
xlabel('Confidence of leaf');
ylabel('# of leafs');
title('Histogram of leaf confidence');

%% calculating the std and the radius of the mean value of each leaf offsets
valz = zeros(leafnum,3);
for ii=1:leafnum
   offsets=reshape(leafcell{ii}(4:end),2,size(leafcell{ii}(4:end),2)/2)';
   if (numel(offsets)/2 < 2) continue;end 
   stdoff=std(offsets);
   Roff=sqrt(sum(mean(offsets).^2));
   valz(ii,:) = [stdoff, Roff ]; 
end
 %% Cumulative histogram of distances from patch 
 figure();
 histogram(valz(:,3),'Normalization','cumcount');
 xlabel('mean distance from patch of votes');
 ylabel('Number of leafs');
 title(sprintf('%s\nCumulative Hist of the mean distance of offsets from patch',exp_title))

% C = repmat([1,2,3],numel(valz(:,1)),1);
s = 15;
% c = C(:);
slices=[0 9 15 Inf]; 
for j=1:numel(slices)-1
    figure();
    indices = valz(:,3)>=slices(j) & valz(:,3)<slices(j+1);
    h=scatter(valz(indices,1),valz(indices,2),s);
    h.MarkerFaceColor = 'y';
    h.MarkerEdgeColor =[0 0 0];
    xlabel('leaf std on x axis');
    ylabel('leaf std on y axis');
    zlabel('mean distance from patch');
    title(sprintf('%s\nmean distance between (%i,%i)',exp_title,slices(j),slices(j+1)));
    grid on;
end

bins = cell(2,1); bins{1} = [0:0.1:1];bins{2}=[1:40];
hist3([pfgvssz(:,1),valz(:,3)],bins);