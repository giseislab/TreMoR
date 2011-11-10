warning off;
matlab_antelope=getenv('MATLAB_ANTELOPE');
addpath(genpath(matlab_antelope));
%startup_volcseis;
tremor_home = getenv('TREMOR_HOME');
if exist(tremor_home,'dir')
	addpath(tremor_home);
	chdir(tremor_home);
end
addpath(genpath('~/src/TreMoR/data/matlab'));
debug(0);


