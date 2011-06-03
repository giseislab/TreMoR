function stats = waveform2stats(w, newFs)
stats=[];
for c=1:length(w)
    oldFs = get(w(c), 'freq');
    cf = round(oldFs / newFs);
    if strcmp(get(w(c), 'units'), 'nm / sec')
        stats(c).Vmax = makestat(w(c), 'absmax', cf);
        stats(c).Vmedian = makestat(w(c), 'absmedian', cf);
        stats(c).Vmean = makestat(w(c), 'absmean', cf);
        %e = energy(s); 
        %stats.Energy = e.resample('absmean', cf);, 
        w(c) = integrate(w(c));
    end

    if strcmp(get(w(c), 'units'), 'nm')
        stats(c).Dmax = makestat(w(c), 'absmax', cf);
        stats(c).Dmedian = makestat(w(c), 'absmedian', cf);
        stats(c).Dmean = makestat(w(c),'absmean', cf);
        stats(c).Drms = makestat(w(c), 'rms', cf);
    end
end
end

function s=makestat(w, method, cf)
	try % rare error in waveform/resample
        	wr = resample(w, method, cf);
        	s = waveform2sam(wr);
        	s.measure = method;
	catch
		s = [];
	end
end
