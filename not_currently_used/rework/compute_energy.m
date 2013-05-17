function compute_energy(subnet, sta, chan, snum, enum)
station.name = sta;
station.channel = chan;

global paths
icewebpaths;
measure = {'Energy'};
ButtonName = 'Yes';
while strcmp(ButtonName,'Yes'),
    close all;
    [fh,ah,onemin]=plotoneminwrapper(subnet, station, snum, enum, measure, 'despikeOn', true, ...
    'downsampleOn', false, 'reduceOn', false, 'remove_calibs', false, 'correctOn', false, 'wavetype', 'surface', 'panelperstation', true);
    suptitle('total energy per minute');
    disp('use left mouse button to select time range of interest, any other mouse button will quit');
    [x, y, button] = ginput(2);
    if button(1)~=1 | button(2)~=1
        break;
    end
    i = find(onemin.dnum >= x(1) & onemin.dnum <= x(2));
    totalenergy = cumsum(onemin.data(i));
    figure;
    sel_snum=onemin.dnum(i(1));
    sel_enum=onemin.dnum(i(end));
    plot(onemin.dnum(i), totalenergy);
    suptitle('total energy per minute');
    datetick('x');
    disp(sprintf('\nStation = %s, Channel=%s',station.name, station.channel));
    disp(sprintf('Time Range: %s to %s', datestr(sel_snum,31), datestr(sel_enum,31) ));
    disp(sprintf('\tCumulative Energy: %f', totalenergy(end)  ));
    measures={'Dmax';'Drms';'Dstd';'Dmean';'Dmedian'};
    [fh,ah,onemin2]=plotoneminwrapper(subnet, station, sel_snum, sel_enum, measures, 'despikeOn', true, ...
    'downsampleOn', false, 'reduceOn', false, 'remove_calibs', false, 'correctOn', false, 'wavetype', 'surface', 'panelperstation', true);
    [fh,ah,onemin3]=plotoneminwrapper(subnet, station, sel_snum, sel_enum, measures, 'despikeOn', true, ...
    'downsampleOn', false, 'reduceOn', true, 'remove_calibs', false, 'correctOn', true, 'wavetype', 'surface', 'panelperstation', true);

    ButtonName = questdlg('Another go?', ...
                         mfilename, ...
                         'Yes', 'No', 'No');
end

