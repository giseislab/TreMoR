function logbenchmark(modulename, numsecs)
modulename = regexprep(modulename,'[^\w'']','_');
benchmarklock = sprintf('logs/benchmark_%s.lock',modulename);
benchmarkfile = sprintf('logs/benchmark_%s.txt',modulename);
while exist(benchmarklock, 'file')
	pause(0.01);
end
system(sprintf('touch %s',benchmarklock));
fbench = fopen(benchmarkfile, 'a');
fprintf(fbench, '%f\t%.1f\n',now, numsecs);
fclose(fbench);
delete(benchmarklock);


