function errorCode=icewebpaths(rundir)
% errorCode=icewebpaths()
% 2011-02-11: No longer uses paths.pf file. Instead uses local directories
% which can be symlinks. If those don't exist it will try environment
% variables.
% This makes this function independent of Antelope.

errorCode=0;

% global variables
global paths;
if ~exist('rundir','var')
    rundir=pwd;
end
paths.RUNDIR = rundir;

% path for parameter files
paths.PFS = catpath(paths.RUNDIR,'pf'); 

try

	% path for DERIVED DATA
	paths.ONEMINDATA = catpath(paths.RUNDIR, '1mindata');

	% path for web plots
	paths.WEBDIR = catpath(paths.RUNDIR, 'webplots'); % should change this name to paths.WEBPLOTS and remove "plots" from added paths
    
	% path to master station db
    	paths.DBMASTER = catpath(paths.RUNDIR, 'dbmaster', 'master_stations');
    	%if ~exist(paths.DBMASTER,'dir')
    	%    paths.DBMASTER = getenv('DBMASTER');
    	%end

	print_debug('paths setup OK',1);
    
catch exception
    disp(paths);
	disp(sprintf('%s: %s',mfilename, exception.message));
	errorCode = 1;
end  


