function tremor_loadwaveformdata(varargin)
global paths PARAMS

debug.print_debug(sprintf('> %s at %s',mfilename, datestr(now,31)),1)
warning off


% Process arguments
[thismode, snum, enum, nummins, delaymins, thissubnet, matfile] = matlab_extensions.process_options(varargin, 'mode', 'realtime', 'snum', 0, 'enum', 0, 'nummins', 10, 'delaymins', 0, 'thissubnet', '', 'matfile', 'pf/tremor_runtime.mat');
if exist(matfile, 'file')
    load(matfile);
    PARAMS.mode = thismode;
    clear thismode;
else
    disp('matfile not found')
    return
end

% subset on thissubnet
if ~strcmp(thissubnet, '') 
	index = 0;
	for c=1:length(subnets)
		if strcmp(subnets(c).name, thissubnet)
			index = c;
		end
	end
	if index > 0
		subnets = subnets(index);
		disp('subnet found')
	else
		disp('subnet not found')
		return;
	end
end

% end time
if enum==0
    enum = utnow - delaymins/1440;
end

% timewindows
if snum==0
    tw = get_timewindow(enum, nummins);
else
    tw = get_timewindow(enum, nummins, snum);
end
snum = enum - nummins/1440;

% loop over timewindows backwards, thereby prioritizing most recent data
for count = length(tw.start) : -1 : 1
	thistw.start = tw.start(count);	
	thistw.stop = tw.stop(count);	
	tremor_datasource2mat(subnets, thistw);
end

debug.print_debug(sprintf('< %s at %s',mfilename, datestr(now,31)),1)

function snew=randomizesubnets(s)
l = length(s);
r = rand(l, 1);
[o, i] = sort(r);
for c = 1:l
	snew(c) = s(i(c)); 
end
