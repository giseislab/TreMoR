function waveform_tracker(w, subnet, snum, enum)

% Default qc structure is blank. This is overwritten on file load.
qc.snum = [];
qc.enum = [];
qc.ds = [];
qc.scnl = [];
qc.corrupt = [];
qc.numchannels = [];

% Create qc element for this (array of) waveform object(s)
qc0.numchannels = length(w);
qc0.snum = [];
qc0.enum = [];
qc0.scnl = [];
qc0.ds = [];
qc0.corrupt = 0;
if qc0.numchannels > 0
	qc0.snum = snum;
	qc0.enum = enum;
	qc0.station = get(w, 'station');
	qc0.channel = get(w, 'channel');
	qc0.ds = get(w, 'ds');
end

% Load statefile if it exists
statefile = sprintf('state/waveform_tracker_%s.mat',subnet);
if exist(statefile, 'file')
	eval(['load ',statefile]);
	% search for this snum,enum pair
	i = find(qc.snum == qc0.snum);
	switch length(i)
	case 1, % amend
		qc.scnl(i) = qc0.scnl;
		qc.ds(i) = qc0.ds;
		qc.numchannels = qc0.numchannels;
	case 0, % append
		qc.snum = [qc.snum qc0.snum];
		qc.enum = [qc.enum qc0.enum];
		qc.ds = [qc.ds qc0.ds];
		qc.scnl = [qc.scnl qc0.scnl];
		qc.corrupt = [qc.scnl qc0.scnl];
		qc.numchannels = [qc.numchannels qc0.numchannels];
	otherwise,
		disp('Houston, we have a problem!')
	end
end
eval(sprintf('save %s qc',statefile));


