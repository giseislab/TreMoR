function w = waveform_computeDr(w, subnet, f, varargin)
print_debug(sprintf('> %s', mfilename),4);
[downsample_method, wave_type, wave_speed] = process_options(varargin, 'downsample_method', 'rms', 'wave_type', 'surface', 'wave_speed', 2000);

% integrate from velocity to displacement
w = integrate(w);

% downsample
w = waveform_downsample(w, downsample_method);

% add distance
w = waveform_addstationdistance(w, subnet);

% reduce
data = reduce1mindata(get(w, 'data') * 1e-7, get(w, 'r'), 'displacement', wave_type, wave_speed*100, f);
w=set(w,'data',data,'units','cm^2');

print_debug(sprintf('< %s', mfilename),4);



