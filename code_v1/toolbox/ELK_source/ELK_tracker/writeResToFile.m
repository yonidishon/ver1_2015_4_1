function writeResToFile(resfile,v)

fid = fopen(resfile,'a');
fprintf(fid,'%.2f\t',v);
fprintf(fid,'\n');
fclose(fid);

% fprintf('New target state: [');
% fprintf('%.2f ',v);
% fprintf(']\n');