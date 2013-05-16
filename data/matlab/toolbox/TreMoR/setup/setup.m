function setup(varargin)
[runmode] = matlab_extensions.process_options(varargin, 'runmode', 'manual');
if strcmp(runmode, 'manual')
	disp('Use this function to generate a MATLAB workspace for running the spectrograms from an Antelope-style parameter file (default: setup.pf). The MATLAB workspace, stored in a matfile, will contain a structures describing filesystem paths, spectrogram parameters, and a list of subnets and their coordinates, and for each subnet a list of station and channels, coordinates and calibration values. Since all of these variables change relatively infrequently, it is efficient to store them in a .mat file, rather than generate them from parameter/configuration files each time spectrograms are generated.')
	disp('There are two ways to generate the subnet and associated station-channel metadata. The first is to use the list of subnets in the setup parameter file, and then use the Antelope master stations database to choose the best station-channels using a channel mask and an exclude file listing bad station-channels. The second is to hand-create a configuration file containing these metadata (default: subnets.d).')
	choice = menu('Source for subnet definitions:', 'Generate from setup parameter file', 'Generate from existing (hand-edited) configuration file', 'Quit');
	switch choice
		case 1, pf2matfile();
		case 2, configurationfile2matfile();
		case 3, return;
		otherwise return;
	end
else
	if strcmp(runmode, 'auto')
		pf2matfile('runmode','auto');
	end
end

function pf2matfile(varargin)
% PF2MATFILE
% Create a subnets.d and tremor_runtime.mat file from the subnets list in the setup.pf
% 
% The setup.pf file contains (among other things) a subnets table, which defines subnet names, center coordinates, the radius around each subnet to search for stations.
% PF2MATFILE will create a subnets structure containing a list of all scnls within this radius, and metadata associated with each scnl such as latitude, longitude, distance, calibration value, and whether to display it on spectrograms.
% The latter is decided by taking the PARAMS.max_number_scnls closest scnls matching the channel mask PARAMS.channel_mask that are not explicitly excluded in the file exclude_scnl.d
% 

MAX_CHANNELS_TO_FIND = 40;

[runmode, setupfile, excludefile, subnetsdfile, matfile] = matlab_extensions.process_options(varargin, 'runmode', 'manual', 'setupfile', 'pf/setup.pf', 'excludefile', 'pf/exclude_scnl.d', 'subnetsdfile', 'pf/subnets.d', 'matfile', 'pf/tremor_runtime.mat');
if strcmp(runmode, 'manual')
	% Get user verification of filenames
	setupfile = dinput('Path of setup parameter file: ', setupfile);
	excludefile = dinput('Path of file containing station-channel-network combinations to exclude from spectrograms: ', excludefile);
	subnetsdfile = dinput('Path of Earthworm-style configuration file to create: ', subnetsdfile);
	matfile = dinput('Path of Matlab workspace (.mat) file to create: ', matfile);
end
if ~exist(setupfile, 'file')
	error(sprintf('%s does not exist. Please create it first', setupfile));
end

if ~exist(excludefile, 'file')
	error(sprintf('%s does not exist. Please create it first', excludefile));
end

if exist(subnetsdfile, 'file')
	% archive current version of file with a timestamp reflecting last modification date
	filemetadata = dir(subnetsdfile);
    	oldsubnetsdfile = sprintf('%s.%s',subnetsdfile,datestr(filemetadata.datenum, 30));
    	system(sprintf('mv %s %s',subnetsdfile,oldsubnetsdfile));
	warning(sprintf('%s already exists. The current version will be renamed to %s', subnetsdfile, oldsubnetsdfile));
end

if exist(matfile, 'file')
	% archive current version of file with a timestamp reflecting last modification date
	filemetadata = dir(matfile);
    	oldmatfile = sprintf('%s.%s',matfile,datestr(filemetadata.datenum, 30));
    	system(sprintf('mv %s %s',matfile,oldmatfile));
	warning(sprintf('%s already exists. The current version will be renamed to %s', matfile, oldmatfile));
end

[paths,PARAMS,subnets]=pf2PARAMS(setupfile);
for c=1:numel(PARAMS.datasource)
        if strcmp(PARAMS.datasource(c).type, 'antelope')
                gismo_datasource(c) = datasource(PARAMS.datasource(c).type, PARAMS.datasource(c).path);
        else
                gismo_datasource(c) = datasource(PARAMS.datasource(c).type, PARAMS.datasource(c).path, str2num(PARAMS.datasource(c).port));
        end
end

subnetnames = {subnets.name};

disp('The subnets chosen are:');
for c=1:length(subnetnames)
	disp(sprintf('%d: %s',c, subnetnames{c}));
end

if strcmp(runmode, 'manual')
	choice = dinput('Proceed ?', 'y');
	if ~strcmp(choice, 'y')
		disp('Quitting')
		return;
	end
end

% open subnets.d file for writing
fout = fopen(subnetsdfile, 'w');

