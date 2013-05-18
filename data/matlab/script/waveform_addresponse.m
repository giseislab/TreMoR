function w = waveform_addresponse(w, matfile, subnets, subnet )

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
disp(sprintf('%s %s: adding response structures to waveform objects', mfilename, datestr(utnow)));