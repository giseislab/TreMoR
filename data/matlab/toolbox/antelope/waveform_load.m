function w=waveform_load(subnet, sta, chan, snum, enum, varargin)
[remove_calibs, remove_spikes, remove_trend, remove_response, interactive_mode, lowcut, highcut] = process_options(varargin, 'remove_calibs', true, 'remove_spikes', true, 'remove_trend', true, 'remove_response', false, 'interactive_mode', false, 'lowcut', 0.5, 'highcut', 20.0);

w=[];
station.name = sta;
station.channel = chan;
scnl = station2scnl(station);
timewindow.start = snum;
timewindow.stop = enum;

% load the data
w = getwaveforms(scnl, timewindow);

% add the station distance
w = waveform_addstationdistance(w, subnet);

% correct pressure sensor channel: DFR-BDF and DFR-BDL
if strcmp(station.name, 'DFR') && ~isempty(strfind(station.channel, 'BD'));
    if strcmp(station.channel, 'BDF')
        calib = 140; % 140 counts per Pa
    end
    if strcmp(station.channel, 'BDL')
        calib = 7; % 7 counts per Pa
    end
    w = set(w,'calibration_applied', 'yes');
    w = set(w, 'calib', calib);
    w = set(w, 'data', get(w,'data') / calib); 
end

% Remove calibs, despike, detrend and deconvolve waveform data
w = waveform_clean(w, 'remove_calibs', remove_calibs, 'remove_spikes', remove_spikes, 'remove_trend', remove_trend, 'remove_response', remove_response, 'lowcut', lowcut, 'highcut', highcut);
