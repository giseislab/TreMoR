function most_picked_channels(db, expr)
load pf/tremor_runtime.mat
for c=1:numel(subnets)
	fprintf('\n*** SUBNET %s ****\n',subnets(c).name);
	for cc=1:numel(subnets(c).stations)
		sta = subnets(c).stations(cc).name;
		chan = subnets(c).stations(cc).channel;
		dist = subnets(c).stations(cc).distance;
		if exist('expr','var')
			expr2 = sprintf('(%s) && (sta=~/%s/ && chan=~/%s/) ',expr,sta,chan);
		
		else	
			expr2 = sprintf('sta=~/%s/ && chan=~/%s/ ',sta,chan);
		end
		a = arrivals_load(db, expr2);
		disp(sprintf('%s.%s:\tpicks=%4d\tkm=%4.1f',sta,chan,length(a.arid),dist));
	end
end

