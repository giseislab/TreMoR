function [w, filename, snum, enum, subnet] = loadnextwaveformmat(matdir)
	d = [];
    firsttime = 1;
	while isempty(d)
		d = dir(sprintf('%s/*.mat',matdir));
		if length(d)>0
			filename = sprintf('%s/%s',matdir,d(1).name);
			try
				pause(2); % pause just to give time for file to be saved properly
				eval(['load ',filename]);
			catch
				corruptDir = [matdir,'/corrupt'];
				if ~exist(corruptDir, 'dir')
					system(sprintf('mkdir -p %s',corruptDir));	
				end
				system(sprintf('mv %s %s',filename,corruptDir));
				d = [];
			end	
        else
            if firsttime
                disp(sprintf('%s: Waiting for new waveformmat file...',mfilename));
                firsttime = 0;
            end    
			pause(5);
		end
	end
end
	
