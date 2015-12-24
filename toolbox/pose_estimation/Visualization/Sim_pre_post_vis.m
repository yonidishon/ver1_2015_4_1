function [chi_graph,auc_graph] = Sim_pre_post_vis(pre_sim,post_sim,frnum,shift,height)
% This function gets two similarity files and show them as respect to the
% frame 
% [vidFrame]=function(sim1,sim2,);
% sim1/sim2 are vectors of [#frames x 1] 
% height - normalized screen height for graphes
% sim1_chi = squeeze(sim(1,1,:));
% sim1_auc = squeeze(sim(1,2,:));
% sim2_chi = squeeze(sim(2,1,:));
% sim2_auc = squeeze(sim(2,2,:));
% sim3_chi = squeeze(sim(3,1,:));
% sim3_auc = squeeze(sim(3,2,:));

% f=figure();%debug
% f.Position = [0,height,1080,height];%debug
frtot = size(pre_sim,2);
%AUC comparision (ii == 2)Chi-Square comparision (ii == 1)
for ii=1:size(pre_sim,1)
    f=figure('Visible','off');
    f.Position = [0,height,1080,height];
    xmarker = frnum;
    ymarker1 = pre_sim(ii,frnum);
    ymarker2 = post_sim(ii,frnum);
    ha = tight_subplot(2,1,.04,.1,[.03,.05]);
    %set(ha(1),'Visible','off');set(ha(2),'Visible','off');
    %ha(1).Visible='off';ha(2).Visible='off';
    plot(ha(1),1:frtot,pre_sim(ii,:),'r',1:frtot,repmat(ymarker1,1,frtot),'--r');
    str = '\bullet';
    text(xmarker,ymarker1,str,'Parent',ha(1));
    str = ['\leftarrow ','\bf',sprintf('%.2f',ymarker1)];
    text(frtot,ymarker1,str,'Parent',ha(1));
    set(ha(1),'XTick',0:120:frtot);
    set(ha(1),'XTickLabel',repmat('',1,length(0:120:frtot)));
    grid(ha(1),'on');
    xlim(ha(1),[1,frtot]);
    ylim(ha(1),[0 1]);
    legend(ha(1),'Pre');
    if ii == 2
        title(ha(1),[['Frame# ',num2str(xmarker+shift),', AUC : ',num2str(ymarker1)...
            ,' (Houghforest \color{red}--------','\color{black})'],[' ',num2str(ymarker2)...
            ,' (Post \color{blue}--------','\color{black})']]);
    else % (ii == 2)
        title(ha(1),[['Frame# ',num2str(xmarker+shift),', \chi^2 : ',num2str(ymarker1)...
            ,' (Houghforest \color{red}--------','\color{black})'],[' ',num2str(ymarker2)...
            ,' (Post \color{blue}--------','\color{black})']]);
    end
    plot(ha(2),1:frtot,post_sim(ii,:),'b',1:frtot,repmat(ymarker2,1,frtot),'--b');
    str = '\bullet';
    text(xmarker,ymarker2,str,'Parent',ha(2));
    str = ['\leftarrow ','\bf',sprintf('%.2f',ymarker2)];
    text(frtot,ymarker2,str,'Parent',ha(2));
    set(ha(2),'XTick',0:120:frtot);
    grid(ha(2),'on');
    xlim(ha(2),[1,frtot]);
    ylim(ha(2),[0 1]);
    legend(ha(2),'Post');
    if ii == 2
        auc_graph = getframe(f);
        auc_graph = auc_graph.cdata;
    else % (ii == 2) 
        chi_graph = getframe(f);
        chi_graph = chi_graph.cdata;
    end
    % debug
    %f1=figure('Name','Image');
    %imshow(F.cdata);
    %drawnow;
    delete(ha);
    delete(f);
end
end
