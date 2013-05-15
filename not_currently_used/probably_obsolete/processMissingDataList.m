function processMissingDataList
while 1,
	load state/missingDataList.mat
	if length(mdi)>0
		m = mdi(1);
		mdi(1) = [];
		save state/missingDataList.mat mdi
		try
			w = getwaveforms(m.scnl, m.snum, m.enum);
			if isempty(w)
				giveUp(m);
			else	
				save2waveformmat(w, 'waveforms_raw', m.snum, m.enum, m.subnet);
			end
		catch
				giveUp(m);
		end
	else
		disp('No more missing data. Waiting...'); 	
		pause(60);
	end
end

function giveUp(m)
fout = fopen('state/missingData.txt', 'a');
fprintf(fout, 'Missing data from %s to %s for %s\n', datestr(m.snum, 31), datestr(m.enum, 31), m.subnet);
fclose(fout);	
