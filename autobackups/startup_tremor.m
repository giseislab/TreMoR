warning off;
matlab_antelope=getenv('MATLAB_ANTELOPE');
addpath(genpath(matlab_antelope));
addpath(genpath('GISMO'));
%tremor_home = getenv('TREMOR_HOME');
%addpath(tremor_home);
%chdir(tremor_home);
addpath(genpath('matlab'));
rmpath('matlab/toolbox/TreMoR/setup/obsolete');
rmpath('matlab/toolbox/libOther/obsolete');
javaaddpath('lib/swarm.jar');
javaaddpath('lib/usgs.jar');
javaaddpath('lib/swarm-bin.jar');


