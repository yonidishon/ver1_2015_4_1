function [loc_of_gau]=gaussian_hough(predmap,sigma,vote_prec)
% Function for finding the gaussian sources out of the prediction maps of
% the NN trees.
%% For debug 
% im=zeros(500,500);
% [m,n]=size(im);
% im(260,260)=1;
% im(120,240)=1;
% im(280,260)=1;
% im(200,300)=1;
% figure();imshow(im);%pause()
% [X,Y]=meshgrid([44:-1:0,1:44],[44:-1:0,1:44]);
% sigma=10;
% % [ptsy,ptsx]=find(im);
% % for ii=1:length(ptsy)
% %     im_g=(1/sigma/sqrt(2*pi)).*exp((-((X-ptsx(ii)).^2+(Y-ptsy(ii)).^2)./sigma^2./2));
% %     im_g=im_g./max(im_g(:));
% % end
% im_g=imfilter(im,1/sigma/sqrt(2*pi).*exp((-((X).^2+(Y).^2)./sigma^2./2)));
% %  y = awgn(im_g,100);
% %  y1=zeros(500,500);
% %  y1(100:end-99,100:end-99)=y(100:end-99,100:end-99);
% %  im_g=y1;
% figure();imshow(im_g,[]);%pause();
%%
if nargin<3
    vote_prec=0.1;
end
%tic;
ind = find(predmap);
maxR=zeros(size(predmap));
%maxR(ind)=round(sqrt(2*sigma^2*abs(log(1/sigma/sqrt(2*pi)./predmap(ind)))));
% In the correct learner we learned the Gausssian normilized to 1
maxR(ind)=round(sqrt(2*sigma^2*abs(log(1./predmap(ind)))));
maxR(maxR>5*sigma)=0;
ind=find(maxR);
maxR2=2*maxR;
maxmaxR=max(maxR(:));
hough = zeros(size(predmap,1), size(predmap,2));
% figure();
for ii = 1:length(ind)
    if maxR(ind(ii))==0 % this is when the point is the center of gaussian
        Index=ind(ii);
    else
        [X,Y] = meshgrid(0:maxR2(ind(ii)), 0:maxR2(ind(ii)));
        Rmap = round(sqrt((X-maxR(ind(ii))).^2 + (Y-maxR(ind(ii))).^2));
        Rmap(Rmap~=maxR(ind(ii))) = 0;
        [Cy,Cx]= find(Rmap);
        [Ey,Ex]=ind2sub(size(hough),ind(ii));
        circ_subs=[Cy-1+Ey-maxR(ind(ii)),Cx-1+Ex-maxR(ind(ii))];
        auth_subs=find(circ_subs(:,1)>0 & circ_subs(:,1)<size(hough,1) & ...
            circ_subs(:,2)>0 & circ_subs(:,2)<size(hough,2));
        Index = sub2ind(size(hough),circ_subs(auth_subs,1),circ_subs(auth_subs,2));
    end
    % vote for all bins in hough space with radius distance from our current point
    hough(Index) = hough(Index)+1;
% DEBUG    
%     if mod(ii,1000)==0
%         imshow(hough,[]);drawnow; pause(0.5);
%     end
end
% 10% of the pixels in the area say's that's were the center is
% DIDN'T WORK
%thrsh=(pi*maxmaxR^2)*vote_prec;
thrsh=sort(hough,'descend');
% taking only the values in the top 10% precentage
thrsh=min(thrsh(1:round(length(thrsh)/10)));
%toc;
%hough1=hough;
hough(hough<thrsh) = 0;

% NMS
[houghm,houghn]=find(hough);
bbhough=[houghm-sigma,houghn-sigma,...
         houghm-sigma+repmat(2*sigma,length(houghm),1),...
         houghn-sigma+repmat(2*sigma,length(houghm),1)];
[nmsbbox,~]=prunebboxes(bbhough,ones(length(bbhough),1),0.5);

% DEBUG
% figure, imshow(imadjust(mat2gray(hough)));
% xlabel('a'), ylabel('b');
% axis on, axis normal, hold on;
% colormap(hot);
% title(['This the CHT after dealt with the Threshold, R=' num2str(radius)]);
loc_of_gau=[round(nmsbbox(:,1))+sigma,round(nmsbbox(:,2))+sigma];
end