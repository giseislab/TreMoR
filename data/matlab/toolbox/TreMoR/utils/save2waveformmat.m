function [w, filename, snum, enum, subnet] = save2waveformmat(w, matdir, snum, enum, subnet, varargin)
	global paths PARAMS;
	%print_debug(sprintf('> %s',mfilename),1);
	debug.printfunctionstack('>');
	[matdir2] = matlab_extensions.process_options(varargin, 'copy', '');
	%filename = sprintf('%s/%s_%s.mat',matdir,subnet,datestr(snum,30));
	filename = sprintf('%s/%s_%s.mat',matdir,subnet,datestr(enum,30));
	if ~exist(matdir, 'dir')
		mkdir('.', matdir);
	end
	disp(sprintf('%s: Saving to %s',datestr(utnow), filename));
	successful = false;
	eval(sprintf('save -mat %s.tmp w snum enum subnet paths PARAMS',filename));
	
	% check file size is reasonable - if not, delete and return
	d = dir(sprintf('%s.tmp',filename));
	if length(d)==1
		filesize = d(1).bytes;
		system(sprintf('mv %s.tmp %s',filename, filename));
		disp(sprintf('%s: %s has size %d bytes',datestr(utnow), filename,filesize));
		if (filesize < 10000)		
			delete(filename);
			if ~exist(filename, 'file')
				disp(sprintf('%s: %s has been deleted - it was suspiciously small - there is probably a zero length spectrogram png out there somewhere too which needs deleting',datestr(utnow), filename));
			else
				disp(sprintf('%s: *** Weird! Could not delete %s',datestr(utnow), filename));
			end

			remove_sgramfile(subnet, enum)
			debug.printfunctionstack('<');
			return;	
		end	
		disp(sprintf('%s: Waveform MAT file created',datestr(utnow)));
	else
		disp(sprintf('%s: *** Weird %s not created',datestr(utnow), filename))
		d
		w
		for c=1:numel(w)
			w(c)
		end	
		matdir
		snum, datestr(snum)
		enum, datestr(enum)
		subnet
		remove_sgramfile(subnet, enum)
		debug.printfunctionstack('<');
		return;	
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

	
	debug.printfunctionstack('<');

end

function successful = remove_sgramfile(subnet, enum)
	successful = true;
	sgramfile = getSgram10minName(subnet, enum);
	if exist(sgramfile, 'file')
		sfileptr=dir(sgramfile);
		disp(sprintf('%s: %s has size %d bytes',datestr(utnow), sgramfile,sfileptr(1).bytes));
		if (sfileptr(1).bytes < 1000)
			delete(sgramfile);
			if ~exist(sgramfile, 'file')
				disp(sprintf('%s: %s has been deleted - it was suspiciously small',datestr(utnow), sgramfile));
			else
				successful = false;	
				disp(sprintf('%s: *** Weird! Could not delete %s',datestr(utnow), sgramfile));
			end
		end
	else
		successful = false;	
		disp(sprintf('%s: *** Weird! %s does not exist - oh well I was going to delete it anyway',datestr(utnow), sgramfile));
	end
end
