function [w, filename, snum, enum, subnet] = loadnextwaveformmat(matdir)
	d = [];
	while isempty(d)
		d = dir(sprintf('%s/*.mat',matdir));
		if length(d)>0
			filename = sprintf('%s/%s',matdir,d(1).name);
			eval(['load ',filename]);
		else
			pause(5);
		end
	end
end
	
