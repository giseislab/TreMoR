function [pointerToSubnetPF, existsSubnetPF] = openPointerToSubnet(subnet);
%OPENPOINTERTOSUBNET return a pointer to the parameter file for subnet.
%
% [pointerToSubnetPF, existsSubnetPF] = openPointerToSubnet(subnet);
% 	existsSubnetPF is either TRUE or FALSE depending on whether the subnet file was found (& opened) or not.
%
% The paths.PFS variable must be set to the directory where the subnet.pf resides
%
% Glenn Thompson, 1998 - 2008

global paths

print_debug(sprintf('> %s', mfilename),5)

% create pointer to iceweb parameter file
parameterFilename = catpath(paths.PFS,sprintf('subnet_%s',subnet));
if exist([parameterFilename,'.pf'])
	pointerToSubnetPF = dbpf(parameterFilename);
	existsSubnetPF = 1; 
else
	disp([parameterFilename,' does not exist'])
	pointerToSubnetPF = -1;
	existsSubnetPF = 0;
end

print_debug(sprintf('< %s', mfilename),5)
