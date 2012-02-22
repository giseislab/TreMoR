function tenminspfile = getSgram10minName(subnet, enum)
global paths
timestamp = datestr(enum, 30);
%spdir = catpath(paths.WEBDIR, 'plots', 'sp', subnet, timestamp(1:4), timestamp(5:6), timestamp(7:8));
spdir = catpath(paths.spectrograms, subnet, timestamp(1:4), timestamp(5:6), timestamp(7:8));
tenminspfile = catpath(spdir, [timestamp, '.png']);
