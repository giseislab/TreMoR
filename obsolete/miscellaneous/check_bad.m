cd /avort/modrun/badmatfiles

d=dir('*.mat');
for c=1:numel(d)
	fprintf('%s: %d bytes',d(c).name,d(c).bytes);
	try
		eval(sprintf('load %s',d(c).name));
		fprintf(' - loaded');
		try	
			plot(w)	
			fprintf(' - plotted');
			system(sprintf('mv %s /avort/modrun/waveform_files/stage2_filtered',d(c).name));
		catch
		end
	catch
		
	end
	fprintf('\n\n');
end
