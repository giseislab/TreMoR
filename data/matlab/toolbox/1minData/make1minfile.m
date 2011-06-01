function make1minfile(outfile, days);
% make1minfile(outfile, days);
disp('> make1minfile');
datapointsperday = 1440;
l=length(outfile);

samplesperyear=days*datapointsperday;
a=zeros(samplesperyear,1);

fid=fopen(outfile,'w');
fwrite(fid,a,'float32');
fclose(fid);
disp('< make1minfile');
