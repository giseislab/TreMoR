function setup()
disp('Use this function to generate a MATLAB workspace for running the spectrograms from an Antelope-style parameter file (default: setup.pf). The MATLAB workspace, stored in a matfile, will contain a structures describing filesystem paths, spectrogram parameters, and a list of subnets and their coordinates, and for each subnet a list of station and channels, coordinates and calibration values. Since all of these variables change relatively infrequently, it is efficient to store them in a .mat file, rather than generate them from parameter/configuration files each time spectrograms are generated.')
disp('There are two ways to generate the subnet and associated station-channel metadata. The first is to use the list of subnets in the setup parameter file, and then use the Antelope master stations database to choose the best station-channels using a channel mask and an exclude file listing bad station-channels. The second is to hand-create a configuration file containing these metadata (default: subnets.d).')
choice = menu('Source for subnet definitions:', 'Generate from setup parameter file', 'Generate from existing (hand-edited) configuration file', 'Quit');
switch choice
	case 1, pf2matfile();
	case 2, configurationfile2matfile();
	case 3, return;
	otherwise return;
end

function pf2matfile()
% PF2MATFILE
% Create a subnets.d and tremor_runtime.mat file from the subnets list in the setup.pf
% 
% The setup.pf file contains (among other things) a subnets table, which defines subnet names, center coordinates, the radius around each subnet to search for stations.
% PF2MATFILE will create a subnets structure containing a list of all scnls within this radius, and metadata associated with each scnl such as latitude, longitude, distance, calibration value, and whether to display it on spectrograms.
% The latter is decided by taking the PARAMS.max_number_scnls closest scnls matching the channel mask PARAMS.channel_mask that are not explicitly excluded in the file exclude_scnl.d
% 

MAX_CHANNELS_TO_FIND = 40;

% Get user verification of filenames
setupfile = dinput('Path of setup parameter file: ', 'pf/setup.pf');
if ~exist(setupfile, 'file')
	error(sprintf('%s does not exist. Please create it first', setupfile));
end
excludefile = dinput('Path of file containing station-channel-network combinations to exclude from spectrograms: ', 'pf/exclude_scnl.d');
if ~exist(excludefile, 'file')
	error(sprintf('%s does not exist. Please create it first', excludefile));
end
subnetsdfile = dinput('Path of Earthworm-style configuration file to create: ', 'pf/subnets.d');
if exist(subnetsdfile, 'file')
	% archive current version of file with a timestamp reflecting last modification date
	filemetadata = dir(subnetsdfile);
    	oldsubnetsdfile = sprintf('%s.%s',subnetsdfile,datestr(filemetadata.datenum, 30));
    	system(sprintf('mv %s %s',subnetsdfile,oldsubnetsdfile));
	warning(sprintf('%s already exists. The current version will be renamed to %s', subnetsdfile, oldsubnetsdfile));
end
matfile = dinput('Path of Matlab workspace (.mat) file to create: ', 'pf/tremor_runtime.mat');
if exist(matfile, 'file')
	% archive current version of file with a timestamp reflecting last modification date
	filemetadata = dir(matfile);
    	oldmatfile = sprintf('%s.%s',matfile,datestr(filemetadata.datenum, 30));
    	system(sprintf('mv %s %s',matfile,oldmatfile));
	warning(sprintf('%s already exists. The current version will be renamed to %s', matfile, oldmatfile));
end

[paths,PARAMS,subnets]=pf2PARAMS(setupfile);
subnetnames = {subnets.name};

disp('The subnets chosen are:');
for c=1:length(subnetnames)
	disp(sprintf('%d: %s',c, subnetnames{c}));
end
choice = dinput('Proceed ?', 'y');
if ~strcmp(choice, 'y')
	disp('Quitting')
	return;
end

% open subnets.d file for writing
fout = fopen(subnetsdfile, 'w');

