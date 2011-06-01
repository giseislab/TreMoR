function data = reduce1mindata(data, distance, measurement_type, wavetype, surface_wave_speed, f)
% data = reduce1mindata(data, distance, measurement_type, wavetype, surface_wave_speed, f)
% Take a derived waveform measurement_typement, then reduce it using body/surface wave spreading
% measurement_type = 'energy', 'displacement', or 'velocity'
% all measurements assumed to be in cm (not m, or nm).

% Note that this routine no longer corrects for old spectral method drs
% properly since that was already divided by frequency.

print_debug(sprintf('> %s', mfilename),4)
distance = distance * 100; % cm
if (~strcmp(measurement_type, 'energy'))
	% displacement
	if (strcmp(wavetype, 'body')) % body wave
        print_debug('Reducing assuming body wave displacement',4);
		data = data * distance ;
	else % surface wave
        print_debug('Reducing assuming surface wave displacement',4);
        wavelength = surface_wave_speed ./ f;
        try
            data = data .* sqrt(distance * wavelength); 
        catch
            print_debug('mean wavelength instead',5)
            data = data * sqrt(distance * mean(wavelength));             
        end
	end
else
	% energy
	if (strcmp(wavetype, 'body')) % body wave
        print_debug('Reducing assuming body wave energy',4);
		data = data * distance^2;
	else % surface wave - when energy was calculated, it was already divided by sqrt(f)
        print_debug('Reducing assuming surface wave energy',4);
		data = data .* (distance * wavelength); 
	end
	
end
print_debug(sprintf('< %s', mfilename),4)
