function w=iceweb_spectrogram(matfile, subnet, snum, enum, mycmap)
% ICEWEB_SPECTROGRAM Create a customised IceWeb-like spectrogram plot
%
% 	ICEWEB_SPECTROGRAM(MATFILE, SUBNET, SNUM, ENUM, MYCOLORMAP) creates an IceWeb spectrogram plot
%       based on the station/channel list in the MATFILE for that particular
%	subnet. The start and end times are defined by the arguments SNUM and ENUM which 
%	must be in Matlab datenumber format. See DATENUM.
%
%
% 	Example:
%		The following will create an IceWeb-like spectrogram for Shishaldin Volcano 
%		from 10:00 UTC to 11:00 UTC on 10th April 2008 and uses the default_spectralobject_colormap colormap:
%	
%  		iceweb_spectrogram('pf/tremor_runtime.mat', 'Shishaldin', datenum(2008,4,10,10,0,0), ...
%		datenum(2008,4,10,11,0,0), default_spectralobject_colormap);
%
%       iceweb_spectrogram('pf/tremor_runtime.mat', 'Kanaga', datenum(2013,05,08,22,20,00), datenum(2013,05,08,22,30,00), iceweb_spectrogram_colormap);
%
%
%	Author:
%		Glenn Thompson (glennthompson1971@gmail.com), 2008-04-11
if ~exist('mycmap', 'var')
    mycmap = jet;
end

load(matfile);
for c=1:numel(PARAMS.datasource)
	if strcmp(PARAMS.datasource(c).type, 'antelope')
		gismo_datasource(c) = datasource(PARAMS.datasource(c).type, PARAMS.datasource(c).path);
	else
		gismo_datasource(c) = datasource(PARAMS.datasource(c).type, PARAMS.datasource(c).path, str2num(PARAMS.datasource(c).port));
	end
end
PARAMS.mode = 'interactive';
disp(sprintf('You have requested a spectrogram from %s to %s', datestr(snum,0), datestr(enum,0)));
debug.set_debug(2);
for subnet_num=1:length(subnets)
	% which subnet?
	thissubnet = subnets(subnet_num).name;
    if strcmp(subnet, thissubnet) 
        station = subnets(subnet_num).stations;
        w = waveform_wrapper([station.scnl], snum, enum, gismo_datasource);
        
        % downsample data
        freqmax = get(PARAMS.spectralobject, 'freqmax');
        for c=1:length(w)
            nyquist = get(w(c), 'freq') / 2;
            factor = floor(nyquist / (freqmax * 5));

            if (factor > 1)
                disp(sprintf('Decimating by factor %d',factor));

                % downsample data
                data = get(w(c),'data');
                %data2 = decimate(data, factor); % not NaN-aware
                data2 = data(1:factor:end);
                w(c) = set(w(c), 'data', data2);
                clear data data2
	
                % update the sample frequency info
                freq = get(w(c),'freq');
                freq = freq / factor;
                w(c) = set(w(c), 'freq', freq)
            end
        end

        specgram_wrapper(PARAMS.spectralobject, w, 0.7, mycmap);
    end
end

