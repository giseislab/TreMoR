function tremor_wrapper(waveformdir, matfile)
global paths PARAMS
debug.printfunctionstack('>');
%print_debug(sprintf('> %s at %s',mfilename, datestr(utnow,31)),1)
if exist(matfile, 'file')
    feval('load',matfile);
else
    disp('matfile not found')
    return
end
highpassfilterobject = filterobject('h', 0.5, 2);
makeSamFiles = false;
makeSoundFiles = false; 
while 1,

	% PREP
	tic;
	[w, filename, snum, enum, subnet] = loadnextwaveformmat(waveformdir);
	diaryname = getSgramDiaryName(subnet, enum);
	diary(diaryname);
	disp(sprintf('%s %s: Started',mfilename,datestr(utnow)));
	if isempty(w)
		empty_waveform_object(w);
		continue;
	end
	logbenchmark('loading next waveform and doing prep', toc);
	disp(sprintf('%s %s: loading next waveform and doing prep (%.1f s)', mfilename, datestr(utnow), toc));
        
	%%%%%%%%%%%%%%% ADD RESPONSE FROM SUBNETS TO WAVEFORM OBJECTS %%%%%%%%%
       	% Add response structures to waveform objects
	tic;
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
	logbenchmark('adding response structures to waveform objects', toc);
	disp(sprintf('%s %s: adding response structures to waveform objects (%.1f s)', mfilename, datestr(utnow), toc));

	%%%%%%%%%%%%%% PREPARE SPECTROGRAM WAVEFORM OBJECTS %%%%%%%%%%%%%%%%
      	% For spectrogram waveforms, remove calib only. Also high pass filter broadband channels.
	tic;
	%w = waveform_fillempty(w, snum, enum); % alternative is the waveform_nonempty function, which eliminates empty waveform objects, rather than replacing them with waveform objects containing zeros. Both eliminate waveform objects of length 1 - these corrupt waveform objects cause masaive problems - no idea where they coome from 
	w = waveform_nonempty(w); 
	if isempty(w)
		empty_waveform_object(w);
		continue;
	end
	for c=1:numel(w)
		w(c) = detrend(fillgaps(w(c),mean(w(c))));
        	if strcmp(get(w(c),'Units'), 'Counts')
                	resp = get(w(c), 'response');
                        debug.print_debug(sprintf('Applying calib of %d for %s.%s',resp.calib, get(w(c),'station'), get(w(c), 'channel')), 1);
                        if (resp.calib ~= 0)
                                w(c) = w(c) * resp.calib;
                                %w(c) = set(w(c), 'units', resp.units);
                                w(c) = set(w(c), 'units', 'nm / sec');
                        end
                end
		if strfind(get(w(c), 'channel'),'BH')
			try
	                        debug.print_debug(sprintf('Applying high pass filter to %s.%s', get(w(c),'station'), get(w(c), 'channel')), 1);
				w(c) = filtfilt(highpassfilterobject, w(c));
			catch
	                        debug.print_debug(sprintf('Filter failed'), 1);
			end
		end
	end

	logbenchmark('preparing spectrogram waveforms', toc);
	disp(sprintf('%s %s: preparing spectrogram waveforms (%.1f s)', mfilename, datestr(utnow), toc));
	
	%%%%%%%%%%%% COMPUTE / PLOT SPECTROGRAMS %%%%%%%%%%%		
	tic;
	tenminspfile = getSgram10minName(subnet, enum);
	%specgram3(w, sprintf('%s %s - %s UTC', subnet, datestr(snum,31), datestr(enum,13)), PARAMS.spectralobject , 0.75);
	specgram3(PARAMS.spectralobject, w, 0.75);
	logbenchmark('computing & plotting spectrograms', toc);
	disp(sprintf('%s %s: computing & plotting spectrograms (%.1f s)', mfilename, datestr(utnow), toc));

	%%%%%%%%%%%% SAVE TO IMAGE FILE AND CREATE THUMBNAIL %%%%%%%%%%%
	orient tall;
	tic;
	if saveImageFile(tenminspfile, 72)

		fileinfo = dir(tenminspfile);
		debug.print_debug(sprintf('%s %s: spectrogram PNG size is %d',mfilename, datestr(utnow), fileinfo.bytes),0);	

		% make thumbnails
		makespectrogramthumbnails(tenminspfile);

		try
			system('touch spectrograms/lastspectrogram.png');
		end
		logbenchmark('saving spectrogram images', toc);
		disp(sprintf('%s %s: saving spectrogram images (%.1f s)', mfilename, datestr(utnow), toc));
	end


	%%%%%%%%%%%%%%%% SOUND FILES %%%%%%%%%%%%%%
	if makeSoundFiles
		tic;
		% 20120221 Added a "sound file" like 201202211259.sound which simply records order of stachans in waveform object so
		% php script can match spectrogram panel with appropriate wav file 
		% 20121101 GTHO COmment: Could replace use of bnameroot below with strrep, since it is just used to change file extensions
		% e.g. strrep(tenminspfile, '.png', sprintf('_%s_%s.wav', sta, chan)) 
		[bname, dname, bnameroot, bnameext] = matlab_extensions.basename(tenminspfile);
		fsound = fopen(sprintf('%s%s%s.sound', dname, filesep, bnameroot),'a');
		for c=1:length(w)
			soundfilename = catpath(dname, sprintf('%s_%s_%s.wav',bnameroot, get(w(c),'station'), get(w(c), 'channel')  ) );
			fprintf(fsound,'%s\n', soundfilename);  
			debug.print_debug(sprintf('Writing to %s',soundfilename),0); 
			data = get(w(c),'data');
			m = max(data);
			if m == 0
				m = 1;
			end 
			data = data / m;
			wavwrite(data, get(w(c), 'freq') * 120, soundfilename);
		end
		fclose(fsound);
		logbenchmark('making sound files', toc);
		disp(sprintf('%s %s: saving sound files (%.1f s)', mfilename, datestr(utnow), toc));
	end

	%%%%%%%%%%%%%%%% COMPUTE SAM DATA %%%%%%%%%%%%%%
	if makeSamFiles
		tic;
		w = waveform_nonempty(w); % eliminate empty and corrupt waveform objects
	      	w = waveform_clean(w, 'filter_waveforms', false, 'filterObj', PARAMS.filterObj, 'remove_spikes', 'false', 'remove_trend', 'true', 'remove_response', 'false'); % cannot remove full instrument response as Mike's response_apply is broken. But calib is used.
		% Calculate and save true ground motion data (at the
		% seismometer) to file (no reduced measurements)
		try
	    		stats = waveform2stats(w, 1/60);  
	    		%stats = waveform2f(w);
		catch	
			disp('waveform2stats failed');
		end
	
	    	for c = 1:length(stats)
	    		samcollection = stats(c);
	     	 	%measurements = {'Vmax';'Vmedian';'Vmean';'Dmax';'Dmedian';'Dmean';'Drms';'Energy';'peakf';'meanf'};
	       		measurements = {'Vmax';'Vmedian';'Vmean';'Dmax';'Dmedian';'Dmean';'Drms';'Energy';'peakf';'meanf'};
	        	for m = 1:length(measurements)
	            		measure = measurements{m};	 
	            		if isfield(samcollection, measure)
	                		eval(sprintf('s = samcollection.%s;',measure));
	   		        	if isempty(s)
	            	        		debug.print_debug(sprintf('SAM object for %s is blank',measure),2);
	       			    	else
	                    			debug.print_debug(sprintf('Calling save2bob for %s', measure),3);
	                    			try
	                       				save2bob(s.station, s.channel, s.dnum, s.data, measure);
			               		catch
							disp(sprintf('save2bob failed for %s-%s',s.station, s.channel));
	                	  		end
			        	end
	       		 	else
	      				debug.print_debug(sprintf('measure %s not found',measure),2);
	       	    		end
	       		end
	    	end

		disp('*** SAM FILES SUCCEEDED ***');
		logbenchmark('making SAM files', toc);
	end
	%%%%%%%%%%%%%%%%%%%%%% CLEAN UP %%%%%%%%%%%%%
	disp(sprintf('%s %s: Finished',mfilename,datestr(utnow)));
	diary off
	clear w
	
	% Pause briefly
	pause(5);
