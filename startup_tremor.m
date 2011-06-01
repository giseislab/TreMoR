disp('> startup_iceweb2')
matlab_antelope=getenv('MATLAB_ANTELOPE');
addpath(genpath(matlab_antelope));
%startup_volcseis;
iceweb2_home = getenv('ICEWEB2_HOME');
addpath(iceweb2_home);
chdir(iceweb2_home);
addpath(genpath(sprintf('%s/toolbox/',iceweb2_home)));
disp('< startup_iceweb');


