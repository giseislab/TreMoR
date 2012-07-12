function tenminspfile = waveformfilename2sgram10minname(waveformMat)
printfunctionstack('>');
fields = regexp(basename(waveformMat), '_', 'split');
datestring = fields{2};
yyyy = datestring(1:4);
mm = datestring(5:6);
dd = datestring(7:8);
hr = datestring(10:11);
mi = datestring(12:13);
ss = datestring(14:15);
enum = datenum(sprintf('%s/%s/%s %s:%s:%s', yyyy, mm, dd, hr, mi, ss));
tenminspfile = getSgram10minName(fields{1}, enum);
printfunctionstack('<');
