function generateTremorRunStructure(subnet, snum, enum, timestep_in_minutes);
l=0;
outfile = "tremor_run.mat";
if exist(outfile, 'file')
	eval(['load ',outfile]);
	l=length(trs);
end
c=0;
trs(l+1).subnet = % need to load this from runtime MAT file...
for dnum = snum+timestep_in_minutes/1440: timestep_in_minutes/1440: enum
	c=c+1;
	trs(l+1).enum(c) = dnum;
	trs(l+1).snum(c) = dnum - timestep_in_minutes/1440;
end
trs(l+1).mode = 'compute';
eval(['save ',outfile,' trs']);


