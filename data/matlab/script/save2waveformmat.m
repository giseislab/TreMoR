function [w, filename, snum, enum, subnet] = save2waveformmat(w, matdir, snum, enum, subnet, varargin)
	[matdir2] = process_options(varargin, 'copy', '');
	filename = sprintf('%s/%s_%s.mat',matdir,subnet,datestr(snum,30));
	if ~exist(matdir, 'dir')
		mkdir('.', matdir);
	end
	disp(sprintf('Saving to %s',filename));
	eval(sprintf('save %s w snum enum subnet',filename));
	if ~isempty(matdir2)
		filename2 = sprintf('%s/%s_%s.mat',matdir2,subnet,datestr(snum,30));
		if ~exist(matdir2, 'dir')
			mkdir('.', matdir2);
		end
		disp(sprintf('Copying to %s',filename2));
		system(sprintf('cp %s %s',filename, filename2));
	end
end
