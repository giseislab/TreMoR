function summariseWaveformMat(filename, snum, enum, subnet)
disp(sprintf('\n***** New waveform *****'));
fprintf('file=%s\n',filename);
disp(sprintf('Start time is %s UTC',datestr(snum)));
disp(sprintf('End time is %s UTC',datestr(enum)));
