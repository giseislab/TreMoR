function diaryname = getSgramDiaryName(subnet, enum)
debug.printfunctionstack('>');
tenminspfile = getSgram10minName(subnet,enum);
% 20121101: Replacing basename with fileparts/strrep
%[bname,dname,bnameroot,bnameext] = basename(tenminspfile);
[dname, bname, ext] = fileparts(tenminspfile);
system(sprintf('mkdir -p %s',dname));
%diaryname = catpath(dname, [bnameroot, '.txt']);
diaryname = strrep(tenminspfile, ext, '.txt');
debug.printfunctionstack('<');
