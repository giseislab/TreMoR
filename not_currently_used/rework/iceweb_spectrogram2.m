function w=iceweb_spectrogram(subnet, snum, enum, station);
% ICEWEB_SPECTROGRAM Create a customised IceWeb-like spectrogram plot
%
% 	ICEWEB_SPECTROGRAM(VOLCANO, SNUM, ENUM) creates an IceWeb spectrogram plot
%       based on the station/channel list in the current parameter file for that particular
%	volcano. The start and end times are defined by the arguments SNUM and ENUM which 
%	must be in Matlab datenumber format. See DATENUM.
%
%	ICEWEB_SPECTROGRAM(TITLE, SNUM, ENUM, STATION) creates an IceWeb spectrogram plot
%	for the STATION structure given. TITLE in this case is the title given to the plot.
%	A STATION structure as a bare minimum must have name and channel fields, and can be
%	constructed manually like this:
%
%		station(1).name = 'PVV';
%		station(1).channel = 'EHZ';
%		station(2).name = 'PV6';
%		station(2).channel = 'EHZ';
%		...etc
%
% 	Example:
%		The following will create an IceWeb-like spectrogram for Shishaldin Volcano 
%		from 10:00 UTC to 11:00 UTC on 10th April 2008:
%	
%  		iceweb_spectrogram('Shishaldin', datenum(2008,4,10,10,0,0), ...
%		datenum(2008,4,10,11,0,0));
%
%
%	Author:
%		Glenn Thompson (glennthompson1971@gmail.com), 2008-04-11

global PARAMS paths
if exist('/home/glenn/pf/iceweb_parameters.pf','file')
  rundir = '/home/glenn';
else
  rundir = '/home/iceweb/run';
end
rundir = pwd;


switch nargin
	case 3,
		if exist([rundir,'/pf/iceweb_parameters.pf'],'file')
			[subnets, numstations] = subnetsetup(rundir, subnet );
			station = subnets(1).stations;
			titlestr = [subnet,'  ',datestr(snum,31),' - ',datestr(enum,13),' UTC'];	
		else
			disp('No IceWeb parameter file');
			w=[];
			return;
		end
		

	case 4,
		if exist([rundir,'/pf/iceweb_parameters.pf'],'file')
			errorCode1 = pf2paths(rundir);
			errorCode2 = pf2PARAMS();
			titlestr = subnet;
		else
			PARAMS.spectralobject = spectralobject(512, 268, 10, [40 100]);
		end
	otherwise
		help iceweb_spectrogram2, return;
end
PARAMS.mode = 'interactive';
PARAMS.sound = 0;
PARAMS.print = 0;


timewindow.start = snum;
timewindow.stop = enum;

disp(sprintf('You have requested a spectrogram from %s to %s', datestr(snum,0), datestr(enum,0)));
debug(2);
w = waveformWrapper2(station, timewindow);
success = 0;

% downsample data
freqmax = get(PARAMS.spectralobject, 'freqmax');
for c=1:length(w)
	nyquist = get(w(c), 'freq') / 2;
	factor = floor(nyquist / freqmax);

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

specgram3(w, titlestr, PARAMS.spectralobject, 1.0);


