function w = waveform_fillempty(w);
data = zeros(60000, 1);
[wsnum, wenum]=gettimerange(w);
i = find(wsnum==epoch2datenum(0));
wsnum(i)=[];
for c=1:length(w)
	nsamp = get(w(c), 'data_length');
	if (nsamp == 0) 
		w(c) = set(w(c), 'data', data, 'freq', 100, 'start', min(wsnum));
	end
end 
