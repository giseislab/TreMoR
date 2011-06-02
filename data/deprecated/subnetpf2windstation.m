function [windstation, pfexists] = subnetpf2windstation(subnet)
% [windstation, pfexists] = subnetpf2windstation(subnet)


print_debug(sprintf('> %s', mfilename),5)

% open pointer to subnet parameter file
[ps, pfexists]=openPointerToSubnet(subnet);

if pfexists

	% read the windstation
	windstation = 'nowind';
	try
		windstation = pfget(ps,'windstation');
	catch
		windstation = 'nowind';
	end

else

	windstation = 'nowind';
end
print_debug(sprintf('< %s', mfilename),5)
