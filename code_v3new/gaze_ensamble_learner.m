% SCRIPT
NCPU=str2double(getenv('NUMBER_OF_PROCESSORS')); % Number of CPUs on which to run
cobj=parcluster('local');
cobj.NumWorkers = NCPU;
poolobj=parpool('local',NCPU);
[responses,data] = load_train_set_sel(CollectDataDst,TREEPARAMS.trainset,...
    TREEPARAMS.samples_per_frame,TREEPARAMS.fractions); % TODOYD
X = cell2mat(data);
Y = cell2mat(responses);
% giving a weight to lower and higher values examples
%W = 1./exp(-((Y-0.5)./sqrt(-0.5^2/2/log(0.1))).^2./2);
%learned_tree = TreeBagger(NTREES,X,Y,'Weights',W,'Method','regression','OOBPred','On'...
%       ,'FBoot',FRACDATA,'Options',statset('UseParallel',true),'OOBVarImp','On');
learned_tree = TreeBagger(TREEPARAMS.numtrees,X,Y,'Method','regression','OOBPred','On'...
       ,'FBoot',FRACDATA,'Options',statset('UseParallel',true),'OOBVarImp','On');       
 delete(poolobj);
 save(fullfile(TreesDst,[GENERALPARAMS.full_tree_ver,getComputerName(),'.mat']),'learned_tree','-v7.3');
 