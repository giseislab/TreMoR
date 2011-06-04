function tremor_createspectrograms(varargin)
global paths PARAMS
print_debug(sprintf('> %s at %s',mfilename, datestr(now,31)),1)
load pf/runtime

while 1,
	[w, filename, snum, enum, subnet] = loadnextwaveformmat('waveforms_sgram');

	% Remove waveforms MAT file here so can have multiple jobs running  without  them processing the same waveform file
	delete(filename);

	% Output some information
	disp(sprintf('\n***** New waveform *****'));
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
	try
		saveImageFile(tenminspfile, 60);
        catch exception
        	disp(sprintf('Could not save %s\n%s' ,tenminspfile, exception.message));
	end
				
	% Create a thumbnail spectrogram
	%spthumbfile = catpath(spdir, ['small_', timestamp, '.png']);
	disp(sprintf('Creating thumbnail'));
	%makeThumbnail(spthumbfile, timestamp);
    makesgramthumbnail(tenminspfile);

	close;

	% Pause briefly
	pause(1);
end    

print_debug(sprintf('< %s at %s',mfilename, datestr(now,31)),1)


