function []=helloworld(q1)
time_sig = datestr(clock,'dd/mm/yyyy, HH:MM');
fprintf('Recieved String :: %s Time:: %s Hello World!\n',q1,time_sig);
%fprintf('Wow! Calculation! %s\n',num2str(q1*q2));
