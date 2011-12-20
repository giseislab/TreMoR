function tremor_loadlivedata(varargin)
global paths PARAMS

print_debug(sprintf('> %s at %s',mfilename, datestr(now,31)),1)
warning off
load pf/runtime
%subnets = randomizesubnets(subnets);

% Process arguments
[PARAMS.mode, snum, enum, nummins, delaymins] = process_options(varargin, 'mode', 'realtime', 'snum', 0, 'enum', 0, 'nummins', 10, 'delaymins', 0);
if enum==0
    enum = utnow - delaymins/1440;
end
if snum==0
    tw = get_timewindow(enum, nummins);
else
    tw = get_timewindow(enum, nummins, snum);
end
snum = enum - nummins/1440;

VALID_DATASOURCES = get_datasource(snum, enum); % there have to be  wfdisc rows ending later than 2nd argument, else no valid datasources
if isempty(VALID_DATASOURCES)
	disp('No valid datasources yet');
	return;
end
%tremor_datascope2mat(subnets, tw, VALID_DATASOURCES);

% loop over timewindows backwards, thereby prioritizing most recent data
for count = length(tw.start) : -1 : 1
	thistw.start = tw.start(count);	
	thistw.stop = tw.stop(count);	
	tremor_winston2mat(subnets, thistw);
end


print_debug(sprintf('< %s at %s',mfilename, datestr(now,31)),1)

function snew=randomizesubnets(s)
l = length(s);
r = rand(l, 1);
[o, i] = sort(r);
for c = 1:l
	snew(c) = s(i(c)); 
end
