function stats = waveform2f(w)
w = waveform_addsgram(w);
for c=1:length(w)
    sgram = get(w(c), 'sgram');
    if isstruct(sgram)
        % downsample sgram data to 1 minute bins
        [Smax,i] = max(sgram.S);
        peakf = sgram.F(i);
        meanf = (sgram.F' * sgram.S)./sum(sgram.S);
        dnum = unique(floorminute(sgram.T/86400));
        for k=1:length(dnum)
            p = find(floorminute(sgram.T) == dnum(k));
            stats(c).peakf(k) = nanmean(peakf(p));
            stats(c).meanf(k) = nanmean(meanf(p));       
        end
    else
        sgram
    end
end