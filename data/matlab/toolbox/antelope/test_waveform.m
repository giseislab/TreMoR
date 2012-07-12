chdir('~/run');
startup_tremor;	
scnl(1) = scnlobject('CP2', 'EHZ', 'AV', '--');
%scnl(2) = scnlobject('BGL', 'EHZ', 'AV', '--');
%scnl(3) = scnlobject('CKT', 'EHZ', 'AV', '--');
%scnl(4) = scnlobject('CKL', 'EHZ', 'AV', '--');
%scnl(5) = scnlobject('NCG', 'EHZ', 'AV', '--');
%scnl(6) = scnlobject('SPU', 'EHZ', 'AV', '--');
ds = datasource('antelope', '/avort/devrun/db/archive')
w = waveform(ds, scnl, 734963.895833, 734963.902778);
