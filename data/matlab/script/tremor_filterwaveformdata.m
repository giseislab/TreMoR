function tremor_filterwaveformdata(varargin)
global paths PARAMS
print_debug(sprintf('> %s at %s',mfilename, datestr(now,31)),1)
load pf/runtime

while 1,
	[w, filename, snum, enum, subnet] = loadnextwaveformmat('waveforms_raw');
        
       	% Add response structures to waveform objects

	subnets 
	subnetnum = find(strcmp( {subnets.name}, subnet));
	stations = {subnets(subnetnum).stations.name};
	channels = {subnets(subnetnum).stations.channel};
	for c=1:numel(w)
		station = get(w(c), 'station');
		channel = get(w(c), 'channel');
		try
			stachanindex = find(strcmp(stations, station) & strcmp(channels, channel));
			w(c) = addfield(w(c), 'response', subnets(subnetnum).stations(stachanindex).response);
		catch
			fprintf('adding response failed for %s.%s\n',station,channel);
		end
	end

      	% Remove calibs, despike, detrend and deconvolve waveform data
      	w = waveform_clean(w, 'filterObj', PARAMS.filterObj, 'remove_spikes', 'true', 'remove_trend', 'true', 'remove_response', 'true');

	% Save waveforms
	save2waveformmat(w, 'waveforms_filtered', snum, enum, subnet);

        % Pause briefly
        pause(5);
end    

print_debug(sprintf('< %s at %s',mfilename, datestr(now,31)),1)

