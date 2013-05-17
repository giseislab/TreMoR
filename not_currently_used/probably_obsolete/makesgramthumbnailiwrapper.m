global paths
d = dir(paths.spectrograms);
for c=1:length(d)
	try
		d2 = dir(sprintf('%s/%s/2011/06/03/*.png',spectrograms, d(c).name));
		for cc=1:length(d2)
			d2(cc).name
			makesgramthumbnail(sprintf('%s/%s/2011/06/03/%s',spectrograms, d(c).name, d2(cc).name));
		end
	end
end

