function alarm = tremoralarmsummary2alarm(subnet, alarmtype)
disp('> tremoralarmsummary2alarm');

% load data
eval(sprintf('load /home/glenn/db/alarms/%s/summary/%s.dat;',alarmtype, subnet));
eval(sprintf('alarmlog = %s;',subnet));
alarm.dnum = alarmlog(:,1);
alarm.usedtriggers = alarmlog(:,2);
alarm.alltriggers = alarmlog(:,3);

disp('< tremoralarmsummary2alarm');
