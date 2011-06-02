function [w, filename, snum, enum, subnet] = loadnextwaveformmat(matdir)
	d = [];
    firsttime = 1;
	while isempty(d)
		d = dir(sprintf('%s/*.mat',matdir));
		if length(d)>0
			filename = sprintf('%s/%s',matdir,d(1).name);
			eval(['load ',filename]);
        else
            if firsttime
                disp(sprintf('%s: Waiting for new waveformmat file...',mfilename));
                firsttime = 0;
            end    
			pause(5);
		end
	end
end
	
