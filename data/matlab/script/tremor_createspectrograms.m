function tremor_createspectrograms(waveformdir)
global paths PARAMS
print_debug(sprintf('> %s at %s',mfilename, datestr(now,31)),1)
load pf/runtime
while 1,

	tic;
	[w, filename, snum, enum, subnet] = loadnextwaveformmat(waveformdir);
	if (snum<utnow-3)
		PARAMS.mode = 'archive';
	else
		PARAMS.mode = 'realtime';
	end	
	diaryname = getSgramDiaryName(subnet, enum);	
	diary(diaryname);
	w = waveform_fillempty(w, snum, enum); % alternative is the waveform_nonempty function, which eliminates empty waveform objects, rather than replacing them with waveform objects containing zeros. Both eliminate waveform objects of length 1 - these corrupt waveform objects cause masaive problems - no idea where they coome from 
	tenminspfile = getSgram10minName(subnet, enum);
	specgram3(w, sprintf('%s %s - %s UTC', subnet, datestr(snum,31), datestr(enum,13)), PARAMS.spectralobject , 0.75);

	% save image file
	orient tall;
	if saveImageFile(tenminspfile, 200)
		fileinfo = dir(tenminspfile);
		print_debug(sprintf('spectrogram PNG size is %d',fileinfo.bytes),0);	
		if fileinfo.bytes < 20000 % if PNG is too small, it cannot be a good waveform file
			disp('spectrogram PNG is small. Copying to small_spectrograms for further diagnosis');
			system(sprintf('cp %s small_spectrograms/',tenminspfile));
        		save2waveformmat(w, 'small_spectrograms', snum, enum, subnet);
		end
		% Create a thumbnail spectrogram
    		makesgramthumbnail(tenminspfile);
        	save2waveformmat(w, 'waveform_files/stage3_sgramcreated', snum, enum, subnet);

		%system(sprintf('cp %s www/plots/lastspectrogram.png',tenminspfile));
		system('touch www/plots/lastspectrogram.txt');
		logbenchmark(mfilename, toc);
	end
	diary off
	
	% Pause briefly
	pause(1);
end    

print_debug(sprintf('< %s at %s',mfilename, datestr(now,31)),1)
