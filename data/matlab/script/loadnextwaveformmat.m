function [w, filename, snum, enum, subnet] = loadnextwaveformmat(matdir)

% set null values
w=[];
filename='';
snum=0;
enum=0;
subnet='';

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
				system(sprintf('rm %s',filename));
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
	
