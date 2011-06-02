function self = waveform2sam(w)
    self = sam(datenum(w), get(w, 'data')');
    self.units = get(w, 'units');
    self.scnl = scnlobject(get(w, 'station'), get(w, 'channel'));
    self.measure = get(w, 'measure');
    self.isReduced = get(w, 'isReduced');
end 