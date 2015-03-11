function [reconError out COEFF Lm] =  projNrectmp(pVec,IX,imSize)
global pcaTime
poiVec = pVec(IX,:);
Lm = repmat(mean(poiVec,1),[size(poiVec,1) 1]);
tic
[COEFF] = princomp(poiVec-Lm);
% COEFF = COEFF(:,1:10);
out = pVec*COEFF;
reconError = sum(abs((out)),2);
% t = repmat(mean(poiVec,1),[size(pVec,1) 1]);
% reconError2 = sum(((pVec-t).^2),2);
% reconError = sum(abs((pVec*C)*(C')-pVec),2);
% for cf=2:5
% C = COEFF(:,cf);
% reconError = reconError+sum(abs((pVec*C)*(C')-pVec),2);
% end
reconError = reshape(reconError,imSize);
tt=toc;
pcaTime =  pcaTime +tt;
fprintf('\nPCA -- > %d\n',tt);


% reconError2 = reshape(reconError2,imSize);
% figure;imagesc(reconError);axis image;
% figure;imagesc(reconError2);axis image;

end