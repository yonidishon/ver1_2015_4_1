% run ELK on CVPR dataset
clc;
dbdir = 'C:\CVPR_2013_tracking_DB';
main_res_dir = 'C:\CVPR_DB_results';


seqs = dir(dbdir);
seqs(1:2)  = [];
dout = 'ELK_public_results';
resdir = fullfile(main_res_dir,dout);
if ~exist(resdir,'dir');
    mkdir(resdir);
end

prm = loadDefaultParams;
prm.outputDir = resdir;

for ii = 1:length(seqs)     
    resfile = fullfile(resdir,[seqs(ii).name '.txt']);
    if ~exist(resfile,'file')  ||1
        prm.runName = seqs(ii).name;
        prm.inputDir = fullfile(dbdir,seqs(ii).name,'img');
        prm.annFile = fullfile(dbdir,seqs(ii).name,'groundtruth_rect.txt');
        try
            ELK_tracker_main(prm);
        end
    end
end