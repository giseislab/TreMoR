function logbenchmark(modulename, numsecs)
benchmarklock = 'logs/benchmark.lock';
benchmarkfile = 'logs/benchmark.txt';
while exist(benchmarklock, 'file')
	pause(0.01);
end
system(sprintf('touch %s',benchmarklock));
fbench = fopen(benchmarkfile, 'a');
fprintf(fbench, '%s\t%s\t%.1f\n',datestr(now,31),modulename, numsecs);
fclose(fbench);
delete(benchmarklock);


