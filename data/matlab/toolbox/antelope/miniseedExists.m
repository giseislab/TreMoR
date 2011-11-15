function scnlfound=miniseedExists(ds, scnl, snum, enum)
print_debug(sprintf('> %s',mfilename),6);
scnlfound = [];
for c=1:length(scnl)
	print_debug(sprintf('Calling listMiniseedFiles for %s.%s',get(scnl(c),'station'),get(scnl(c),'channel')),5);
	mseedfiles = listMiniseedFiles(ds, scnl(c), snum, enum);
	try	
    		if(getpref('runmode', 'debug') >= 5)
			for k=1:length(mseedfiles)
				f=mseedfiles(k).filepath;
				for m=1:length(f)
					print_debug(sprintf('MiniSEED file: %s',f{m}),5);
				end
			end
		end
	end
	if mean([mseedfiles.exists])==2
		scnlfound = [scnlfound scnl(c)];
	end
end
print_debug(sprintf('< %s',mfilename),6);
