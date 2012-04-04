function tremor_datascope2mat(subnets, tw, datasources)
global paths PARAMS

print_debug(sprintf('> %s',mfilename),1)

%%%%%%%%%%%%%%%%% LOOP OVER SUBNETS / STATIONS
% loop over all subnets
for subnet_num=1:length(subnets)
  %try % try this subnet
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
			w = getwaveforms2(scnl, snum, enum, datasources);
			%waveform_tracker(w, subnet, snum, enum);a % this function not ready & tested yet
			if isempty(w)
				disp('No waveform data found for this timewindow - quitting while loop');
				break;
			else
				%[wsnum, wenum] = waveform2timewindow(w);
				[wsnum, wenum] = gettimerange(w);
				secsGotLastTime = secsGot;
				secsGot = (max(wenum) - min(wsnum)) * 86400;
				if (secsGotLastTime >= secsGot) % quit the loop as doing no better
					fprintf('Still only got %.1f seconds of data - quitting while loop\n',secsGot);	
					break;
				end
				if (secsGot/secsRequested) < 0.9 && strcmp(PARAMS.mode, 'realtime') 
              				print_debug(sprintf('Pausing %.0f seconds for data to catch up',secsRequested - secsGot),1);
					pause(secsRequested - secsGot); 
				end
			end
		end

		if ~isempty(w)
			disp('Got some waveform data - will now run save2waveformmat');
			% Save waveform data
			save2waveformmat(w, 'waveforms_raw', snum, enum, subnet);
			% update state file
			lastenum = enum;
			eval(['save ',lastenumfile,' lastenum']);
		end
	end
  %catch
%	disp(sprintf('Failed for subnet %s',subnet));
%  end
end
print_debug(sprintf('< %s',mfilename),1)
