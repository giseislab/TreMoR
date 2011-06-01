function tremor_loadwaveformdata(varargin)
global paths PARAMS
print_debug(sprintf('> %s at %s',mfilename, datestr(now,31)),1)
load pf/runtime

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

%%%%%%%%%%%%%%%%% LOOP OVER SUBNETS / STATIONS
% loop over all subnets
for subnet_num=1:length(subnets)

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
			if (lastenum == timewindow.stop && ~strcmp(PARAMS.mode, 'test') )
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
			w = getwaveforms(scnl, snum, enum);
			if isempty(w)
				disp('No waveform data found for this timewindow');
				continue; % jump to next timewindow (or subnet)
			else
				[wsnum, wenum] = waveform2timewindow(w);
				secsGotLastTime = secsGot;
				secsGot = (wenum - wsnum) * 86400;
				if (secsGotLastTime >= secsGot) % quit the loop as doing no better
					break;
				end
              			print_debug(sprintf('Pausing %.0f seconds for data to catch up',secsRequested - secsGot));
				pause(secsRequested - secsGot); 
			end
		end

		% Save waveform data
		save2waveformmat(w, 'waveforms_raw', snum, enum, subnet);

		% update state file
		lastenum = tenum;
		eval(['save ',lastenumfile,' lastenum']);
	end
end
print_debug(sprintf('< %s at %s',mfilename, datestr(now,31)),1)


