function tremor_filterwaveformdata(waveformdir)
global paths PARAMS
print_debug(sprintf('> %s at %s',mfilename, datestr(now,31)),1)
load pf/runtime

while 1,

	tic;
	[w, filename, snum, enum, subnet] = loadnextwaveformmat(waveformdir);
	diaryname = getSgramDiaryName(subnet, enum);
	diary(diaryname);
        
       	% Add response structures to waveform objects
	disp('Adding response structures to waveform objects');
	subnetnum = find(strcmp( {subnets.name}, subnet));
	stations = {subnets(subnetnum).stations.name};
	channels = {subnets(subnetnum).stations.channel};
	for c=1:numel(w)
		try
			station = get(w(c), 'station');
			channel = get(w(c), 'channel');
			try
				stachanindex = find(strcmp(stations, station) & strcmp(channels, channel));
				w(c) = addfield(w(c), 'response', subnets(subnetnum).stations(stachanindex).response);
			catch
				fprintf('adding response failed for %s.%s\n',station,channel);
			end
		catch
			fprintf('could not get station and/or channel\n');
		end
	end

      	% Remove calibs, despike, detrend and deconvolve waveform data
	disp('remove spikes, remove trend, calibrate and bandpass filter'); 
      	w = waveform_clean(w, 'filter_waveforms', false, 'filterObj', PARAMS.filterObj, 'remove_spikes', 'true', 'remove_trend', 'true', 'remove_response', 'false'); % cannot remove full instrument response as Mike's response_apply is broken. But calib is used.

	% Save waveforms
	save2waveformmat(w, 'waveform_files/stage2_filtered', snum, enum, subnet);

	logbenchmark(mfilename, toc);
	diary off;

        % Pause briefly
        pause(1);
end    

print_debug(sprintf('< %s at %s',mfilename, datestr(now,31)),1)

