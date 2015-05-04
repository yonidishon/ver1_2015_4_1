function [ensamble]=gaze_ensamble_learner(data_folder,train_set)
% Function to build an ensamble of weak learner to learn the fusion of the
% verious PCA methods in order to fit a responses to the spatial color,
% position and movement extracted from 

train_set={'BBC_life_in_cold_blood_1278x710'
           'advert_iphone_1272x720'
           'one_show_1280x712'};
%data_folder='\\CGM10\D\Video_Saliency_features_for_learner_nn_v1\';
data_folder='\\CGM10\D\Video_Saliency_features_for_learner_nn_v2\';

NCPU=str2double(getenv('NUMBER_OF_PROCESSORS')); % Number of CPUs on which to run
cobj=parcluster('local');
cobj.NumWorkers = NCPU;
poolobj=parpool('local',NCPU);
NTREES=10;% Number of trees to grow.
FRACDATA=1/5; % Fraction of data sampled for each tree.
NUM_SAMPLES_PER_FRAME=1000;
[responses,data]=load_train_set(data_folder,train_set,NUM_SAMPLES_PER_FRAME);
 learned_tree = TreeBagger(NTREES,cell2mat(data),cell2mat(responses),'Method','regression','OOBPred','On'...
       ,'FBoot',FRACDATA,'Options',statset('UseParallel',true),'OOBVarImp','On');
 delete(poolobj);
 %save(fullfile('\\CGM10\D\Learned_Trees',['tree_nnv1_1_',getComputerName(),'.mat']),'learned_tree','-v7.3');
 save(fullfile('\\CGM10\D\Learned_Trees',['tree_nn_v2_',getComputerName(),'.mat']),'learned_tree','-v7.3');
%  leaf = [5 10 20 50 100];
% col = 'rbcmy';
% figure
% for i=1:length(leaf)
%    b = TreeBagger(50,cell2mat(data),cell2mat(responses),'Method','R','OOBPred','On'...
%        ,'MinLeaf',leaf(i));
%     plot(oobError(b),col(i));
%     hold on;
% end
% xlabel 'Number of Grown Trees';
% ylabel 'Mean Squared Error' ;
% legend({'5' '10' '20' '50' '100'},'Location','NorthEast');
% hold off;