end    

%print_debug(sprintf('< %s at %s',mfilename, datestr(now,31)),1)
debug.printfunctionstack('<');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function w = waveform_fillempty(w, snum, enum);
dl = get(w, 'data_length');
% data length is either 30000 (50Hz), 60000 (100Hz), 0 (blank waveform object) or 1 (corrupt waveform object)
idxgood = find(dl~=1);
w = w(idxgood);
idxempty = find(dl==0);
idxfull = find(dl>1);
data = zeros(max(dl), 1);
if ~exist('snum','var')
	[wsnum, wenum]=gettimerange(w(idxfull));
	snum = min(wsnum);
end

for c=1:length(idxempty)
	i = idxempty(c);
	w(i) = set(w(i), 'data', data, 'freq', 100, 'start', snum);
end


function w2 = waveform_nonempty(w);
e = 1;
for c=1:length(w)
	nsamp = get(w(c), 'data_length');
	if nsamp > 1 % 0 means blank waveform object, 1 means corrupt waveform object 
		w2(e) = w(c);
		e = e + 1;
	end
end 
if e==1
	w2 = [];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function stats = waveform2stats(w, newFs)
stats=[];
for c=1:length(w)
    oldFs = get(w(c), 'freq');
    cf = round(oldFs / newFs);
    if strcmp(get(w(c), 'units'), 'nm / sec')
        stats(c).Vmax = makestat(w(c), 'absmax', cf);
        stats(c).Vmedian = makestat(w(c), 'absmedian', cf);
        stats(c).Vmean = makestat(w(c), 'absmean', cf);
        %e = energy(s); 
        %stats.Energy = e.resample('absmean', cf);, 
        w(c) = integrate(w(c));
    end

    if strcmp(get(w(c), 'units'), 'nm')
        stats(c).Dmax = makestat(w(c), 'absmax', cf);
        stats(c).Dmedian = makestat(w(c), 'absmedian', cf);
        stats(c).Dmean = makestat(w(c),'absmean', cf);
        stats(c).Drms = makestat(w(c), 'rms', cf);
    end
