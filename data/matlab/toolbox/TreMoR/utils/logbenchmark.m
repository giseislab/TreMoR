function logbenchmark(modulename, numsecs)
debug.printfunctionstack('>');
modulename = regexprep(modulename,'[^\w'']','_');
benchmarklock = sprintf('logs/benchmark_%s.lock',modulename);
benchmarkfile = sprintf('logs/benchmark_%s.txt',modulename);
timewaited=0;
while (exist(benchmarklock, 'file') & timewaited < 2.0)
	pause(0.1);
	timewaited = timewaited + 0.1;
end
system(sprintf('touch %s',benchmarklock));
fbench = fopen(benchmarkfile, 'a');
fprintf(fbench, '%f\t%.1f\n',now, numsecs);
fclose(fbench);
delete(benchmarklock);
debug.printfunctionstack('<');

