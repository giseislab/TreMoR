function utdnum=get_utnow()
% Running under rtexec/rtrun_matlab on coho I found a new problem on
% 31/05/2011. now returns UT time, so utnow is in the future. Consequently,
% get_timewindow returns a time slice for loading waveform data that does
% not exist.
% So I need to add a check here against local system time.
[status, unixnowstr] = system('date +"%Y-%m-%d %H:%M:%S"');
unixnow = datenum(unixnowstr);
[status, unixnowTZ] = system('date +"%Z"'); 
unixnowTZ = unixnowTZ(1:end-1); % chomp
switch unixnowTZ
    case 'AKDT'
        utdnum = unixnow + 8/24;
    case 'AKST'
        utdnum = unixnow + 9/24;
    otherwise
        utdnum = unixnow;
end
% old code below
%dnumnow = now;
%timediff=dnumnow-datenum(zepoch2str(datenum2epoch(dnumnow), '%D %H:%M', 'US/Alaska'));
%utdnum = dnumnow + timediff;

