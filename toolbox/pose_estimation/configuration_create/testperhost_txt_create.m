function [] = testperhost_txt_create(data_fold,hosts,dst_fold,frcnt)
% function to produce the .txt from CRCNS movies to train the
if ~exist(dst_fold,'dir')
    mkdir(dst_fold);
end
testset = extractfield(dir(data_fold),'name');
testset = testset(~ismember(testset,{'.','..'}))';

MOVIESPERHOST = repmat(floor(length(testset)/length(hosts)),length(hosts),1);
carry_over = mod(length(testset),length(hosts));
MOVIESPERHOST(end-(carry_over-1):end,:) = MOVIESPERHOST(end-(carry_over-1):end,:)+1;
counter = 1;
for ii=1:length(hosts)
    fid=fopen(fullfile(dst_fold,[hosts{ii},'_SFUtest','.txt']),'w');
    fprintf(fid,'%d\n',0); % dummy value
    foldernms = testset(counter:counter+(MOVIESPERHOST(ii)-1));
    totnumframes=0;
    for k=1:length(foldernms);
        if frcnt == Inf
            numfiles = numel(dir(fullfile(data_fold,foldernms{k},'*.png')));
        else
            numfiles = frcnt;
        end
        
        for pp=1:numfiles
            fprintf(fid,'%s\n',...
                fullfile(data_fold,foldernms{k},sprintf('%06d.png',pp)));
            totnumframes=totnumframes+1;
        end
    end
    counter = counter+(MOVIESPERHOST(ii)-1)+1;
fclose(fid);
A = regexp( fileread(fullfile(dst_fold,[hosts{ii},'_SFUtest','.txt'])), '\n', 'split');
A{1} = sprintf('%d',totnumframes);
fid = fopen(fullfile(dst_fold,[hosts{ii},'_SFUtest','.txt']), 'w');
fprintf(fid, '%s\n', A{:});
fclose(fid);
end
end