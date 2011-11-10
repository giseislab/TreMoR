function tremor_filterwaveformdata(varargin)
global paths PARAMS
print_debug(sprintf('> %s at %s',mfilename, datestr(now,31)),1)
load pf/runtime

while 1,
	[w, filename, snum, enum, subnet] = loadnextwaveformmat('waveforms_raw');

	% Output some information
	disp(sprintf('\n***** New waveform *****'));
	disp(sprintf('Start time is %s UTC',datestr(snum)));
	disp(sprintf('End time is %s UTC',datestr(enum)));
        
        % Add response structures to waveform objects
        
        % Remove calibs, despike, detrend and deconvolve waveform data
        w = waveform_clean(w, 'filterObj', PARAMS.filterObj);

	% Save waveforms
	save2waveformmat(w, 'waveforms_filtered', snum, enum, subnet);

	% Remove waveforms MAT file from waveforms_raw
	delete(filename);

	% Pause briefly
	pause(1);
end    

print_debug(sprintf('< %s at %s',mfilename, datestr(now,31)),1)

