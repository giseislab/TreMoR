function scnl=station2scnl(station)
for c = 1 : length(station)
	scnl(c) = scnlobject(station(c).name, station(c).channel);
end