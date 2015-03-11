function result = grabCutMe(I_RGB,salMap)
bg = 0.1;
pbgfg = 0.3;
fg = 0.95;

OUTdir = './OUT/';
imwrite(I_RGB,[OUTdir 'rgbInput.png'],'png');
imwrite(salMap,[OUTdir 'salMask.png'],'png');
grabCut([OUTdir 'rgbInput.png'],[OUTdir 'salMask.png'],[OUTdir 'grab.png'],[OUTdir 'grab2.png'],bg,pbgfg,fg);
result = im2double(imread([OUTdir 'grab.png']));
end
