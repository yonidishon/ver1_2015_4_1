function [h]=displayNNresults(ex_patch,NN_patch,quad,ch)
 % function displayNNresults to display in a tight subplot the results of
 % the NN analysis
 % inputs:
 % 1. ex_patch - cell array of the example patches Nx1
 % 2. NN_patch - cell array of the NN patches NxM
 % 3. quad - the quadratian checked
 % 4. ch - the channel that is checked
 fig_name = sprintf('Results of Quad:%s Channel:%s',quad,ch);
 h=figure('Name',fig_name);
 [m,n] = size(NN_patch);
%  ha_ex = tight_subplot(m,1,[.01 .03],[.1 .01],[.01 .01]);
%  ha_nn = tight_subplot(m,n,[.01 .03],[.1 .01],[.01 .01]);
cell1NN = repmat({{'-g'}},1,n);
C = repmat({{[]},cell1NN},m,1);
[ha,labelfontsize] = subplotplus(C);
 for ii=1:m
     axes(ha(1+(ii-1)*(n+1)));
     imshow(imread(ex_patch{ii}),[]);
     mov_ind = strsplit(ex_patch{ii},'\');
     mov_ind = strsplit(mov_ind{end},'_');
     mv_ind = mov_ind{1};
     fr_ind = mov_ind{2};
     title(sprintf('M:%s,Fr:%s',mv_ind,fr_ind),'FontSize',labelfontsize(1+(ii-1)*(n+1)));
     for jj=1:n
        axes(ha(1+(ii-1)*(n+1)+jj));
        ind = strsplit(NN_patch{ii,jj},'\');
        ind = strsplit(ind{end},'_');
        ind1 = ind{1};
        fr_ind1 = ind{2};
        imshow(imread(NN_patch{ii,jj}),[]);
        title(sprintf('M:%s,Fr:%s',ind1,fr_ind1),'FontSize',labelfontsize(1+(ii-1)*(n+1)+jj));
     end       
 end
 drawnow
end