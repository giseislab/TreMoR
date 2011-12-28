function [w, filename, snum, enum, subnet] = save2waveformmat(w, matdir, snum, enum, subnet, varargin)
	global paths PARAMS;
	[matdir2] = process_options(varargin, 'copy', '');
	filename = sprintf('%s/%s_%s.mat',matdir,subnet,datestr(snum,30));
	if ~exist(matdir, 'dir')
		mkdir('.', matdir);
	end
	disp(sprintf('Saving to %s',filename));
	eval(sprintf('save %s w snum enum subnet paths PARAMS',filename));

	% check file size is reasonable - if not, delete and return
	d = dir(filename);
	if length(d)==1
		filesize = d(1).bytes;
		disp(sprintf('%s has size %d bytes',filename,filesize));
		if (filesize < 10000)		
			delete(filename);
			disp('Too small - deleted');
			return;	
		end	
	end

	% make a second copy if asked
	if ~isempty(matdir2)
		filename2 = sprintf('%s/%s_%s.mat',matdir2,subnet,datestr(snum,30));
		if ~exist(matdir2, 'dir')
			mkdir('.', matdir2);
		end
		%disp(sprintf('Copying to %s',filename2));
		disp(sprintf('Saving to %s',filename2));
		eval(sprintf('save %s w snum enum subnet paths PARAMS',filename2));
		%system(sprintf('cp %s %s',filename, filename2));
	end

	

end
