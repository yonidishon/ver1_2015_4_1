function [h AUC] = ROCplot(HitRate,FalseAlarm,ALG_DIR)
% HitRate = [zeros([1 size(HitRate,2)]); HitRate];
% FalseAlarm = [zeros([1 size(FalseAlarm,2)]); FalseAlarm];
% plot results
NumOfAlgos = length(ALG_DIR);
MarkSize = 8;
LineWidth = 2;
h = figure;
AUC(1) = trapz(FalseAlarm(:,1),HitRate(:,1));
plot(FalseAlarm(:,1),HitRate(:,1),'Color',ALG_DIR(1).graphColor,...
    'Marker',ALG_DIR(1).graphStyle,'LineWidth',LineWidth, ...
    'MarkerEdgeColor','k',...
    'MarkerFaceColor',ALG_DIR(1).graphFaceColor,...
    'MarkerSize',MarkSize);
legLabel{1} = [ALG_DIR(1).name ' - ' num2str(AUC(1), 3)];
hold on;
for algIdx=2:NumOfAlgos
    AUC(algIdx) = trapz(FalseAlarm(:,algIdx),HitRate(:,algIdx));
    plot(FalseAlarm(:,algIdx),HitRate(:,algIdx),'Color',ALG_DIR(algIdx).graphColor,...
        'Marker',ALG_DIR(algIdx).graphStyle,'LineWidth',LineWidth, ...
    'MarkerEdgeColor','k',...
    'MarkerFaceColor',ALG_DIR(algIdx).graphFaceColor,...
    'MarkerSize',MarkSize);
legLabel{algIdx} = [ALG_DIR(algIdx).name ' - ' num2str(AUC(algIdx), 3)];
end

hold off;
legend(legLabel,'Location','SouthEast');
set(gca,'fontsize',12,'fontweight','bold');

xlabel('False positive rate','fontsize',18,'fontweight','bold');
ylabel('True positive rate','fontsize',18,'fontweight','bold');

% % print(h,'-djpeg','ROCJ-Area.jpg');
% % print(h,'-djpeg','ROCJ.jpg');
end