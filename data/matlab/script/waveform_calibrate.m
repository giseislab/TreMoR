function w=waveform_calibrate(w, snum, enum);   

% remove calib. Also high pass
     	% filter broadband channels.
	w = waveform_fillempty(w, snum, enum); % alternative is the waveform_nonempty function, which eliminates empty waveform objects, rather than replacing them with waveform objects containing zeros. Both eliminate waveform objects of length 1 - these corrupt waveform objects cause masaive problems - no idea where they coome from 
	%w = waveform_nonempty(w); 
	if isempty(w)
		return;
	end
	for c=1:numel(w)
		w(c) = detrend(fillgaps(w(c),mean(w(c))));
		thissta = get(w(c), 'station');
		thischan = get(w(c), 'channel');

        	if strcmp(get(w(c),'Units'), 'Counts')
                        resp = get(w(c), 'response');
                        rawmax = nanmax(abs(get(w(c), 'data')));
                        fprintf('%s: Max raw amplitude for %s.%s = %e counts\n',mfilename, thissta, thischan, rawmax);
                        fprintf('%s: Applying calib of %d for %s.%s\n',mfilename, resp.calib, thissta, thischan);
                        if (resp.calib ~= 0)
                                w(c) = w(c) * resp.calib;
                                %w(c) = set(w(c), 'units', resp.units);
                                w(c) = set(w(c), 'units', 'nm / sec');
                        end
                        fprintf('%s: Max corrected amplitude for %s.%s = %e nm/s\n',mfilename: thissta, thischan, rawmax);
                end
		if strfind(thischan,'BH')
			try
	                        debug.print_debug(sprintf('Applying high pass filter to %s.%s', thissta, thischan), 1);
                            w(c) = filtfilt(highpassfilterobject, w(c));
			catch
	                        debug.print_debug(sprintf('Filter failed'), 1);
			end
		end
	end

	disp(sprintf('%s %s: calibrated spectrogram waveforms', mfilename, datestr(utnow)));