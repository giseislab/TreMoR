function subnetpf2runtimemat();
% SUBNETPF2MAT
% Reads all subnet.pf files and produces tremorruntime.mat
print_debug(sprintf('> %s', mfilename),5)

[paths,PARAMS]=pf2PARAMS;

for c=1:length(PARAMS.subnetnames)
    subnetname = PARAMS.subnetnames{c};
    subnets(c).name = subnetname;
    
    % create pointer to main parameter file
    if isfield(paths,'PFS')
        subnetfile = sprintf('%s/%s',paths.PFS,subnetname);
    else
        subnetfile = sprintf('pf/%s',subnetname);    
    end

    if exist([subnetfile,'.pf'], 'file')
        pf = dbpf(subnetfile);

        % get station list for this subnet from parameter file
        pointerToStations = pfget_arr(pf,'stations');
        stas = pfkeys(pointerToStations);
    
        % for each station, get the corresponding channel, threshold and use
        cc=0;
        for k=1:length(stas)
            sta = stas{k};
            pointerToStation = pfget_arr(pointerToStations,sta);
            pointerToChannels = pfget_arr(pointerToStation,'channels');
		    chans = pfkeys(pointerToChannels);
            for l = 1:length(chans)
                chan = chans{l};
                pointerToChannel = pfget_arr(pointerToChannels,chan);
                use = pfget(pointerToChannel,'use');
                if use==1
                    cc=cc+1;
                    subnets(c).stations(cc).name = sta;                   
                    subnets(c).stations(cc).channel = chan;
                    subnets(c).stations(cc).threshold = pfget(pointerToChannel,'threshold');
                    subnets(c).stations(cc).distance = pfget(pointerToStation,'distance');
                    subnets(c).stations(cc).latitude = pfget(pointerToStation,'latitude');
                    subnets(c).stations(cc).longitude = pfget(pointerToStation,'longitude');
                    subnets(c).stations(cc).response = response_get_from_db(sta, chan, now, PARAMS.f, paths.DBMASTER);
                end
            end
        end
        subnets(c).source.latitude = pfget(pf, 'latitude');
        subnets(c).source.longitude = pfget(pf, 'longitude');
        subnets(c).spectrograms = pfget_num(pf, 'spectrograms');
        subnets(c).onemindata = pfget_num(pf, 'onemindata');
        subnets(c).plots = pfget_num(pf, 'plots');
        subnets(c).alarms = pfget_num(pf, 'alarms');



    else
        subnets(c) = [];
    end
end

save pf/runtime.mat subnets PARAMS paths

print_debug(sprintf('< %s', mfilename),5)

