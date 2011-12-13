function scnl=station2scnl(station, network)
for c = 1 : length(station)
	if exist('network','var')
		scnl(c) = scnlobject(station(c).name, station(c).channel, network);
	else

		scnl(c) = scnlobject(station(c).name, station(c).channel);
	end
end
