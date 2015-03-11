%Run Tests
clear all;
close all;
movieName = 'flock';
% Base_DIR = 'H:/Study/Thesis/Input/';
Ran_Dir = ['D:\Output\OURS\Video\' movieName '\'];
%GroundTruthDir
GTDIR = 'Z:\Documents\Dropbox\Study\Doctorate\Research\Input\JPEGS\GT_matlab\';
GT = load([GTDIR movieName '_GT.mat']);
GT = GT.GT;
fls = dir([Ran_Dir '*.png']);
GT = GT(:,:,1:min(numel(fls),size(GT,3)));
createCompStruct = @(name,dir,prefix,postfix,ext,C,gS,gC) ...
    struct('name', name, 'dir', dir,'prefix',prefix,'postfix',...
    postfix,'ext',ext,'graphColor',C,'graphStyle',gS,'graphFaceColor',gC);
% ALG_DIR(1) = createCompStruct('SVO',SVO_dir,[],'F','png',[247 150 70]/255,'o',[247 150 70]/255);
% ALG_DIR(2) = createCompStruct('RC',RC_DIR,[],'_RC','png',[192 80 77]/255,'d',[192 80 77]/255);
% ALG_DIR(3) = createCompStruct('CNTX',StasDir,[],'_SaliencyMap','jpg',[155 187 89]/255,'v',[155 187 89]/255);
% ALG_DIR(4) = createCompStruct('CBS',CBS_Dir,[],'F','png',[128 100 162]/255,'s',[128 100 162]/255);
ALG_DIR(1) = createCompStruct('Ours',Ran_Dir,[],'_S','png',[75 172 198]/255,'^',[75 172 198]/255);


% [HitRate , FalseAlarm] = ROCpercent(GTDIR,ALG_DIR);
[HitRate , FalseAlarm] = ROCthreshold(GT,ALG_DIR);
MissRate=1-HitRate;
% return
% cTime = clock;
% [h AUC] = ROCplot(HitRate,FalseAlarm,ALG_DIR);
% [h AUC] = ROCplot(MissRate,FalseAlarm,ALG_DIR);

equalRate = 0:0.01:1;
[x0,y0,iout,jout] = intersections(FalseAlarm,MissRate,equalRate,equalRate,false);
load('EER.mat');
eval(['EER.' movieName '=' num2str(x0)]);
save('EER.mat','EER');
EER
% print(h,'-dpng','ROC-MSRA.png');
