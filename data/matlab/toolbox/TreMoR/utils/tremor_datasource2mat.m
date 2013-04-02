function tremor_datasource2mat(subnets, tw)
debug.printfunctionstack('>');
global paths PARAMS
for c=1:numel(PARAMS.datasource)
	if strcmp(PARAMS.datasource(c).type, 'antelope')
		gismo_datasource(c) = datasource(PARAMS.datasource(c).type, PARAMS.datasource(c).path);
	else
		gismo_datasource(c) = datasource(PARAMS.datasource(c).type, PARAMS.datasource(c).path, str2num(PARAMS.datasource(c).port));
	end
end
%gismo_datasource = gismo_datasource(1);

%%%%%%%%%%%%%%%%% LOOP OVER SUBNETS / STATIONS
% loop over all subnets
for subnet_num=1:length(subnets)
	% which subnet?
	subnet = subnets(subnet_num).name;

	% get IceWeb stations
	station = subnets(subnet_num).stations;
	if isempty(station)
		continue;
	end
    	scnl = station2scnl(station, 'AV');

	% loop over all elements of tw
	for twcount = 1:length(tw.start)
		tic;
		snum = tw.start(twcount);
		enum = tw.stop(twcount);

		% Have we already process this timewindow?
		tenminspfile = getSgram10minName(subnet,enum);
		diaryname = getSgramDiaryName(subnet, enum);
		diary(diaryname);
		disp(sprintf('%s %s: Started',mfilename, datestr(utnow)));

		if strcmp(PARAMS.mode, 'realtime')
			% need to check for spectrogram file too
			if exist(tenminspfile,'file')
				% go to next timewindow because the spectrogram PNG exists
				disp(sprintf('%s %s: Data already processed because spectrogram file %s already exists. Skipping',mfilename, datestr(utnow), tenminspfile));
				diary off;
				continue;	
			else
				% 20111213: Create a zero size spectrogram image, so we know there was an attempt to run IceWeb on this timewindow
				system(sprintf('touch %s',tenminspfile)); 
				disp(sprintf('%s %s: Created 0 length spectrogram file %s',mfilename, datestr(utnow), tenminspfile));
			end
		end

		% Get waveform data
		disp(sprintf('%s %s: Getting waveforms for %s from %s to %s at %s',mfilename, datestr(utnow), subnet , datestr(snum), datestr(enum)));
		w = waveform_wrapper(scnl, snum, enum, gismo_datasource);

		% Did we get any data - if not, delete spectrogram file so it will try again later, and quit loop.	
		if isempty(w)
			disp(sprintf('%s %s: No waveform data found - skipping',mfilename, datestr(utnow)));
			delete(tenminspfile)
			diary off;
			break;
		else
			% GTHO 20130125: Capture data requests that failed
			for i=1:numel(w)
        			dl0 = get(w(i), 'data_length');
				if (dl0==0)
        				sta0 = get(w(i), 'station');
        				chan0 = get(w(i), 'channel');
					flogbadchannels = fopen('logs/badchannels.log', 'a');
        				fprintf(flogbadchannels, '%s: waveform %d: got %d samples for %s-%s for time %s to %s\n',datestr(utnow), i,dl0,sta0,chan0, datestr(snum), datestr(enum));
					fclose(flogbadchannels);
				end
			end
		end

		% If we are requesting real-time data, wait for data to backfill because there may be latency.
		% Otherwise, ignore this condition.
		if (utnow - snum) < (10/1440) % real-time data were requested
			 
			% Did we get enough data - if not, delete spectrogram file so it will try again later, and quit loop.
			secsRequested = (enum - snum) * 86400;
			minFraction = 0.99;
			[wsnum, wenum] = gettimerange(w);
			secsGot = (max(wenum) - min(wsnum)) * 86400;
 			if (secsGot/secsRequested) < minFraction
				fprintf('%s %s: Only got %.1f seconds of data - skipping\n',mfilename,datestr(utnow),secsGot);	
				disp('Insufficient waveform data found - deleting blank spectrogram file');
				delete(tenminspfile)
				diary off;
				break;
			end
		end

		% Report waveform state-of-health data into log file
		%try
			waveform_soh(w, snum, enum);
		%catch ME
		%	ME
			%ME.stack

		%end

		% Save waveform data
		save2waveformmat(w, 'waveform_files/loaded', snum, enum, subnet);
		%save2waveformmat(w, 'waveform_files/loaded', snum, enum, subnet, 'copy', 'waveform_files_copy');

		% update benchmark log
		logbenchmark(mfilename, toc);
		
		disp(sprintf('%s %s: Finished',mfilename, datestr(utnow)));
		diary off

	end
end
debug.printfunctionstack('<');

function scnl=station2scnl(station, network)
for c = 1 : length(station)
	if exist('network','var')
		scnl(c) = scnlobject(station(c).name, station(c).channel, network);
	else

		scnl(c) = scnlobject(station(c).name, station(c).channel);
	end
