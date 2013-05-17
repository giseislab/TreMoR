function onemin = stationmeasure2onemin(station, snum, enum, measure, datadir);
% onemin = stationmeasure2onemin(station, snum, enum, measure, datadir)
%
% station is like station().name
%
% each member of onemin() is like
% 	onemin.dnum 
%	onemin.data
%	onemin.datafound
%	onemin.station.name
%	onemin.subnet
%	onemin.snum
%	onemin.enum
%	onemin.measure
%
print_debug(sprintf('> %s', mfilename),1)

if ~iscell(measure)
    measure = {measure};
end

c=1;
for stationNum=1:length(station)
    for measureNum=1:length(measure)
        try 
            onemin(c) = loadbob( station(stationNum), snum, enum, measure{measureNum}, datadir);
        catch
            onemin(c) = loadwfmeas(station(stationNum), snum, enum, measure{measureNum}); % should perhaps move reduced part to a higher level in plotting routine
        end
        if (length(onemin(c).data)<2)
            %onemin(c).use = false;
            print_debug(sprintf('%s: No data for %s for measure %s from data directory %s',mfilename, station(stationNum).name, measure{measureNum}, datadir),2);
        else
            %onemin(c).use = true;
        end
        c=c+1;
    end
end

print_debug(sprintf('< %s', mfilename),1)

