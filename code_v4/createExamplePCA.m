clear all;
close all;


p(:,:,1) = [0 1 0; 0 1 0; 0 1 0];
p(:,:,2) = [0 1 0; 0 1 0; 0 1 0];
p(:,:,3) = [0 0 0; 1 1 1; 0 0 0];
p(:,:,6) = [0 0 0; 1 1 1; 0 0 0];
p(:,:,9) = [0 1 0; 1 1 1; 0 1 0];
p(:,:,4) = [0 1 0; 0 1 1; 0 1 0];
p(:,:,5) = [0 1 0; 0 1 1; 0 1 0];
p(:,:,8) = [1 0 0; 0 1 0; 0 0 1];
p(:,:,7) = [ 1 0 0; 0 1 0; 0 0 1 ];
% p=double(~p);
% % 
% for i=1:9
%     I = kron(p(:,:,i),ones(100));
%     imwrite(I,['../../Publications/Saliency/images/Struct/patch' num2str(i) '.png'],'png');
% end
%     

% p= p - repmat(m,[1 1 9]);
%%
pA = mean(p,3);
pVec = reshape(p-repmat(pA,[1 1 9]),[9 9])';
pVecOld = reshape(p,[9 9])';
m = repmat(mean(pVecOld,2),[1 size(pVecOld,2)]);
pVecNoMean = pVecOld - m;
pA2 = repmat(mean(pVecNoMean,1),[size(pVecNoMean,1) 1]);
% dOld = sum(squareform(abs(pdist(pVecOld-m,'cityblock'))));
dOld = sum(squareform(abs(pdist(pVecOld-m,'euclidean'))));
[COEFF] = princomp(pVecNoMean-pA2);
SCORE = pVecNoMean*COEFF;
r = reshape(SCORE',[3 3 9]);
reconError = sum(abs((SCORE)),2);
figure(1)
for i=1:9
subplot(3,3,i);imagesc(p(:,:,i));colormap(gray);
m = mean2(p(:,:,i));
d = abs(p(:,:,i)-pA-m);
value = sum(d(:));
value2 = sqrt(sum(d(:).^2));
value3 = reconError(i);
value4 = dOld(i);
xlabel([num2str(value) ' / ' num2str(value2) ' / ' num2str(value3)  ' / ' num2str(value4) ]);
end
% figure(2);imagesc(pA,[M 1]); axis image;colormap(gray);


% figure(99);
% m = zeros(3);
% for i=1:9
%     c = reshape(COEFF(:,i),[3 3])';
%     m=m+c;
% subplot(3,3,i);imagesc(c,[M 1]);colormap(gray);
% end
% m = m/9;
% figure(100);imagesc(m,[M 1]); axis image;colormap(gray);