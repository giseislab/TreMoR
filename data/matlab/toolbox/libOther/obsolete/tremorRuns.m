function tremorRuns(subnet, snum, enum, timestep_in_minutes);
outfile = 'tremor_runs.mat';
eval(['load ',outfile]);
num_trs = length(trs);
[paths, PARAMS]=pf2PARAMS;
while num_trs > 0
	this_trs = trs(1);
	len_snum = length(this_trs.snum);
	if len_snum > 0
        tic;
	% THIS WHOLE PROGRAM HAS TO BE RETHOUGHT SINCE WE NOW LOAD FROM RUNTIME.MAT and HVAE REPLACED ICEWEB2 WITH TREMOR	
    	%tremor(pwd, this_trs.subnet, 'mode', this_trs.mode, 'snum', this_trs.snum(1), 'enum', this_trs.enum(1));
        toc;
		if len_snum > 1
			this_trs.snum = this_trs.snum(2:end);
			this_trs.enum = this_trs.enum(2:end);
		else
			this_trs.snum = [];
			this_trs.enum = [];
		end
		trs(1) = this_trs;
	else
		trs = trs(2:end);
		num_trs = length(trs);
	end
	eval(['save ',outfile,' trs']);
		
end
