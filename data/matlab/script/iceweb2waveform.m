function w=iceweb2waveform(matfile, subnet, snum, enum)
% ICEWEB2WAVEFORM Create a waveform vector from an IceWeb matfile
%
% 	ICEWEB2WAVEFORM(MATFILE, SUBNET, SNUM, ENUM) loads a waveform vector 
%   based on the datasources and station/channel list in the MATFILE for that particular
%	subnet. The start and end times are defined by the arguments SNUM and ENUM which 
%	must be in Matlab datenumber format. See DATENUM.
%
%
% 	Example:
%		The following will create a waveform vector for Shishaldin Volcano 
%		from 10:00 UTC to 11:00 UTC on 10th April 2008
%	
%  		w=iceweb2waveform('pf/tremor_runtime.mat', 'Pavlof', datenum(2013,5,16,0,0,0), datenum(2013,5,17,0,0,0));
%
%	Author:
%		Glenn Thompson (glennthompson1971@gmail.com), 2008-04-11
close all
load(matfile);
for c=1:numel(PARAMS.datasource)
	if strcmp(PARAMS.datasource(c).type, 'antelope')
		gismo_datasource(c) = datasource(PARAMS.datasource(c).type, PARAMS.datasource(c).path);
	else
		gismo_datasource(c) = datasource(PARAMS.datasource(c).type, PARAMS.datasource(c).path, str2num(PARAMS.datasource(c).port));
	end
end
PARAMS.mode = 'interactive';
disp(sprintf('You have requested a waveform vector from %s to %s', datestr(snum,0), datestr(enum,0)));
debug.set_debug(2);
for subnet_num=1:length(subnets)
	% which subnet?
	thissubnet = subnets(subnet_num).name;
    if strcmp(subnet, thissubnet) 
        station = subnets(subnet_num).stations;
        w = waveform_wrapper([station.scnl], snum, enum, gismo_datasource);
        w = waveform_addresponse( w, matfile, subnets, subnet );
        w = waveform_adddistance( w, matfile, subnets, subnet );
        w = waveform_calibrate(w, snum, enum)
    end    
end

