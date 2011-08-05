function onemin=durationAmplitudeWrapper2(snum, enum)
global paths subnets
load /scratch/run/TreMoR/pf/runtime.mat
si = find(strcmp({subnets.name}, 'Redoubt'));
subnets = subnets(si);
numstations = length({subnets.stations.name});
%[subnets, numstations] = subnetsetup('Redoubt', pwd );
measure = 'Drms';
[fh,ah,onemin]=plotsamwrapper(subnets.name, subnets.stations, snum, enum, measure, 'despikeOn', true, 'downsampleOn', false, 'correctOn', true, 'reduceOn', true);
setappdata(fh,'onemin',onemin);
%datetick('x',3,'keeplimits');
datetickgt;
pos=get(fh,'Position')
for c=1:numstations
    frac = (numstations-c)/numstations;
    pos_cbh = [pos(3)*.9 pos(4)*frac*0.8+130 130 20]
    %pos_cbh = [90 20*c 130 20]
    cbh(c) = uicontrol(fh,'Style','checkbox',...
                'String',subnets.stations(c).name,...
                'Value',onemin(c).use,'Position',pos_cbh);
    set(cbh(c),'Callback',{@cbh_Callback, c, fh});
end
pbh1 = uicontrol(fh,'Style','pushbutton','String','Exponential law',...
                'Position',[200 0 200 40]);
set(pbh1,'Callback',{@pbh_Callback,fh,'exponential'});
pbh2 = uicontrol(fh,'Style','pushbutton','String','Power law',...
                'Position',[400 0 200 40]);
set(pbh2,'Callback',{@pbh_Callback,fh,'power'});


function onemin = cbh_Callback(hObject,eventdata,c, fh)
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

function pbh_Callback(hObject,eventdata, fh, law)
lambda=durationAmplitude(getappdata(fh,'onemin'), law);