end

function s=makestat(w, method, cf)
	try % rare error in waveform/resample
        	wr = resample(w, method, cf);
        	s = waveform2sam(wr);
        	s.measure = method;
	catch
		s = [];
	end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function stats = waveform2f(w)
w = waveform_addsgram(w);
for c=1:length(w)
    sgram = get(w(c), 'sgram');
    if isstruct(sgram)
        % downsample sgram data to 1 minute bins
        [Smax,i] = max(sgram.S);
        peakf = sgram.F(i);
        meanf = (sgram.F' * sgram.S)./sum(sgram.S);
        dnum = unique(floorminute(sgram.T/86400));
        for k=1:length(dnum)
            p = find(floorminute(sgram.T) == dnum(k));
            stats(c).peakf(k) = nanmean(peakf(p));
            stats(c).meanf(k) = nanmean(meanf(p));       
        end
    else
        sgram
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [w, tmpfile, snum, enum, subnet] = loadnextwaveformmat(matdir)
global paths PARAMS
found = false;
firsttime = 1;

while ~found
	d = dir(sprintf('%s/*.mat',matdir));
	if length(d)>0
		%filename = sprintf('%s/%s',matdir,d(1).name);

		% sort file times
		[dummy, i] = sort([d.datenum]);

		% get the most recently written MAT file
		filename = sprintf('%s/%s',matdir,d(i(end)).name); 
		filesize = d(i(end)).bytes;
		disp(sprintf('\n** %s: size %d bytes',filename,filesize));
		diaryname = waveformfilename2diaryname(filename);
		diary(diaryname);
		%disp('> loadnextwaveformmat');
		debug.printfunctionstack('>');
		disp(sprintf('%s %s: Started', mfilename, datestr(utnow)));
		disp(sprintf('%s %s: Size of %s is %d bytes', mfilename, datestr(utnow), filename, filesize));

		% also list the size of the ten inute spectrogram file - will be zero  bytes unless this timewindow was previously processed
		tenminspfile = waveformfilename2sgram10minname(filename);
		tenminspfileptr = [];
		if exist(tenminspfile, 'file')
			tenminspfileptr = dir(tenminspfile);
			disp(sprintf('%s %s: Size of %s is %d bytes', mfilename, datestr(utnow), tenminspfileptr(1).name, tenminspfileptr(1).bytes));
		end

		% delete the waveform MAT file it if too small
		if (filesize < 20000), % was 76000, but then had some Katmai data with 46000 bytes - mostly dead channels
			disp(sprintf('%s %s: Waveform.mat file is too small - deleting', mfilename, datestr(utnow)));
			delete(filename);
			% need to delete zero length spectrogram file too - else this ten minutes will never be filled in 
			if numel(tenminspfileptr)==1
				if (tenminspfileptr(1).bytes < 100)
					disp(sprintf('%s %s: 10 minute spectrogram png is too small - deleting', mfilename, datestr(utnow)));
					delete(tenminspfile);
				end
			end
			disp(sprintf('%s %s: tremor_wrapper will not run for this timewindow', mfilename, datestr(utnow)));
			%disp('< loadnextwaveformmat');
			debug.printfunctionstack('<');
			diary off;
			continue;
		end

		% select the most recent file
		

		% sometimes loading a file generates a segmentation fault, which cannot be caught.
		% a potential hack is to move the waveform file to an alternate location before loading it.
		% then if a seg fault results, the file is lost and will never be loaded again. 
		% so providing the next file is ok, TreMoR should restart rtrun_matlab and continue.
		tmpdir = sprintf('%s/tmp',matdir);
		if ~exist(tmpdir,'dir')
			mkdir(tmpdir);
		end

		pause(2); % pause just to give time for file to be saved properly

		% move MAT file to tmp directory
		tmpfile = sprintf('%s/%s',tmpdir,d(i(end)).name);
		cmd = sprintf('mv %s %s',filename,tmpfile);
		disp(cmd);
		system(cmd);

		disp(sprintf('** Loading...'));
		try
	                cmd = sprintf('load %s',tmpfile);
       	         	disp(cmd);
                	eval(cmd);

           		% Sanity checks
               		errorFound=false;
			if exist('w', 'var')
               			if ~strcmp(class(w),'waveform')
               		        	errorFound=true;
					disp('w is not a waveform object')
               			end
			else
               	        	errorFound=true;
				disp('w not found')
			end
		
			if exist('snum', 'var')
               			if ~(snum>datenum(1989,1,1) && snum<utnow)
               		        	errorFound=true;
					disp('snum out of range')
               			end
			else
               	        	errorFound=true;
				disp('snum not found')
			end

			if exist('enum', 'var')
               			if ~(enum>datenum(1989,1,1) && enum<utnow)
               		        	errorFound=true;
					disp('enum out of range')
               			end
			else
               	        	errorFound=true;
				disp('enum not found')
			end

			if exist('subnet', 'var')
               			if length(subnet)==0
               		        	errorFound=true;
					disp('subnet has zero length')
               			end
			else
               	       		errorFound=true;
				disp('subnet not found')
			end
		catch
			errorFound = true;
		end

                if ~errorFound
			found = true;
			disp('*** file looks good - all variables validate');
			summariseWaveformMat(filename, snum, enum, subnet);
			delete(tmpfile);
		else
			disp('*** file looks bad - skipping');
			% need to delete zero length spectrogram file too - else this ten minutes will never be filled in 
			if numel(tenminspfileptr)==1
				if (tenminspfileptr(1).bytes < 100)
					disp(sprintf('%s %s: 10 minute spectrogram png is too small - deleting', mfilename, datestr(utnow)));
					delete(tenminspfile);
				end
			end
			delete(tmpfile);
			% in this case, found==false and waveform file has been blown away, so function should just load next one
		end
		debug.printfunctionstack('<');
		diary off;

        else
        	if firsttime
                	fprintf('%s: Waiting for new waveformmat file.',mfilename);
                	firsttime = 0;
            	end    
		pause(1);
		fprintf('.');
	end
end
fprintf('\n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function summariseWaveformMat(filename, snum, enum, subnet)
debug.printfunctionstack('>');
disp(sprintf('** waveform loaded **'));
%fprintf('file=%s\n',filename);
disp(sprintf('Start time is %s UTC',datestr(snum)));
disp(sprintf('End time is %s UTC',datestr(enum)));
debug.printfunctionstack('<');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function diaryname = waveformfilename2diaryname(waveformMat)
debug.printfunctionstack('>');
fields = regexp(matlab_extensions.basename(waveformMat), '_', 'split');
datestring = fields{2};
yyyy = datestring(1:4);
mm = datestring(5:6);
dd = datestring(7:8);
hr = datestring(10:11);
mi = datestring(12:13);
ss = datestring(14:15);
enum = datenum(sprintf('%s/%s/%s %s:%s:%s', yyyy, mm, dd, hr, mi, ss));
diaryname = getSgramDiaryName(fields{1}, enum);
debug.printfunctionstack('<');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function tenminspfile = waveformfilename2sgram10minname(waveformMat)
debug.printfunctionstack('>');
fields = regexp(matlab_extensions.basename(waveformMat), '_', 'split');
datestring = fields{2};
yyyy = datestring(1:4);
mm = datestring(5:6);
dd = datestring(7:8);
hr = datestring(10:11);
mi = datestring(12:13);
ss = datestring(14:15);
enum = datenum(sprintf('%s/%s/%s %s:%s:%s', yyyy, mm, dd, hr, mi, ss));
tenminspfile = getSgram10minName(fields{1}, enum);
debug.printfunctionstack('<');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function empty_waveform_object(w)
disp(sprintf('%s %s: Waveform object is empty - no data to process',mfilename,datestr(utnow)));