% Loop over subnets, get scnls matching the pattern within given radius for each scnl, get response vector for each scnl
laststation = 'ZZZZ';
newsubnet_num = 0;
for c=1:length(subnetnames)

    thissubnet = subnets(c);

    % Find up to MAX_CHANNELS_TO_FIND scnls matching the channel mask within radius(km) of subnet latitude/longitude
    thissubnet.stations = getStationsWithinDist(thissubnet.source.longitude, thissubnet.source.latitude, thissubnet.radius, paths.DBMASTER, MAX_CHANNELS_TO_FIND);

    % Add response data (calib only?) for each scnl
    for k=1:length(thissubnet.stations)
	try
        	thissubnet.stations(k).response = response_get_from_db(thissubnet.stations(k).name, thissubnet.stations(k).channel, now, PARAMS.f, paths.DBMASTER);
	catch
        	thissubnet.stations(k).response.calib = NaN;
	end
    end

    % Write out the subnet summary line
    fprintf(fout, 'SUBNET\t%s\t%.4f\t%.4f\t%d\n',thissubnet.name, thissubnet.source.latitude, thissubnet.source.longitude, thissubnet.use);
    fprintf('SUBNET\t%s\t%.4f\t%.4f\t%d\n',thissubnet.name, thissubnet.source.latitude, thissubnet.source.longitude, thissubnet.use);

    % Write out scnl summary lines for this subnet
    totalinuse = 0;
    for k=1:length(thissubnet.stations)

	% If there is no calib value, don't even allow this as an option
       	if isnan(thissubnet.stations(k).response.calib)
		fprintf('No calibration for %s.%s: omitting.\n',thissubnet.stations(k).name, thissubnet.stations(k).channel);
		continue;
	end

	% Should this scnl be used?
        useit=0;
        %if regexp(thissubnet.stations(k).channel, '[BES]HZ')  & (totalinuse < PARAMS.max_number_scnls) & (~excluded_scnl(thissubnet.stations(k).name, thissubnet.stations(k).channel) & ~strcmp(thissubnet.stations(k).name, laststation))
        if regexp(thissubnet.stations(k).channel, PARAMS.channel_mask)  & (totalinuse < PARAMS.max_number_scnls) & (~excluded_scnl(excludefile, thissubnet.stations(k).name, thissubnet.stations(k).channel) & ~strcmp(thissubnet.stations(k).name, laststation))
                useit = 1;
		totalinuse = totalinuse + 1;
		laststation = thissubnet.stations(k).name;
        end

	% Write out scnl summary line for this scnl
        fprintf(fout, 'scn\t%s.%s.%s\t%.4f\t%.4f\t%.2f\t%.4f\t%d\n',thissubnet.stations(k).name, thissubnet.stations(k).channel, get(thissubnet.stations(k).scnl, 'network'), thissubnet.stations(k).latitude, thissubnet.stations(k).longitude, thissubnet.stations(k).elev, thissubnet.stations(k).response.calib, useit);
        fprintf('scn\t%s.%s.%s\t%.4f\t%.4f\t%.2f\t%.4f\t%d\n',thissubnet.stations(k).name, thissubnet.stations(k).channel, get(thissubnet.stations(k).scnl, 'network'), thissubnet.stations(k).latitude, thissubnet.stations(k).longitude, thissubnet.stations(k).elev, thissubnet.stations(k).response.calib, useit);

    end
    fprintf(fout, '\n\n'); % end of subnet
    fprintf('\n\n'); % end of subnet

    % Now we have a successfully fleshed-out metadata for this subnet, let's reset subnets accordingly
    if thissubnet.use
	newsubnet_num = newsubnet_num + 1;
    	newsubnets(newsubnet_num) = thissubnet;
    end
end 

save2mat(matfile, newsubnets, paths, PARAMS);

% update the subnets list for the spectrograms menu
choice = dinput('Update the list of subnets used for the web interface menus? (y/n) ', 'n');
if strcmp(choice, 'y')
	update_web_subnets(subnets, paths);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function configurationfile2matfile();
% reads subnets.d file (which has probably been hand-edited) and write tremor_runtime.mat

