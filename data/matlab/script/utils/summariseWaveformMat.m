function summariseWaveformMat(filename, snum, enum, subnet)
disp(sprintf('** waveform loaded **'));
%fprintf('file=%s\n',filename);
disp(sprintf('Start time is %s UTC',datestr(snum)));
disp(sprintf('End time is %s UTC',datestr(enum)));
