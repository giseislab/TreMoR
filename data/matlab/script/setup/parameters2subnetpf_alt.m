function parameters2subnetpf()
km = 30.0; % km
maxchans = 30;
[paths,PARAMS]=pf2PARAMS();
outfile = 'params/subnets.d';
if exist(outfile, 'file')
    system(sprintf('mv %s %s.%s',outfile,outfile,datestr(now,30)));
end
fout = fopen(outfile, 'w');
for c=1:length(PARAMS.subnetnames)
    subnets.name = PARAMS.subnetnames{c};
    subnets.source = pf2source(subnets.name);
    subnets.stations = getStationsWithinDist(subnets.source.longitude, subnets.source.latitude, km, paths.DBMASTER, maxchans)
    for k=1:length(subnets.stations)
        subnets.stations(k).response = response_get_from_db(subnets.stations(k).name, subnets.stations(k).channel, now, PARAMS.f, paths.DBMASTER);
    end
    fprintf(fout, 'SUBNET\t%s\t%.4f\t%.4f\t1\n',subnets.name, subnets.source.latitude, subnets.source.longitude);
    totalinuse = 0;
    for k=1:length(subnets.stations)
        useit=0;
        if regexp(subnets.stations(k).channel, '[BES]HZ')  & (totalinuse < 6)
                useit = 1;
		totalinuse = totalinuse + 1;
        end
        fprintf(fout, 'scn\t%s.%s.%s\t%.4f\t%.4f\t%.2f\t%.4f\t%d\n',subnets.stations(k).name, subnets.stations(k).channel, get(subnets.stations(k).scnl, 'network'), subnets.stations(k).site.lat, subnets.stations(k).site.lon, subnets.stations(k).site.elev, subnets.stations(k).response.calib, useit);
    end
    fprintf(fout, '\n\n'); % end of subnet

   
end
fclose(fout);
