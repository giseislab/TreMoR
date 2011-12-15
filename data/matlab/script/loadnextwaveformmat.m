function [w, filename, snum, enum, subnet] = loadnextwaveformmat(matdir)

% set null values
w=[];
filename='';
snum=0;
enum=0;
subnet='';
found = false;

d = [];
firsttime = 1;
while ~found
	d = dir(sprintf('%s/*.mat',matdir));
	if length(d)>0
		%filename = sprintf('%s/%s',matdir,d(1).name);
		filename = sprintf('%s/%s',matdir,d(end).name);
		try
			pause(2); % pause just to give time for file to be saved properly
			eval(['load ',filename]);

	           	% Sanity checks
                	errorFound=false;
                	if ~strcmp(class(w),'waveform')
                	        errorFound=true;
                	end
                	if ~(snum>datenum(1989,1,1) && snum<utnow)
                	        errorFound=true;
                	end
                	if ~(enum>datenum(1989,1,1) && enum<utnow)
                	        errorFound=true;
                	end
                	if length(subnet)==0
                	        errorFound=true;
                	end
	
	                if errorFound
	                        delete(filename);
			else
				found = true;
				summariseWaveformMat(filename, snum, enum, subnet);
			end
		catch
			delete(filename);
		end	
        else
        	if firsttime
                	fprintf('%s: Waiting for new waveformmat file.',mfilename);
                	firsttime = 0;
            	end    
		pause(5);
		fprintf('.');
	end
end
fprintf('\n');


	
