function tremor_winston2mat(subnets, tw)
global paths PARAMS
WINSTON_DATASOURCE = datasource('winston', 'churchill.giseis.alaska.edu', 16022);
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
    	scnl = station2scnl(station, 'AV');

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

		% 20111213: Create a zero size spectrogram image, so we know there was an attempt to run IceWeb on this timewindow
                timestamp = datestr(enum, 30);
                spdir = catpath(paths.WEBDIR, 'plots', 'sp', subnet, timestamp(1:4), timestamp(5:6), timestamp(7:8));
		system(sprintf('mkdir -p %s',spdir));
                tenminspfile = catpath(spdir, [timestamp, '.png']);
		if ~exist(tenminspfile,'file')
			system(sprintf('touch %s',tenminspfile)); 
			disp(sprintf('touch %s',tenminspfile)); 
		end

		% Get waveform data
		secsRequested = (enum - snum) * 86400;
		secsGot = 0.0;
		while (secsGot/secsRequested) < 0.9
			%w = getwaveforms(scnl, snum, enum);
			disp('loading waveforms');
			w = waveform(WINSTON_DATASOURCE, scnl, snum, enum);
			%w = getwaveforms2(scnl, snum, enum, datasources);
			%waveform_tracker(w, subnet, snum, enum);a % this function not ready & tested yet
			if isempty(w)
				disp('No waveform data found');
				break;
			else
				%[wsnum, wenum] = waveform2timewindow(w);
				[wsnum, wenum] = gettimerange(w);
				secsGotLastTime = secsGot;
				secsGot = (max(wenum) - min(wsnum)) * 86400;
				if (secsGotLastTime >= secsGot) % quit the loop as doing no better
					fprintf('Still only got %.1f seconds of data - will not wait any longer\n',secsGot);	
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
			for woc=1:numel(w)
				disp(sprintf('waveform %d, stachan %s-%s, samples %d',woc,get(w(woc), 'station'), get(w(woc), 'channel'), length(get(w(woc), 'data')) ));
			end

			% Save waveform data
			save2waveformmat(w, 'waveforms_raw', snum, enum, subnet);
			% update state file
			lastenum = enum;
			eval(['save ',lastenumfile,' lastenum']);
		end

		disp(sprintf('***** Finished %s %s %s *****\n\n', subnet, datestr(snum,15), datestr(enum,15) ));
	end
  %catch
%	disp(sprintf('Failed for subnet %s',subnet));
%  end
end
print_debug(sprintf('< %s',mfilename),1)
