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
		printfunctionstack('>');
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
			printfunctionstack('<');
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
		printfunctionstack('<');
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


	
