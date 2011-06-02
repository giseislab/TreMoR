function [day_plots, pfexists] = subnetpf2days(subnet);
%subnetpf2days returns the days vector from a subnet parameter file.
% If a day_plots &Arr is not defined, it defaults to the PARAMS.dayplots value
%
% [day_plots, pfexists] = subnetpf2days(subnet)
%
% Glenn Thompson, 2008-03-28
global PARAMS;
print_debug(sprintf('> %s', mfilename),5)

% open pointer to subnet parameter file
[ps, pfexists] = openPointerToSubnet(subnet);

if pfexists

	% get drplots
	print_debug('getting days',3)
	try
		day_plots = pfget_tbl(ps,'day_plots');
	catch
		day_plots = PARAMS.dayplots;
	end

	% test for existence
	if ~exist('day_plots', 'var')
		day_plots = PARAMS.dayplots;
	end
else
	day_plots = [];
end
print_debug(sprintf('< %s', mfilename),5)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

