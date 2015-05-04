function [reconError] =  projNrec(pVec,IX,imSize)
global totTime;


poiVec = pVec(IX,:);
Lm = repmat(mean(poiVec,1),[size(poiVec,1) 1]);

salTic = tic;
[COEFF,junk] = princomp(poiVec-Lm);
% reconError = sum(abs((pVec*COEFF)),2);
% Mahal distance
reconError = mahal(pVec*COEFF,pVec*COEFF);
reconError = reshape(reconError,imSize);
salToc = toc(salTic);

totTime = totTime + salToc;


% t = repmat(mean(poiVec,1),[size(pVec,1) 1]);
% reconError2 = sum(((pVec-t).^2),2);
% reconError = sum(abs((pVec*C)*(C')-pVec),2);
% for cf=2:5
% C = COEFF(:,cf);
% reconError = reconError+sum(abs((pVec*C)*(C')-pVec),2);
% end

% tt=toc;
% pcaTime =  pcaTime +tt;
% fprintf('\nPCA -- > %d\n',tt);


% reconError2 = reshape(reconError2,imSize);
% figure;imagesc(reconError);axis image;
% figure;imagesc(reconError2);axis image;

end