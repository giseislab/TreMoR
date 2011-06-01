function tremor(varargin)
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

% We have not really done any useful yet
somethingRan = 0;

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
		timewindow.start = tw.start(twcount);
		timewindow.stop  = tw.stop(twcount);

		% Lets examine the last timewindow plotted for this subnet
		lastenumfile = ['state/lastenum_',subnet,'.mat'];
		if (exist(lastenumfile, 'file') && strcmp(PARAMS.mode, 'realtime'))
			eval(['load ',lastenumfile]);
			if (lastenum == timewindow.stop && ~strcmp(PARAMS.mode, 'test') )
				disp('Already processed these data');
				continue;
			end
		end
		somethingRan = 1;

		% Output some information
		disp(sprintf('\n***** Time Window *****'));
		disp(sprintf('Start time is %s UTC',datestr(timewindow.start)));
		disp(sprintf('End time is %s UTC',datestr(timewindow.stop)));
		timestamp = datestr(timewindow.stop, 30);

		% 1. Get waveform data
		w = getwaveforms(scnl, timewindow);
		if (size(w)==0)
			disp('No waveform data found for this timewindow');
			continue;
        end
        
        % add response structures to waveform objects
        
        % Remove calibs, despike, detrend and deconvolve waveform data
        w = waveform_clean(w, 'filterObj', PARAMS.filterObj);
		try
		  	if (w == -1) || (length(w) == 0) % no data
		  	    disp(sprintf('No waveform data for %s',subnet));
		  	    continue;
		    end
		end    

		% Before we go further, lets see if the data returned are for
		% the full timewindow requested, which means we want to be within 10s
		wt = waveform2timewindow(w);
		secsDiff = (timewindow.stop - wt.stop) * 86400;
        if strcmp(PARAMS.mode,'realtime')
           if (abs(secsDiff) < 1)
                disp('Data are complete');
                pause( min([wt.maxDiff 60]) );
           else
                disp(sprintf('Data are incomplete: secsDiff = %.0f',secsDiff));
                continue;
            end
        end

		% 2. Create 10 minute spectrogram plots
		close all;

		% Plot multiple panel spectrograms 
		spdir = catpath(paths.WEBDIR, 'plots', 'sp', subnet, timestamp(1:4), timestamp(5:6), timestamp(7:8));
		tenminspfile = catpath(spdir, [timestamp, '.png']);
		disp(sprintf('Creating spectrogram, file will go to %s',tenminspfile));
		%subnet2spectrogram(subnet, w, tenminspfile, timewindow);
		specgram3(w, sprintf('%s %s - %s UTC',subnet,datestr(timewindow.start,31),datestr(timewindow.stop,13)), PARAMS.spectralobject, 0.75);

		% add colorbar
		%if (PARAMS.colorbar == 1) % this does not exist as a parameter currently            
			%addColorbar(get(PARAMS.spectralobject,'dblims')); % this function no longer exists!
		%end

		% save image file
		orient tall;
		try
			saveImageFile(tenminspfile, 60);
			%saveImageFile(tenminspfile, 120);

        catch exception
            disp(sprintf('Could not save %s\n%s',tenminspfile,exception.message));
		end
				
		% Create a thumbnail spectrogram
		spthumbfile = catpath(spdir, ['small_', timestamp, '.png']);
		disp(sprintf('Creating spectrogram, file will go to %s',spthumbfile));
		makeThumbnail(spthumbfile, timestamp);

		
		% 3. Calculate and save true ground motion data (at the
		% seismometer) to file (no reduced measurements)
  		onemin = waveform2onemin(w);
		onemin2bobfiles(onemin);

		% At this point, since we will have a spectrogram.ps file and derived data computed,
		% and since alarms are no good unless they are real-time, we will make a decision
		% that this timewindow of data for this subnet is done
		% we need to log that somehow, so we don't run it again
		lastenum = timewindow.stop;
		eval(['save ',lastenumfile,' lastenum']);

		% 4. Run alarm algorithm(s)
		if (PARAMS.detectAlarms == 1) 
			try
				detectAlarms(subnet, station, timewindow, PARAMS.measures(1), 'static');
                detectAlarms(subnet, station, timewindow, PARAMS.measures(1), 'adaptive');
			catch
				disp('Alarm detection failed');
			end
		end

		% 5. Create Derived Data plots
		if ( strcmp(PARAMS.mode,'realtime')) 
			%make1minPlots(subnet, station, timewindow.stop, subnets(subnet_num).days);
           	make1minPlots(subnet, station, timewindow.stop, PARAMS.dayplots);
		end

		if ( PARAMS.sound)
			% 6. create a sound file
			numStations=length(w);
			for stationNum=1:numStations
				station_name = get(w(stationNum),'station');
				% create directory for writing sound file
				sounddir = catpath(paths.WEBDIR,'sound', subnet, timestamp(1:4), timestamp(5:6), timestamp(7:8));	
				soundfile = [timestamp,'_',station_name ];
				data = get(w(stationNum), 'data');
				Fs = round(get(w(stationNum),'freq'));
				waveformdata2sound(data, Fs, sounddir, soundfile);
			end
			
			% 7. output the stations list for sound file links in spectrograms			
			fptr = fopen(catpath(paths.WEBDIR, 'sound', subnet, 'stations.txt'), 'w');
			for c=1:length(w)
				if (length(get(w(c), 'data')) > 600)
					station_name = get(w(c),'station');
					fprintf(fptr, '%s\n', station_name);
				end
			end
			fclose(fptr);
		end
	
	end

end


print_debug(sprintf('< %s at %s',mfilename, datestr(now,31)),1)