% Loop over subnets, get scnls matching the pattern within given radius for each scnl, get response vector for each scnl
laststation = 'ZZZZ';
newsubnet_num = 0;
for c=1:length(subnetnames)
    clear thissubnet;
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



    % See which stations are good
    clear outstr;
    clear percentagegot;
    clear priority;
    clear newstations;
    clear use;
    for k=1:length(thissubnet.stations)

        fprintf('Processing %s.%s.%s\n',thissubnet.stations(k).name, thissubnet.stations(k).channel, get(thissubnet.stations(k).scnl, 'network'));
	% If there is no calib value, don't even allow this as an option
       	if isnan(thissubnet.stations(k).response.calib) || (thissubnet.stations(k).response.calib <=0.0)
		outstr{k} = '#nocalib';
	end

	% If there are no waveform data within past 24 hours, don't even allow as an option
	snum = utnow-1.1;
	enum = utnow-0.1;
	w = waveform_wrapper(thissubnet.stations(k).scnl, snum, enum, gismo_datasource);
	if isempty(w)
		percentagegot(k)=0.0;
		outstr{k} = '#fail';
	else
		percentagegot(k) = waveform_soh(w, snum, enum);
		if (percentagegot(k) == 0.0)
			outstr{k} = '#nodata';
		else
			outstr{k} = 'scn';
		end
	end

	% compute priority based on channel type, distance, and percentage of good data retrieved
	switch thissubnet.stations(k).channel
		case 'BHZ', priority(k) = 4;
		case {'EHZ', 'SHZ'}, priority(k) = 3;
		case {'BHN', 'BHE'}, priority(k) = 2;
		case {'EHN', 'EHE', 'SHN', 'SHE', 'BDF'}, priority(k) = 1;
		otherwise, priority(k) = 0;
	end
	priority(k) = percentagegot(k) * (priority(k) + (25.0 / thissubnet.stations(k).distance));
	use(k) = 0;
     end

   % Decide which scn's to use based on 8 highest priority values, but without repeating a station
   % make a copy that can be modified
   clear pc;
   pc = priority;
   totalinuse = 0;
   maxpc = 1;
   while (maxpc > 0 && totalinuse < min([PARAMS.max_number_scnls length(thissubnet.stations)])),
	% find the biggest priority
        [maxpc, index] = max(pc);
	if (maxpc <= 0)
		continue;
	end

	% switch it on for use if not excluded
	if (~excluded_scnl(excludefile, thissubnet.stations(k).name, thissubnet.stations(k).channel))
		use(index) =  1;
		totalinuse = totalinuse + 1;
		newstations(totalinuse) = thissubnet.stations(index);
		pc(index) = -999.0;
	else
		outstr{index} = strcat(outstr{index}, 'X');
	end

	% disallow any other channels for this station by setting pc to -ve
	thissta = thissubnet.stations(index).name;
	for k=1:length(thissubnet.stations)
		thisothersta = thissubnet.stations(k).name;
		if strcmp(thissta, thisothersta)
			pc(k) = 0.0;
		end
	end
   end

    % Exclude subnet with no stations, otherwise get a crash 8 lines below
    if (totalinuse == 0)
	thissubnet.use = 0;
    end

    % Now we have a successfully fleshed-out metadata for this subnet, let's reset subnets accordingly
    if thissubnet.use
	newsubnet_num = newsubnet_num + 1;
    	newsubnets(newsubnet_num) = thissubnet;
	newsubnets(newsubnet_num).stations = newstations;
    end

    % Write out the subnet summary line
    fprintf(fout, 'SUBNET\t%s\t%.4f\t%.4f\t%d\n',thissubnet.name, thissubnet.source.latitude, thissubnet.source.longitude, thissubnet.use);
    fprintf('SUBNET\t%s\t%.4f\t%.4f\t%d\n',thissubnet.name, thissubnet.source.latitude, thissubnet.source.longitude, thissubnet.use);
  
   % Write out scnl summary lines for this subnet
   for k=1:length(thissubnet.stations)
        fprintf(fout, '%s\t%s.%s.%s\t%.4f\t%.4f\t%.2f\t%.1f\t%.0f\t%.4f\t%d\n',outstr{k}, thissubnet.stations(k).name, thissubnet.stations(k).channel, get(thissubnet.stations(k).scnl, 'network'), thissubnet.stations(k).latitude, thissubnet.stations(k).longitude, thissubnet.stations(k).elev, thissubnet.stations(k).distance, priority(k), thissubnet.stations(k).response.calib, use(k));
   end

    fprintf(fout, '\n\n'); % end of subnet

end 

save2mat(matfile, newsubnets, paths, PARAMS);

% update the subnets list for the spectrograms menu
%choice = dinput('Update the list of subnets used for the web interface menus? (y/n) ', 'n');
%if strcmp(choice, 'y')
	update_web_subnets(newsubnets, paths);
%end
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
                if str2num(fields{9})==1 % use==1
                        cc = cc + 1;
                        scn = fields{2};
                        scnfields = regexp(scn, '\.', 'split');
                        subnets(c).stations(cc).name = scnfields{1};
                        subnets(c).stations(cc).channel = scnfields{2};
                        subnets(c).stations(cc).scnl = scnlobject(scnfields{1}, scnfields{2}, scnfields{3});
                        %subnets(c).stations(cc).distance = deg2km(distance(str2num(fields{3}), str2num(fields{4}), subnets(c).source.latitude, subnets(c).source.longitude));

                        subnets(c).stations(cc).latitude = str2num(fields{3});
                        subnets(c).stations(cc).longitude = str2num(fields{4});
                        subnets(c).stations(cc).elev = str2num(fields{5});
                        subnets(c).stations(cc).distance = str2num(fields{6});
                        subnets(c).stations(cc).priority = str2num(fields{7});
                        subnets(c).stations(cc).response.calib = str2num(fields{8});
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
    paths.DBMASTER = getenv('SITE_DB');
    if isempty(paths.DBMASTER)
	disp('You must run setup from rtrun, e.g.\n\trtrun matlab -r setup')
	exit();
    end
    paths.PFS = 'pf';
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

