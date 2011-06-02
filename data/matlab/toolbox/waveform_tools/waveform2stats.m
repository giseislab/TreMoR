function stats = waveform2stats(w, newFs)
for c=1:length(w)
    stats(c) = [];
    oldFs = get(w(c), 'freq');
    cf = round(oldFs / newFs);
    if strcmp(get(w(c), 'units'), 'nm / sec')
        s = waveform2sam(w(c));
        stats(c).Vmax = s.resample('absmax', cf);
        stats(c).Vmedian = s.resample('absmedian', cf);
        stats(c).Vmean = s.resample('absmean', cf);
        %e = energy(s); 
        %stats.Energy = e.resample('absmean', cf);, 
        w(c) = integrate(w(c));
    end

    if strcmp(get(w(c), 'units'), 'nm')
        s = waveform2sam(w(c));
        stats(c).Dmax = s.resample('absmax', cf);
        stats(c).Dmedian = s.resample('absmedian', cf);
        stats(c).Dmean = s.resample('absmean', cf);
        stats(c).Drms = s.resample('rms', cf);
    end
end
end