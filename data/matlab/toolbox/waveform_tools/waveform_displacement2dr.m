function w = waveform_computeDrs(w, subnet, f, varargin)
print_debug(sprintf('> %s', mfilename),4);
[downsample_method, wave_type, wave_speed] = process_options(varargin, 'downsample_method', 'rms', 'wave_type', 'surface', 'wave_speed', 2000);

% integrate from velocity to displacement
w = integrate(w);

% downsample
w = waveform_downsample(w, downsample_method);

% add distance
w = waveform_addstationdistance(w, subnet);

% reduce
data = reduce1mindata(data * 1e-7, station.distance, 'displacement', wave_type, wave_speed*100, f);
w=set(w,'data',data,'units','cm^2');

print_debug(sprintf('< %s', mfilename),4);

function w=waveform_downsample(w, downsample_method)
% Note: If RMS and STD were added as methods to waveform/resample, this
% function would be obsolete
% downsample to 1 Hz
data = abs(get(w,'data'));
tstart = get(w, 'tstart');
Fs = get(w, 'freq');
l = length(data);
count = 1;
seconds = 60;
step = Fs * seconds;
for ssamp=1:step:l
    esamp = min([(ssamp + step -1) l]);
    y(count) = eval(sprintf('%s(data(ssamp:esamp))',downsample_method));
    count = count + 1;
end 
w = set(w, 'data', y, 'freq', 1/seconds);
w = addfield(w, 'downsample_method', downsample_method);
w = addHistory(sprintf('Resampled data using %s method in %s',downsample_method,mfilename));

function w = waveform_addstationdistance(w, subnet)
if isempty(get(w,'r')) 
    station.name = get(w,'station');
    station.channel = get(w,'channel');
    station = db2stationdistances(subnet, station, get(w,'start'));
    w = addfield(w, 'r', station.distance);
    w = addHistory('Added station distance as r');
end