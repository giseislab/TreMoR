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

		% delete it if too small
		if (filesize < 76000), 
			disp(sprintf('%s is probably full of blank data, as size is only %d bytes',filename,filesize));
			delete(filename);
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
		end
		delete(tmpfile);

           	% Sanity checks
               	errorFound=false;
		if exist('w', 'var')
               		if ~strcmp(class(w),'waveform')
               		        errorFound=true;
               		end
		else
               	        errorFound=true;
		end
		
		if exist('snum', 'var')
               		if ~(snum>datenum(1989,1,1) && snum<utnow)
               		        errorFound=true;
               		end
		else
               	        errorFound=true;
		end

		if exist('enum', 'var')
               		if ~(enum>datenum(1989,1,1) && enum<utnow)
               		        errorFound=true;
               		end
		else
               	        errorFound=true;
		end

		if exist('subnet', 'var')
               		if length(subnet)==0
               		        errorFound=true;
               		end
		else
               	        errorFound=true;
		end

                if ~errorFound
			found = true;
			summariseWaveformMat(filename, snum, enum, subnet);
		else
			disp('CORRUPT WAVEFORM MAT FILE? - Skipping.')
		end


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


	
