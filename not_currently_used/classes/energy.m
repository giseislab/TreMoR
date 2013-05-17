classdef energy
	properties
		data = [];
		units = '';
		totalenergy = 0;
		duration = 0;
		meanpower = 0;
		maxpower = 0;
	end

	methods
		function self = energy(x, r, channel, Fs, units) 
			if isempty(r)
				r=1000; % assume 1 km
				warning('No distance argument, so using default of 1000 m');
			end
    			% Scale factor to convert to real energy units (J)
    			if strfind(channel, 'BD')
				if strcmp(units, 'Pa')
        				% pressure sensor - spherical waves
        				rho_air = 1.2; % kg/m3
        				c_air = 320; % m/s
        				scale_factor = (4 * pi * r^2)/(c_air * rho_air);
				else
					error(sprintf('Units %s not recognised for pressure',units));
				end
    			else
        			% seismometer - assuming body waves
				if strfind(units, 'nm')
        				rho_earth = 2500; % kg/m3
        				c_earth = 3000; % m/s
        				scale_factor = (4 * pi * r^2)*(c_earth * rho_earth)*1e-18; % 1e-18 converts from (nm/s)^2 to (m/s)^2
				else
					error(sprintf('Units %s not recognised for seismogram',units));
				end
			end
    			self.units = 'J';
			watts = (x.*x) * scale_factor;
			e = cumsum(watts)/Fs;
			self.totalenergy = max(e) - min(e); % J
			self.duration = (length(e)/Fs); % s
			self.meanpower = mean(watts); % W
			self.maxpower = max(watts); % W
			self.data = e;
		end
    end
end
