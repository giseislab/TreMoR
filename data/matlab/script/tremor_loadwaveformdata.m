function tremor_loadwaveformdata(varargin)
global paths PARAMS
debug(5)
warning on 

print_debug(sprintf('> %s at %s',mfilename, datestr(now,31)),1)
load pf/runtime
subnets = randomizesubnets(subnets);

% Process arguments
[PARAMS.mode, snum, enum, nummins] = process_options(varargin, 'mode', 'realtime', 'snum', 0, 'enum', 0, 'nummins', 10);
if enum==0
    enum = utnow - nummins/1440;
end
if snum==0
    tw = get_timewindow(enum, nummins);
else
    tw = get_timewindow(enum, nummins, snum);
end
snum = enum - nummins/1440;

DELAYMINS =  0;
VALID_DATASOURCES = get_datasource(snum, enum + DELAYMINS/1440); % there have to be  wfdisc rows ending later than 2nd argument, else no valid datasources
if isempty(VALID_DATASOURCES)
	disp('No valid datasources yet');
	return;
end

%%%%%%%%%%%%%%%%% LOOP OVER SUBNETS / STATIONS
% loop over all subnets
for subnet_num=1:length(subnets)
  try % try this subnet
	% which subnet?
	subnet = subnets(subnet_num).name;
	disp(sprintf('\n****** Starting %s at %s *****',subnet , datestr(now)));

	% get IceWeb stations
	station = subnets(subnet_num).stations;
    	scnl = station2scnl(station);

	% loop over all elements of tw
	for twcount = 1:length(tw.start)
		snum = tw.start(twcount);
		enum = tw.stop(twcount);

			

		% Lets examine the last timewindow plotted for this subnet
		lastenumfile = ['state/lastenum_',subnet,'.mat'];
		if (exist(lastenumfile, 'file') && strcmp(PARAMS.mode, 'realtime'))
			eval(['load ',lastenumfile]);
			if (lastenum == enum && ~strcmp(PARAMS.mode, 'test') )
				disp('Already processed these data');
				continue;
			end
		end

		% Output some information
		disp(sprintf('\n***** Time Window *****'));
		disp(sprintf('Start time is %s UTC',datestr(snum)));
		disp(sprintf('End time is %s UTC',datestr(enum)));

		% Get waveform data
		secsRequested = (enum - snum) * 86400;
		secsGot = 0.0;
		while (secsGot/secsRequested) < 0.9
			%w = getwaveforms(scnl, snum, enum);
disp('loading waveforms');
			w = getwaveforms2(scnl, snum, enum, VALID_DATASOURCES)
			%waveform_tracker(w, subnet, snum, enum);a % this function not ready & tested yet
			if isempty(w)
				disp('No waveform data found for this timewindow');
				%append2missingDataList(scnl, snum, enum, subnet); 
				break;
			else
				%[wsnum, wenum] = waveform2timewindow(w);
				[wsnum, wenum] = gettimerange(w);
				secsGotLastTime = secsGot;
				secsGot = (max(wenum) - min(wsnum)) * 86400;
				if (secsGotLastTime >= secsGot) % quit the loop as doing no better
					break;
				end
				if (secsGot/secsRequested) < 0.9 
              				print_debug(sprintf('Pausing %.0f seconds for data to catch up',secsRequested - secsGot),1);
					pause(secsRequested - secsGot); 
				end
			end
		end

		if ~isempty(w)
			% Save waveform data
			save2waveformmat(w, 'waveforms_raw', snum, enum, subnet);
			% update state file
			lastenum = enum;
			eval(['save ',lastenumfile,' lastenum']);
		end
	end
  catch
	disp(sprintf('Failed for subnet %s',subnet));
  end
end
print_debug(sprintf('< %s at %s',mfilename, datestr(now,31)),1)

function append2missingDataList(scnl, snum, enum, subnet)
load state/missingDataList.mat
l = length(mdi);
mdi(l+1).scnl = scnl;
mdi(l+1).snum = snum;
mdi(l+1).enum = enum;
mdi(l+1).subnet = subnet;
save state/missingDataList.mat mdi 

function snew=randomizesubnets(s)
l = length(s);
r = rand(l, 1);
[o, i] = sort(r);
for c = 1:l
	snew(c) = s(i(c)); 
end
