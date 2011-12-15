function tremor_createspectrograms(waveformdir)
global paths PARAMS
print_debug(sprintf('> %s at %s',mfilename, datestr(now,31)),1)
load pf/runtime
while 1,
	[w, filename, snum, enum, subnet] = loadnextwaveformmat(waveformdir);

	tensminspfile = getSgram10minName(subnet, enum);
	specgram3(w, sprintf('%s %s - %s UTC', subnet, datestr(snum,31), datestr(enum,13)), PARAMS.spectralobject , 0.75);

	% save image file
	orient tall;
	if saveImageFile(tenminspfile, 50)
		%close;
				
		% Create a thumbnail spectrogram
		%spthumbfile = catpath(spdir, ['small_', timestamp, '.png']);
		%makeThumbnail(spthumbfile, timestamp);
    		makesgramthumbnail(tenminspfile);
	end

	if ~isempty(filename)
		if exist(filename,'file')
			delete(filename);
		end
	end 
	
	% Pause briefly
	pause(5);
end    

print_debug(sprintf('< %s at %s',mfilename, datestr(now,31)),1)