end


function waveform_soh(w, snum, enum)
% Added by Glenn, September 2012
nsecsexpected = (enum-snum)*86400;
percentagegot = zeros(numel(w),1);
for i=1:numel(w)

        % initialise some values
        thisrange = NaN;
        thisnblanksecs = 0.0;
        thism = NaN;
        thisf = NaN;
        thisnsecsgot = 0;
        thisnuniquevalues = 0;
        thisreportstring = '';
        thiserrorstring = '';

        % set stuff from waveform object
        thissta = get(w(i), 'station');
        thischan = get(w(i), 'channel');
        thisds = get(w(i), 'ds');
        thismode = get(w(i), 'mode');
        thisdl = round(get(w(i), 'data_length'));
        thisfreq = get(w(i), 'freq');

        % update number of seconds of data got
        if ~isnan(thisfreq)
                thisnsecsgot = thisdl/thisfreq;
        end

        % the new magic added on 2012/09/25 to discover bad or missing data
        thisreportstring = sprintf('%s SECONDS-GOT:%.1f',thisreportstring, thisnsecsgot);
        if thisnsecsgot > 0
            thisdata = get(w(i),'data');

            % CHECK FOR ONE-SIDED DATA
            [thism, thisf] = mode(thisdata); % only returns NaN if all values NaN
            thisreportstring = sprintf('%s MODE:%.1e MODE-FREQUENCY:%d',thisreportstring, thism, thisf);
	    if isnan(thism)
		% All data are NaN
                thisnblanksecs = thisnsecsgot;
                thiserrorstring = sprintf('%s ALL-NAN',thiserrorstring);
	    else
                mode_fraction = (thisf/thisdl); 
                thisreportstring = sprintf('%s MODE-FRACTION:%.2f',thisreportstring, mode_fraction);
                if (mode_fraction > 0.1) % AT LEAST 10% OF DATA AT SAME LEVEL (WORRIED ABOUT CLIPPING)
                        if nanmax(thisdata)==thism || nanmin(thisdata)==thism
                                % ONE SIDED DATA - SEISMOMETER STUCK?
                                thisnblanksecs = thisnsecsgot;
                                thiserrorstring = sprintf('%s ONE-SIDED',thiserrorstring);
                        end
                end

                % CHECK NUMBER OF UNIQUE VALUES. IF NOT MANY, RADIO GETTING NO SEISMIC SIGNAL?
                thisnuniquevalues = length(unique(thisdata));
                thisreportstring = sprintf('%s UNIQUE-VALUES:%d',thisreportstring, thisnuniquevalues);
                if thisnuniquevalues<=64 % 6 bits of data resolution
                        thisnblanksecs = thisnsecsgot;
                        thiserrorstring = sprintf('%s FEW-UNIQUE',thiserrorstring);
                end

                % CHECK FOR SMALL DATA RANGE - THINK THIS IS OBSOLETE DUE TO UNIQUE VALUE CHECK
                thisrange = max(thisdata) - min(thisdata);
		bitrange = ceil(log(thisrange)/log(2));
                thisreportstring = sprintf('%s BIT-RANGE:%d',thisreportstring, bitrange);
                if thisrange<10 % if range < 10, all data must be bad
                       % NOT A MEANINGFUL DATA RANGE - NO SEISMIC SIGNAL?
                       thisnblanksecs = thisnsecsgot;
                       thiserrorstring = sprintf('%s SMALL-RANGE',thiserrorstring);
                end

                % IF DATA GOOD SO FAR, LETS SEE HOW MANY MISSING VALUES THERE ARE
                if thisnblanksecs == 0
                        % MISSING DATA
                        % assume NaN's are missing data
                        theseindices = find(isnan(thisdata));
                        thisnblanksecs = length(theseindices)/thisfreq;
                        thisreportstring = sprintf('%s MISSING-SECONDS:%.1f',thisreportstring,thisnblanksecs);
                end
	    end
	else
		% No data
                thisnblanksecs = thisnsecsgot;
                thiserrorstring = sprintf('%s NO-DATA',thiserrorstring);
        end
        if strcmp(thiserrorstring,'')
                thiserrorstring = 'GOOD';
        end

        % compute the percent of good data
        percentagegot(i) = ((thisnsecsgot-thisnblanksecs) / nsecsexpected) * 100.0;

        % summarise what we got for this waveform object
        debug.print_debug(sprintf('- waveform %d, stachan %s.%s, got %.1f%%, bitrange %d, mode %f, modefreq %f%%, numuniquevals %d, blank-seconds %f, datasource %s, method %s \n%s \n%s',i,thissta,thischan,percentagegot(i),bitrange,thism,mode_fraction*100.0,thisnuniquevalues,thisnblanksecs,thisds,thismode,thisreportstring,thiserrorstring),2);
end
