function onemin_r=reduce_displacement(subnet, station, snum, enum, dispmeasure, datadir, wavetype)
station = db2stationdistances(subnet, station, snum);
onemin = stationmeasure2onemin(station, snum, enum, dispmeasure, datadir);
onemin_f = stationmeasure2onemin(station, snum, enum, 'peakf', datadir); % could also use meanf
wave_speed = 2000; % m/s

for c=1:length(onemin)
    if (c>1 && length(onemin_f)<length(onemin))
        onemin_f(c)=onemin_f(1);
    end
    if ~onemin_f(c).datafound
        onemin_f(c).data = 2.0 * ones(size(onemin(c).data));
    end
    if onemin(c).datafound
        %figure;
        %subplot(3,1,1),plot(onemin(c).dnum, onemin(c).data);
        %subplot(3,1,2),plot(onemin(c).dnum, onemin_f(c).data); 
        onemin_r(c) = onemin(c);
        onemin_r(c).data = reduce1mindata(onemin(c).data / 1e7, onemin(c).station.distance, 'displacement', wavetype, wave_speed * 100, onemin_f(c).data);
        %subplot(3,1,3),plot(onemin_r(c).dnum, onemin_r(c).data);
        onemin_r(c).measure = sprintf('D_R_S (cm^2) (from %s)',onemin_r(c).measure);
    end
end
