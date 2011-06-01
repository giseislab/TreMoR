function [w, filename, snum, enum, subnet] = loadnextwaveformmat(matdir)
	d = [];
	while isempty(d)
		d = dir(sprintf('%s/*.mat',matdir));
		if length(d)>0
			filename = d.name(1);
			eval(['load ',filename]);
		else
			pause(5);
		end
	end
end
	
