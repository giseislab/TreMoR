function tremor_dealfilterwaveforms(varargin)
global paths PARAMS
print_debug(sprintf('> %s at %s',mfilename, datestr(now,31)),1)
%load pf/runtime

while 1,
	din = dir('waveforms_filtered/*.mat');
	for k=1:length(din)
		filename = din(k).name;
		disp(sprintf('Processing %s',filename));

		% Find the quietest spectrogram directory
		d=dir('waveforms_sgram*');
		for c=1:length(d)
			%disp(sprintf('Processing %s',d(c).name));
			dd=dir(d(c).name);
			numfiles(c)=length(dd)-2;
		end
		if length(numfiles)>0
			[m,i]=min(numfiles);
			bestdir = d(i).name;
			expr = sprintf('cp waveforms_filtered/%s %s/%s',filename, bestdir, filename );
			disp(expr); 
			status = system(expr);	
			clear d m i bestdir expr numfiles
		end

                % Find the quietest sam directory
                d=dir('waveforms_sam*');
                for c=1:length(d)
                        dd=dir(d(c).name);
                        numfiles(c)=length(dd)-2;
                end
		if length(numfiles)>0
                	[m,i]=min(numfiles);
                	bestdir = d(i).name;
                	expr = sprintf('cp waveforms_filtered/%s %s/%s',filename, bestdir, filename);   
			disp(expr); 
                	status = system(expr); 	
			clear d m i bestdir expr numfiles
		end
        
		% Remove waveforms MAT file from waveforms_raw
		system(sprintf('mv waveforms_filtered/%s done/%s',filename, filename));
		%delete(din(k).name);
	end		


	% Pause briefly
	fprintf('.');
	pause(5);

end    

print_debug(sprintf('< %s at %s',mfilename, datestr(now,31)),1)

