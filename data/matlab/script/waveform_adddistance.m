function w = waveform_adddistance(w, matfile, subnets, subnet )

subnetnum = find(strcmp( {subnets.name}, subnet));
        stations = {subnets(subnetnum).stations.name};
        channels = {subnets(subnetnum).stations.channel};
        for c=1:numel(w)
                try
                        station = get(w(c), 'station');
                        channel = get(w(c), 'channel');
                        try
                                stachanindex = find(strcmp(stations, station) & strcmp(channels, channel));
                                w(c) = addfield(w(c), 'distance', subnets(subnetnum).stations(stachanindex).distance);
                        catch
                                fprintf('adding distance failed for %s.%s\n',station,channel);
                        end
                catch
                        fprintf('could not get station and/or channel\n');
                end
end
disp(sprintf('%s %s: added distance structures to waveform objects', mfilename, datestr(utnow)));