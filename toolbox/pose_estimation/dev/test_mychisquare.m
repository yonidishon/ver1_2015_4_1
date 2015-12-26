% mock run
fold = 'D:\head_pose_estimation\2015_11_11_wColor\BBC_life_in_cold_blood_1278x710';
addpath(genpath('\\cgm10\Users\ydishon\Documents\Video_Saliency\toolbox\pose_estimation\analysis'));
files = dir(fullfile(fold,'*.png'));
files = extractfield(files,'name');
figure();
chiconf = zeros(length(files),1);
for ii = 1:length(files)
    im = im2double(imread(fullfile(fold,files{ii})));
    im(im<max(im(:)/2)) = 0;
   chiconf(ii) = mychisquare( im, ones(size(im)));
   %imshow(im,[]);
   %title(sprintf('Frame : %i Chi Square = %.4f',ii,chidist));
   %pause();
end
plot(chiconf);
grid on;