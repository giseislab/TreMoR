function benchmarkplot()
d = dir('logs/benchmark_*.txt');
ncols = 2;
nrows = 1 + floor(numel(d)/2);

for c=1:numel(d)
        a = load(sprintf('logs/%s',d(c).name));
	subplot(nrows, ncols, c), plot(a(:,1), a(:,2), 'o');
	datetick('x');
	title(strrep(strrep(strrep(d(c).name, '_', ' '),'benchmark',''),'.txt',''));
end
suptitle('TreMoR benchmark stats');
saveImageFile('www/plots/benchmarkplots.png', 500);
