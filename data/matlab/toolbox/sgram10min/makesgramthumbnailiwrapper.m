d = dir('www/plots/sp');
for c=1:length(d)
	try
		d2 = dir(sprintf('www/plots/sp/%s/2011/06/03/*.png',d(c).name));
		for cc=1:length(d2)
			d2(cc).name
			makesgramthumbnail(sprintf('www/plots/sp/%s/2011/06/03/%s',d(c).name, d2(cc).name));
		end
	end
end

