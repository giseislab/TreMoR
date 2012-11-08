function tremor_loadarchivedata(thissubnet, snum, enum, nummins)
global paths PARAMS

print_debug(sprintf('> %s at %s',mfilename, datestr(now,31)),1)
warning off
load pf/runtime
PARAMS.mode = 'archive';
index = 0;
for c=1:length(subnets)
	if strcmp(subnets(c).name, thissubnet)
		index = c;
	end
end
if index > 0
	subnets = subnets(index);
    	tw = get_timewindow(enum, nummins, snum);
	tremor_datascope2mat(subnets, tw);
else
	disp('subnet not found')
end

print_debug(sprintf('< %s at %s',mfilename, datestr(now,31)),1)
