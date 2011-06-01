function gui_plotoneminwrapper(snum, enum)
global paths 

% Set defaults
[subnets, numstations] = subnetsetup('Redoubt', pwd );
measure = 'Vmedian';

% Get and plot 1 minute data
[fh,ah,onemin]=plotoneminwrapper(subnets.name, subnets.stations, snum, enum, measure, 'despikeOn', false, 'downsampleOn', false, 'correctOn', false, 'reduceOn', false);
set(gcf,'MenuBar','none') 
%datetickgt(snum,enum);

% Add checkbox for each station/channel
%pos=get(fh,'Position')
%for c=1:numstations
%    frac = (numstations-c)/numstations;
%    pos_cbh = [pos(3)*.9 pos(4)*frac*0.8+70 130 20]
%    %pos_cbh = [90 20*c 130 20]
%    cbh(c) = uicontrol(fh,'Style','checkbox',...
%                'String',subnets.stations(c).name,...
%                'Value',onemin(c).use,'Position',pos_cbh);
%%end

stachanh = uimenu(fh, 'Label', 'Stations');
for c=1:numstations
    if onemin(c).use
        checked = 'on';
    else
        checked = 'off';
    end
    uimenu(stachanh, 'Label', subnets.stations(c).name, 'Callback', {@stachan_callback, c, fh}, 'Checked', checked)    
end


% Data menu
datamh = uimenu(fh, 'Label', 'Data')

% Measurement
mmh = uimenu(datamh, 'Label', 'Measurement');
vmh = uimenu(mmh, 'Label', 'Velocity');
uimenu(vmh, 'Label', 'Maximum', 'Callback', {@measure_callback, 'Vmax',0,fh});
uimenu(vmh, 'Label', 'Median', 'Callback', {@measure_callback, 'Vmedian',0,fh});
uimenu(mmh, 'Label', 'Energy', 'Callback', {@measure_callback, 'Energy',0,fh});
fmh = uimenu(mmh, 'Label', 'Frequency');
uimenu(fmh, 'Label', 'Mean', 'Callback',{@measure_callback, 'meanf',0,fh});
uimenu(fmh, 'Label', 'Peak', 'Callback',{@measure_callback, 'peakf',0,fh});
dmh = uimenu(mmh, 'Label', 'Displacement');
uimenu(dmh, 'Label', 'RMS', 'Callback',{@measure_callback, 'Drms',0,fh});
uimenu(dmh, 'Label', 'Standard Deviation', 'Callback',{@measure_callback, 'Dstd',0,fh});
uimenu(dmh, 'Label', 'Maximum', 'Callback',{@measure_callback, 'Dmax',0,fh});
uimenu(dmh, 'Label', 'Mean', 'Callback',{@measure_callback, 'Dmean',0,fh});
uimenu(dmh,'Label', 'Median', 'Callback',{@measure_callback, 'Dmedian',0,fh});
uimenu(dmh, 'Label', '68th percentile', 'Callback',{@measure_callback, 'D68',0,fh});
drmh = uimenu(mmh, 'Label', 'Reduced Displacement');
uimenu(drmh, 'Label', 'RMS', 'Callback',{@measure_callback, 'Drms',1,fh});
uimenu(drmh, 'Label', 'Standard Deviation', 'Callback',{@measure_callback, 'Dstd',1,fh});
uimenu(drmh, 'Label', 'Maximum', 'Callback',{@measure_callback, 'Dmax',1,fh});
uimenu(drmh, 'Label', 'Mean', 'Callback',{@measure_callback, 'Dmean',1,fh});
uimenu(drmh,'Label', 'Median', 'Callback',{@measure_callback, 'Dmedian',1,fh});
uimenu(drmh, 'Label', '68th percentile', 'Callback',{@measure_callback, 'D68',1,fh});

