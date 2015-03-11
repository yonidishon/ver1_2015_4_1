function reconError =  projNrecFALSE(pVec,IX,imSize)
pA = repmat(mean(pVec,1),[size(pVec,1) 1]);

reconError = sum(abs((pVec-pA)),2);
% t = repmat(mean(poiVec,1),[size(pVec,1) 1]);
% reconError2 = sum(((pVec-t).^2),2);
% reconError = sum(abs((pVec*C)*(C')-pVec),2);
% for cf=2:5
% C = COEFF(:,cf);
% reconError = reconError+sum(abs((pVec*C)*(C')-pVec),2);
% end
reconError = reshape(reconError,imSize);
% reconError2 = reshape(reconError2,imSize);
% figure;imagesc(reconError);axis image;
% figure;imagesc(reconError2);axis image;

end