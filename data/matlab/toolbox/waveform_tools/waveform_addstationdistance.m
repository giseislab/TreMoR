function w = waveform_addstationdistance(w, subnet)
if isempty(get(w,'r')) 
    station.name = get(w,'station');
    station.channel = get(w,'channel');
    station = db2stationdistances(subnet, station, get(w,'start'));
    w = addfield(w, 'r', station.distance);
    w = addHistory(w, 'Added station distance as r');
end