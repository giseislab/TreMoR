function diaryname = getSgramDiaryName(subnet, enum)
tenminspfile = getSgram10minName(subnet,enum);
[bname,dname,bnameroot,bnameext] = basename(tenminspfile);
system(sprintf('mkdir -p %s',dname));
diaryname = catpath(dname, [bnameroot, '.txt']);