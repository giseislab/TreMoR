function tremor_wrapper(waveformdir)
global paths PARAMS
printfunctionstack('>');
%print_debug(sprintf('> %s at %s',mfilename, datestr(utnow,31)),1)
load pf/tremor_runtime.mat
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
	w = waveform_fillempty(w, snum, enum); % alternative is the waveform_nonempty function, which eliminates empty waveform objects, rather than replacing them with waveform objects containing zeros. Both eliminate waveform objects of length 1 - these corrupt waveform objects cause masaive problems - no idea where they coome from 
	for c=1:numel(w)
		w(c) = detrend(fillgaps(w(c),mean(w(c))));
        	if strcmp(get(w(c),'Units'), 'Counts')
                	resp = get(w(c), 'response');
                        print_debug(sprintf('Applying calib of %d for %s.%s',resp.calib, get(w(c),'station'), get(w(c), 'channel')), 1);
                        if (resp.calib ~= 0)
                                w(c) = w(c) * resp.calib;
                                %w(c) = set(w(c), 'units', resp.units);
                                w(c) = set(w(c), 'units', 'nm / sec');
                        end
                end
		if strfind(get(w(c), 'channel'),'BH')
			try
	                        print_debug(sprintf('Applying high pass filter to %s.%s', get(w(c),'station'), get(w(c), 'channel')), 1);
				w(c) = filtfilt(highpassfilterobject, w(c));
			catch
	                        print_debug(sprintf('Filter failed'), 1);
			end
		end
	end

	logbenchmark('preparing spectrogram waveforms', toc);
	disp(sprintf('%s %s: preparing spectrogram waveforms (%.1f s)', mfilename, datestr(utnow), toc));
	
	%%%%%%%%%%%% COMPUTE / PLOT SPECTROGRAMS %%%%%%%%%%%		
	tic;
	tenminspfile = getSgram10minName(subnet, enum);
	%specgram3(w, sprintf('%s %s - %s UTC', subnet, datestr(snum,31), datestr(enum,13)), PARAMS.spectralobject , 0.75);
	specgram3(w, '', PARAMS.spectralobject , 0.75);
	logbenchmark('computing & plotting spectrograms', toc);
	disp(sprintf('%s %s: computing & plotting spectrograms (%.1f s)', mfilename, datestr(utnow), toc));

	%%%%%%%%%%%% SAVE TO IMAGE FILE AND CREATE THUMBNAIL %%%%%%%%%%%
	orient tall;
	tic;
	if saveImageFile(tenminspfile, 72)

		fileinfo = dir(tenminspfile);
		print_debug(sprintf('%s %s: spectrogram PNG size is %d',mfilename, datestr(utnow), fileinfo.bytes),0);	

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
		[bname, dname, bnameroot, bnameext] = basename(tenminspfile);
		fsound = fopen(sprintf('%s/%s.sound',dname,bnameroot),'a');
		for c=1:length(w)
			soundfilename = catpath(dname, sprintf('%s_%s_%s.wav',bnameroot, get(w(c),'station'), get(w(c), 'channel')  ) );
			fprintf(fsound,'%s\n', soundfilename);  
			print_debug(sprintf('Writing to %s',soundfilename),0); 
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
	            	        		print_debug(sprintf('SAM object for %s is blank',measure),2);
	       			    	else
	                    			print_debug(sprintf('Calling save2bob for %s', measure),3);
	                    			try
	                       				save2bob(s.station, s.channel, s.dnum, s.data, measure);
			               		catch
							disp(sprintf('save2bob failed for %s-%s',s.station, s.channel));
	                	  		end
			        	end
	       		 	else
	      				print_debug(sprintf('measure %s not found',measure),2);
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
printfunctionstack('<');








