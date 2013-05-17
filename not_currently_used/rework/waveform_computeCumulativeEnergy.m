function w=waveform_computeCumulativeEnergy(w)
Fs = get(w,'freq');
x = get(w,'data');
r = get(w,'r');
chan = get(w, 'channel');
if ~isempty(r) % DISTANCE IS DEFINED, USE ABSOLUTE UNITS   
    % Scale factor to convert to real energy units (J)
    if strfind(chan, 'BD')
        % pressure sensor - spherical waves
        rho_air = 1.2; % kg/m3
        c_air = 320; % m/s
        scale_factor = (4 * pi * r^2)/(c_air * rho_air);
    else
        % seismometer - assuming body waves
        rho_earth = 2500; % kg/m3
        c_earth = 3000; % m/s
        scale_factor = (4 * pi * r^2)*(c_earth * rho_earth)*1e-18; % 1e-18 converts from (nm/s)^2 to (m/s)^2
    end
    units = 'J';
    w = addHistory(w, 'Converted waveform to cumulative absolute energy');
else % DISTANCE IS UNDEFINED, USE RELATIVE UNITS   
    if strfind(chan, 'BD')
        % pressure sensor - spherical waves
        units = 'Pa^2 s';
        scale_factor = 1;
    else
        % seismometer - assuming body waves
        units = 'm^2 / s';
        scale_factor = 1e-18; % 1e-18 converts from (nm/s)^2 to (m/s)^2
    end
    w = addHistory(w, 'Converted waveform to cumulative relative energy');
end
watts = (x.*x) * scale_factor;
energy = cumsum(watts)/Fs;
w = set(w, 'data', energy);
w = set(w, 'units', units);

% Add other metrics
metrics.energy = max(energy) - min(energy); % J
metrics.duration = (length(energy)/Fs); % s
metrics.meanpower = mean(watts); % W
metrics.maxpower = max(watts); % W
w = addfield(w, 'metrics', metrics);
w = addHistory(w, 'Added metrics for energy, duration, meanpower and maxpower');