% Options
omh = uimenu(datamh, 'Label', 'Options');
uimenu(omh, 'Label', 'Despike','Callback',{@toggledespike_callback,fh});
uimenu(omh, 'Label', 'Downsample','Callback',{@toggledownsample_callback,fh});
uimenu(omh, 'Label', 'Correct','Callback',{@togglecorrect_callback,fh});

% Load
lmh = uimenu(datamh, 'Label', 'Load', 'Callback', {@load1minutedata_callback, fh});

% Plot menu
pmh = uimenu(fh, 'Label', 'Plot', 'Callback', {@plot1minutedata_callback, fh});

% Add menu for duration-amplitude
setappdata(fh,'onemin',onemin);
damh = uimenu(fh, 'Label', 'Duration-Amplitude');
uimenu(damh, 'Label', 'Exponential Law', 'Callback', {@explaw_callback,fh});
uimenu(damh, 'Label', 'Power Law','Callback',{@powlaw_callback,fh});

function stachan_callback(hObject, eventdata, c, fh)
% Manage stachan checkboxes
onemin=getappdata(fh,'onemin');
if (onemin(c).use == false)
   disp(sprintf('stachan %s selected',onemin(c).station.name))
   onemin(c).use = true;
   set(hObject,'Checked','on');
else
   disp(sprintf('stachan %s deselected',onemin(c).station.name))
   onemin(c).use = false;
   set(hObject,'Checked','off');
end
setappdata(fh,'onemin',onemin);

function measure_callback(hObject, eventdata, measure, reduceOn, fh)
onemin=getappdata(fh,'onemin');
measure
onemin.measure
onemin.measure = measure;
set(hObject, 'Checked', 'on');
set(onemin.hPrevMeasure, 'Checked', 'off')
onemin.hPrevMeasure = hObject;
onemin.dataoptions.reduceOn = reduceOn;
setappdata(fh,'onemin',onemin);

function toggledespike_callback(hObject, eventdata, fh)
onemin=getappdata(fh,'onemin');
if onemin.dataoptions.despikeOn
    set(hObject, 'Checked', 'off');
    onemin.dataoptions.despikeOn = false;
else
    set(hObject, 'Checked', 'on');
    onemin.dataoptions.despikeOn = true;    
end 
setappdata(fh,'onemin',onemin);

function toggledownsample_callback(hObject, eventdata, fh)
onemin=getappdata(fh,'onemin');
if onemin.dataoptions.downsampleOn
    set(hObject, 'Checked', 'off');
    onemin.dataoptions.downsampleOn = false;
else
    set(hObject, 'Checked', 'on');
    onemin.dataoptions.downsampleOn = true;    
end 
setappdata(fh,'onemin',onemin);

function togglecorrect_callback(hObject, eventdata, fh)
onemin=getappdata(fh,'onemin');
if onemin.dataoptions.correctOn
    set(hObject, 'Checked', 'off');
    onemin.dataoptions.correctOn = false;
else
    set(hObject, 'Checked', 'on');
    onemin.dataoptions.correctOn = true;    
end 
setappdata(fh,'onemin',onemin);

function cbh_Callback(hObject,eventdata,c, fh)
% Manage channel checkboxes
onemin=getappdata(fh,'onemin');
if (get(hObject,'Value') == get(hObject,'Max'))
   % Checkbox is checked-take appropriate action
   disp(sprintf('checkbox %d selected',c))
   onemin(c).use = true;
else
   % Checkbox is not checked-take appropriate action
   disp(sprintf('checkbox %d deselected',c))
   onemin(c).use = false;
end
setappdata(fh,'onemin',onemin);

function explaw_callback(hObject,eventdata, fh)
% Duration Amplitude - exponential law
lambda = durationAmplitude(getappdata(fh,'onemin'));

function powlaw_callback(hObject,eventdata, fh)
% Duration Amplitude - power law 
gamma = durationAmplitudePowerLaw(getappdata(fh,'onemin'));


%datetick('x',3,'keeplimits');