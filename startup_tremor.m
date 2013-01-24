warning off;
matlab_antelope=getenv('MATLAB_ANTELOPE');
addpath(genpath(matlab_antelope));
addpath(genpath('~/src/gismotools_new/GISMO'));
addpath('test');
%startup_volcseis;
tremor_home = getenv('TREMOR_HOME');
addpath(tremor_home);
chdir(tremor_home);
addpath(genpath('~/src/TreMoR/data/matlab'));
javaaddpath('/avort/modrun/lib/swarm.jar');
javaaddpath('/avort/modrun/lib/usgs.jar');
javaaddpath('/avort/modrun/lib/swarm-bin.jar');


