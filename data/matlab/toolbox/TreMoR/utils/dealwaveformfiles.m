function dealwaveformfiles(sourcedir, targetdirlist)
% dealwaveformfiles(sourcedir, targetdir)
% to send all MAT files from waveforms_filtered to whichever of waveforms_sgram, waveforms_sgram2, ... have the least files
% 	dealwaveformfiles('waveforms_filtered', 'waveforms_sgram')
% to send all MAT files from waveforms_filtered to whichever of waveforms_sgram, waveforms_sgram2, ... have the least files, AND also to directories like waveforms_sam*
% 	dealwaveformfiles('waveforms_filtered', {'waveforms_sgram';'waveforms_sam'})

global paths PARAMS

debug.printfunctionstack('>');

while 1,
		filelist = dir(sprintf('%s/*.mat',sourcedir));
		for k=1:length(filelist)
			filename = filelist(k).name
			disp(sprintf('Processing %s',filename));

			if (~strcmp(class(targetdirlist),'cell'))
				targetdirlist = {targetdirlist};
			end
			for tdn = 1:numel(targetdirlist)
				targetdir = targetdirlist{tdn};
				%[basedir, topdir] = basename(targetdir); 
				[topdir, basedir] = fileparts(targetdir); 
	
				% Find the quietest target directory
				d = dir(sprintf('%s*',targetdir));
				for c=1:length(d)
					%disp(sprintf('Processing %s',d(c).name));
					dd=dir(sprintf('%s/%s/*.mat',topdir,d(c).name));
					numfiles(c)=length(dd);
				end
				if length(numfiles)>0
					[m,i]=min(numfiles);
					bestdir = d(i).name;
					expr = sprintf('cp %s/%s %s/%s/%s',sourcedir, filename, topdir, bestdir, filename );
					disp(expr); 
					pause(1);
					status = system(expr);	
					clear d m i bestdir expr numfiles
				end
			end

			delete(sprintf('%s/%s',sourcedir, filename));
		end		


		% Pause briefly
		disp(sprintf('Waiting %s',datestr(utnow,30)));
		pause(10);

end    

%print_debug(sprintf('< %s at %s',mfilename, datestr(now,31)),1)
debug.printfunctionstack('<');

