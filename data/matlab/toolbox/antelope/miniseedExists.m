function [scnltoget,mseedStatus] = miniseedExists(ds, scnl, snum, enum)
scnltoget=[];
mseedStatus=[];
for c=1:length(scnl)
	mseedStatus(c).scnl=scnl(c);
	mseedStatus(c).filepath{1}='';
	mseedStatus(c).exists{1}=false;
	mseedStatus(c).dbname = getfilename(ds, scnl(c), snum); 
	if exist(mseedStatus(c).dbname, 'file')
		db=dbopen(mseedStatus(c).dbname,'r');
		db=dbopen_table(db,'wfdisc');
		expr = sprintf('sta=="%s" && chan=="%s" && time <= %f && endtime >= %f',get(ds,'station'),get(ds,'chan'),datenum2epoch(snum),datenum2epoch(snum));
		db=dbselect(db,expr);
		nrecs = dbquery(db, 'dbRECORD_COUNT');
		if nrecs>0
			[dir, dfile] = dbgetv(db, 'dir', 'dfile');
			for k=1:nrecs
				mseedStatus(c).filepath{k} = sprintf('%s/%s',dir{k},dfile{k});
				mseedStatus(c).exists(k) = exist(mseedStatus(c).filepath{k}, 'file');
			end
		else
			fprintf('no records selected for %s matching %s\n',mseedStatus(c).dbname, expr);
		end
	else
		fprintf('database %s not found\n',mseedStatus(c).dbname);
	end
	if mean(mseedStatus(c).exists) == 1 
		scnltoget = [scnltoget scnl(c)];
	end
end

			
