function parameters2subnetpf()
km = 25.0; % km
maxsta = 7;
[paths,PARAMS]=pf2PARAMS();
for c=1:length(PARAMS.subnetnames)
    subnets.name = PARAMS.subnetnames{c};
    subnets.source = pf2source(subnets.name);
    subnets.stations = getStationsWithinDist(subnets.source.longitude, subnets.source.latitude, km, paths.DBMASTER, maxsta);
    for k=1:length(subnets.stations)
        subnets.stations(k).channels = dbgetchannels(subnets.stations(k).name, paths.DBMASTER);
    end
    outfile = sprintf('pf/%s.pf',subnets.name);
    
    % The obvious approach, using dbpf, pfput and pfwrite does not work
    % because structures are way too big.
    %pf = dbpf;
    %pfput(pf, 'subnets', subnets);
    %pfput(pf, 'channels', channels);
    %pfwrite(pf, outfile);
    
    % So do it the long way instead
    if exist(outfile, 'file')
        system(sprintf('mv %s %s.%s',outfile,outfile,datestr(now,30)));
    end
    fout = fopen(outfile, 'w');
    fprintf(fout, 'latitude\t%.4f\n',subnets.source.latitude);
    fprintf(fout, 'longitude\t%.4f\n',subnets.source.longitude);
    fprintf(fout, 'spectrograms\t%d\n',1); 
    fprintf(fout, 'onemindata\t%d\n',1); 
    fprintf(fout, 'plots\t%d\n',1); 
    fprintf(fout, 'alarms\t%d\n',0); 
    fprintf(fout, 'stations &Arr{\n'); 
    for k=1:length(subnets.stations)
        fprintf(fout, '\t%s &Arr{\n',subnets.stations(k).name);
        fprintf(fout, '\t\tdistance\t%.2f\n',subnets.stations(k).distance); 
        fprintf(fout, '\t\tlatitude\t%.4f\n',subnets.stations(k).latitude);
        fprintf(fout, '\t\tlongitude\t%.4f\n',subnets.stations(k).longitude);  
        fprintf(fout, '\t\televation\t%.2f\n',subnets.stations(k).elevation);
        fprintf(fout, '\t\tchannels &Arr{\n');
        for l=1:length(subnets.stations(k).channels)
            fprintf(fout, '\t\t\t%s &Arr{\n',subnets.stations(k).channels{l});
            use=0;
            if regexp(subnets.stations(k).channels{l}, 'BDF') 
                use = 1;
            end
            if regexp(subnets.stations(k).channels{l}, '[BES]HZ')
                use = 1;
            end
            fprintf(fout, '\t\t\t\tuse\t%d\n',use);
            fprintf(fout, '\t\t\t\tthreshold\t%3.1f\n',0.0);
            fprintf(fout, '\t\t\t}\n'); % end of this channel
        end
        fprintf(fout, '\t\t}\n'); % end of channels
        fprintf(fout, '\t}\n'); % end of this station
    end
    fprintf(fout, '}\n'); % end of stations
    fclose(fout);
   
end
