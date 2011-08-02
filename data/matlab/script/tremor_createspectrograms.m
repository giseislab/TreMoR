function tremor_createspectrograms(varargin)
global paths PARAMS
print_debug(sprintf('> %s at %s',mfilename, datestr(now,31)),1)
load pf/runtime

while 1,
	[w, filename, snum, enum, subnet] = loadnextwaveformmat('waveforms_sgram');
	
	% Remove waveforms MAT file here so can have multiple jobs running  without  them processing the same waveform file
	delete(filename);

	% Sanity checks
	if ~strcmp(class(w),'waveform')
		return;
	end
	if ~(snum>datenum(1989,1,1) && snum<utnow) 
		return;
	end
	if ~(enum>datenum(1989,1,1) && enum<utnow) 
		return;
	end
	if length(subnet)==0 
		return;
	end

	% Output some information
	disp(sprintf('\n***** New waveform *****'));
	print_debug(filename, 1);
	disp(sprintf('Start time is %s UTC',datestr(snum)));
	disp(sprintf('End time is %s UTC',datestr(enum)));
	timestamp = datestr(enum, 30);
        
	% Create 10 minute spectrogram plots
	spdir = catpath(paths.WEBDIR, 'plots', 'sp', subnet, timestamp(1:4), timestamp(5:6), timestamp(7:8));
	tenminspfile = catpath(spdir, [timestamp, '.png']);
	disp(sprintf('Creating spectrogram, file will go to %s',tenminspfile));
	specgram3(w, sprintf('%s %s - %s UTC', subnet, datestr(snum,31), datestr(enum,13)), PARAMS.spectralobject , 0.75);

	% add colorbar
	%if (PARAMS.colorbar == 1) % this does not exist as a parameter currently            
		%addColorbar(get(PARAMS.spectralobject,'dblims')); % this function no longer exists!
	%end

	% save image file
	orient tall;
	if saveImageFile(tenminspfile, 50)
		%close;
				
		% Create a thumbnail spectrogram
		spthumbfile = catpath(spdir, ['small_', timestamp, '.png']);
		%makeThumbnail(spthumbfile, timestamp);
    		makesgramthumbnail(tenminspfile);
	end

	% Pause briefly
	pause(1);
end    

print_debug(sprintf('< %s at %s',mfilename, datestr(now,31)),1)


