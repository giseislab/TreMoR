function samobject=durationAmplitudeWrapper2(snum, enum)
global paths subnets
load pf/runtime.mat
si = find(strcmp({subnets.name}, 'Redoubt'));
subnets = subnets(si);

measure = 'Drms';
[fh,ah,samobject]=plotsamwrapper(subnets.name, subnets.stations, snum, enum, measure, 'despikeOn', true, 'downsampleOn', false, 'correctOn', true, 'reduceOn', true);
numstations = numel(samobject)
setappdata(fh,'samobject',samobject);
if isempty(samobject)
    disp('No data found');
    return;
end
pos=get(fh,'Position');
sta = station(samobject);
use = [samobject.use];
for c=1:numstations
    frac = (numstations-c)/numstations;
    pos_cbh = [pos(3)*.9 pos(4)*frac*0.8+130 130 20];
    %pos_cbh = [90 20*c 130 20];
    cbh(c) = uicontrol(fh,'Style','checkbox',...
                'String',sta{c},...
                'Value',use(c),'Position',pos_cbh);
    set(cbh(c),'Callback',{@cbh_Callback, c, fh});
end
pbh1 = uicontrol(fh,'Style','pushbutton','String','Exponential law',...
                'Position',[200 0 200 40]);
set(pbh1,'Callback',{@pbh_Callback,fh,'exponential'});
pbh2 = uicontrol(fh,'Style','pushbutton','String','Power law',...
                'Position',[400 0 200 40]);
set(pbh2,'Callback',{@pbh_Callback,fh,'power'});


function samobject = cbh_Callback(hObject,eventdata,c, fh)
samobject=getappdata(fh,'samobject');
if (get(hObject,'Value') == get(hObject,'Max'))
   % Checkbox is checked-take appropriate action
   disp(sprintf('checkbox %d selected',c))
   samobject(c).use = true;
else
   % Checkbox is not checked-take appropriate action
   disp(sprintf('checkbox %d deselected',c))
   samobject(c).use = false;
end
setappdata(fh,'samobject',samobject);

function pbh_Callback(hObject,eventdata, fh, law)
lambda=durationAmplitude(getappdata(fh,'samobject'), law);