% Get user verification of filenames
setupfile = dinput('Path of setup parameter file: ', 'pf/setup.pf');
if ~exist(setupfile, 'file')
	error(sprintf('%s does not exist. Please create it first', setupfile));
end
subnetsdfile = dinput('Path of Earthworm-style configuration file: ', 'pf/subnets.d');
if ~exist(subnetsdfile, 'file')
	error(sprintf('%s does not exist. Please create it first', subnetsdfile));
end
matfile = dinput('Path of Matlab workspace (.mat) file to create: ', 'pf/tremor_runtime.mat');
if exist(matfile, 'file')
	% archive current version of file with a timestamp reflecting last modification date
	filemetadata = dir(matfile);
    	oldmatfile = sprintf('%s.%s',matfile,datestr(filemetadata.datenum, 30));
    	system(sprintf('mv %s %s',matfile,oldmatfile));
	warning(sprintf('%s already exists. The current version will be renamed to %s', matfile, oldmatfile));
end

[paths,PARAMS,subnets]=pf2PARAMS(setupfile);
subnets = [];

fin = fopen(subnetsdfile,'r');
c=0;
usethissubnet = 0;
while 1,
        tline = fgetl(fin);
        if ~ischar(tline),break,end

        if strfind(tline, 'SUBNET')
		fprintf('%s\n', tline);
                fields = regexp(tline, '\t', 'split') ;
        if length(fields)>=5
            usethissubnet = str2num(fields{5});
            if (usethissubnet == 1)
                c = c + 1;
                cc  = 0;
                subnets(c).name = fields{2};
                        subnets(c).source.latitude = str2num(fields{3});
                        subnets(c).source.longitude = str2num(fields{4});
                subnets(c).use = str2num(fields{5});
            end
               	end

        end
        if (usethissubnet==1)
            if strfind(tline, 'scn')
		fprintf('%s\n', tline);
                fields = regexp(tline, '\t', 'split');
                if str2num(fields{7})==1 % use==1
                        cc = cc + 1;
                        scn = fields{2};
                        scnfields = regexp(scn, '\.', 'split');
                        subnets(c).stations(cc).name = scnfields{1};
                        subnets(c).stations(cc).channel = scnfields{2};
                        subnets(c).stations(cc).scnl = scnlobject(scnfields{1}, scnfields{2}, scnfields{3});
                        subnets(c).stations(cc).distance = deg2km(distance(str2num(fields{3}), str2num(fields{4}), subnets(c).source.latitude, subnets(c).source.longitude));
                        subnets(c).stations(cc).latitude = str2num(fields{3});
                        subnets(c).stations(cc).longitude = str2num(fields{4});
                        subnets(c).stations(cc).elev = str2num(fields{5});
                        subnets(c).stations(cc).response.calib = str2num(fields{6});
                end
            end
        end
end
fclose(fin)

save2mat(matfile, subnets, paths, PARAMS);

% update the subnets list for the spectrograms menu
choice = dinput('Update the list of subnets used for the web interface menus? (y/n) ', 'n');
if strcmp(choice, 'y')
	update_web_subnets(subnets, paths);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function save2mat(matfile, subnets, paths, PARAMS)
% write pf/tremor_runtime.mat, preserve current version if it already exists
if exist(matfile, 'file')
    system(sprintf('mv %s %s.%s',matfile,matfile,datestr(now,30)));
end

save(matfile, 'subnets', 'paths', 'PARAMS');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function update_web_subnets(subnets, paths)
subnetnames = {subnets.name};
outfile = sprintf('%s/subnetslist.d',paths.spectrogram_plots);
fprintf('Writing to %s\n',outfile);
fout = fopen(outfile,'w');
for c=1:length(subnetnames)
	fprintf(fout, '%s\n', subnetnames{c});
end
fclose(fout);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function exclude = excluded_scnl(excludefile, sta, chan)
exclude = false;
str = sprintf('%s.%s',sta,chan);
fid = fopen(excludefile);
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [paths,PARAMS,subnets]=pf2PARAMS(setupfile);
% [paths,PARAMS,subnets]=pf2PARAMS(setupfile)

