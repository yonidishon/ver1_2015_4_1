% build accuracy curve: 
%   x: th 
%   y: fraction of frames with J>=th
% N - th sampling resolution i.e. th = linspace(0,1,N)
% verbose - 0- do not plot, 1- plot curve

function [AUC,th,acc] = comp_jaccard_AUC(J,N,verbose,varargin)

Z = numel(J);
th = linspace(0,1,N)';
%th(end) = [];
dx = th(2)-th(1);

acc = zeros(N,1);

for n = 1:N
    acc(n) = sum(J>=th(n))/Z;
end

AUC = mean(acc);%sum(acc)*dx;
    
if verbose
    figure;
    plot(th,acc,'--b','linewidth',2);
    xlabel('Jaccard TH');
    ylabel('Fraction of data >= TH');    
    grid on;
    if nargin==4 && ischar(varargin{1})
        title(sprintf('AUC = %.3f  - %s',AUC,varargin{1}),'Interpreter', 'none');
    else
        title(sprintf('AUC = %.3f',AUC));
    end
        
end