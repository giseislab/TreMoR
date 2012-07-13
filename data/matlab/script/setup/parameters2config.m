function parameters2config(KM, MAXCHANS, MAXUSED)
if ~exist('KM', 'var')
	KM = 50.0; % KM
end
if ~exist('MAXCHANS', 'var')
	MAXCHANS = 50; 
end
if ~exist('MAXUSED', 'var')
	MAXUSED = 6; 
end
[paths,PARAMS]=pf2PARAMS();

disp('The subnets chosen are:');
for c=1:length(PARAMS.subnetnames)
	disp(sprintf('%d: %s',c, PARAMS.subnetnames{c}));
end
outfile = 'params/subnets.d';
laststation = 'ZZZZ';
if exist(outfile, 'file')
    system(sprintf('mv %s %s.%s',outfile,outfile,datestr(now,30)));
end
fout = fopen(outfile, 'w');
for c=1:length(PARAMS.subnetnames)
    subnets.name = PARAMS.subnetnames{c};
    subnets.source = pf2source(subnets.name);
    subnets.stations = getStationsWithinDist(subnets.source.longitude, subnets.source.latitude, KM, paths.DBMASTER, MAXCHANS);
    for k=1:length(subnets.stations)
        subnets.stations(k).response = response_get_from_db(subnets.stations(k).name, subnets.stations(k).channel, now, PARAMS.f, paths.DBMASTER);
    end
    usesubnet = ~excluded_subnet(subnets.name);
    fprintf(fout, 'SUBNET\t%s\t%.4f\t%.4f\t%d\n',subnets.name, subnets.source.latitude, subnets.source.longitude,usesubnet);
    totalinuse = 0;
    for k=1:length(subnets.stations)
        useit=0;
        if regexp(subnets.stations(k).channel, '[BES]HZ')  & (totalinuse < MAXUSED) & (~excluded_scnl(subnets.stations(k).name, subnets.stations(k).channel) & ~strcmp(subnets.stations(k).name, laststation))
                useit = 1;
		totalinuse = totalinuse + 1;
		laststation = subnets.stations(k).name;
        end
        fprintf(fout, 'scn\t%s.%s.%s\t%.4f\t%.4f\t%.2f\t%.4f\t%d\n',subnets.stations(k).name, subnets.stations(k).channel, get(subnets.stations(k).scnl, 'network'), subnets.stations(k).site.lat, subnets.stations(k).site.lon, subnets.stations(k).site.elev, subnets.stations(k).response.calib, useit);
    end
    fprintf(fout, '\n\n'); % end of subnet

   
end
fclose(fout);

function exclude = excluded_scnl(sta, chan)
exclude = false;
str = sprintf('%s.%s',sta,chan);
fid = fopen('params/exclude_scnl.d');
tline = fgetl(fid);
while ischar(tline)
    	%disp(tline)
    	tline = fgetl(fid);
	if length(tline)==0
		continue;
	else
		if strcmp(tline(1), '#')
			continue;
		end
		if ischar(tline)
			if (regexp(tline,str))
				exclude = true;
			end
		end
	end	
end
fclose(fid);

function exclude = excluded_subnet(subnet)
exclude = false;
fid = fopen('params/exclude_subnet.d');
tline = fgetl(fid);
while ischar(tline)
    	%disp(tline)
    	tline = fgetl(fid);
	if strcmp(tline(1), '#')
		next;
	end
	if ischar(tline)
		if (strcmp(tline,subnet))
			exclude = true;
		end
	end	
end
fclose(fid);


