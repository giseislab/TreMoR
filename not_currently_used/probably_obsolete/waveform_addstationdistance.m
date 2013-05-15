function w = waveform_addstationdistance(w, subnet)
%WAVEFORM_ADDSTATIONDISTANCE
% Associate a subnet-station distance with a waveform
% object
if isempty(get(w,'r')) 
    station.name = get(w,'station');
    station.channel = get(w,'channel');
    station = db2stationdistances(subnet, station, get(w,'start'));
    w = addfield(w, 'r', station.distance);
    w = addHistory(w, 'Added station distance as r');
end