% create pointer to main parameter file
[dirname, filename, ext] = fileparts(setupfile);
if exist(setupfile, 'file')
    setuppf = dbpf(sprintf('%s/%s',dirname,filename));

    % subnets
    subnet_tbl = pfget_tbl(setuppf, 'subnets');
    for c=1:numel(subnet_tbl)
	fields = regexp(subnet_tbl{c}, '\s+', 'split');
	subnets(c).name = fields{1};
	subnets(c).source.latitude = str2double(fields{2});
	subnets(c).source.longitude = str2double(fields{3});
	subnets(c).radius = str2double(fields{4});
	subnets(c).use = str2double(fields{5});
    end

    % Maximum number of scnls to display in a spectrogram
    PARAMS.max_number_scnls = pfget_num(setuppf, 'max_number_scnls');
    
    % Select channels to use according to this channel mask
    PARAMS.channel_mask = pfget(setuppf, 'channel_mask');
    
    % paths (removed from setup.pf file 2013/04/22)
    %paths.DBMASTER = pfget(setuppf,'DBMASTER');
    paths.DBMASTER = getenv('SITE_DB');
    %paths.PFS = pfget(setuppf,'PFS');
    paths.PFS = 'pf';
    %paths.ONEMINDATA = pfget(setuppf,'ONEMINDATA');
    paths.ONEMINDATA = getenv('ONEMINDATA');
    %paths.WEBDIR = pfget(setuppf,'WEBDIR'); 
    paths.WEBDIR = sprintf('%s/TreMoR',getenv('INTERNALWEBPRODUCTS')); 
    %paths.spectrograms = pfget(setuppf,'spectrograms'); 
    paths.spectrogram_plots = 'plots'; 

    % datasource
    datasources = pfget_tbl(setuppf, 'datasources');
    for c=1:numel(datasources)
	fields = regexp(datasources{c}, '\s+', 'split');
	PARAMS.datasource(c).type = fields{1};
	PARAMS.datasource(c).path = fields{2};
	if numel(fields)>2
		PARAMS.datasource(c).port = fields{3};
	end
    end

    % archive_datasource
    PARAMS.switch_to_archive_after_days = pfget(setuppf, 'switch_to_archive_after_days'); 
    archive_datasources = pfget_tbl(setuppf, 'archive_datasources');
    for c=1:numel(archive_datasources)
	fields = regexp(archive_datasources{c}, '\s+', 'split');
	PARAMS.archive_datasource(c).type = fields{1};
	PARAMS.archive_datasource(c).path = fields{2};
	if numel(fields)>2
		PARAMS.archive_datasource(c).port = fields{3};
	end
    end
    % waveform processing
	lowcut	 = pfget_num(setuppf,'lowcut');
	highcut	 = pfget_num(setuppf,'highcut');
	npoles	 = pfget_num(setuppf,'npoles');
    PARAMS.filterObj = filterobject('b',[lowcut highcut],npoles);
    
    % Spectrograms
	PARAMS.spectralobject = spectralobject( ...
		pfget_num(setuppf,'nfft'), ...
		pfget_num(setuppf,'overlap'), ...
		pfget_num(setuppf,'max_freq'), ...
		[ pfget_num(setuppf,'blue') pfget_num(setuppf,'red')] ...
	);

    % Derived data
	PARAMS.surfaceWaveSpeed = pfget_num(setuppf,'surfaceWaveSpeed');
	PARAMS.df        = pfget_num(setuppf, 'df');
    	PARAMS.f        = 0:PARAMS.df:50;
    
 	% Alarm system
	PARAMS.triggersForAlarmFraction = pfget_num(setuppf,'triggersForAlarmFraction');

	debug.print_debug('PARAMS setup OK',1)
else
	error(sprintf('%s: parameter file %s.pf does not exist',mfilename, setupfile));
end

