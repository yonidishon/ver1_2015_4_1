function [ensamble]=gaze_ensamble_learner(data_folder,train_set)
% Function to build an ensamble of weak learner to learn the fusion of the
% verious PCA methods in order to fit a responses to the spatial color,
% position and movement extracted from 
[responses,data]=load_train_set(data_folder,train_set);
leaf = [5 10 20 50 100];
col = 'rbcmy';
figure
for i=1:length(leaf)
   b = TreeBagger(50,cell2mat(data),cell2mat(responses),'Method','R','OOBPred','On'...
       ,leaf(i));
    plot(oobError(b),col(i));
    hold on;
end
xlabel 'Number of Grown Trees';
ylabel 'Mean Squared Error' ;
legend({'5' '10' '20' '50' '100'},'Location','NorthEast');
hold off;