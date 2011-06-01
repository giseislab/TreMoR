function write2bob(dnum, data, filename)
% write2bob(dnum, data, filename)
%
% since dnum may not be ordered and contiguous, this function
% should write data based on dnum only
if length(dnum)~=length(data)
    disp(sprintf('%s: Cannot save to %s because data and time vectors are different lengths',mfilename,filename));
    size(dnum)
    size(data)
    return;
end

if length(data)<1
    disp('No data. Aborting');
	return;
end

datapointsperday = 1440;

% round times to minute
dnum = round((dnum-1/86400) * 1440) / 1440;

% find the next contiguous block of data
diff=dnum(2:end) - dnum(1:end-1);
i = find(diff > 1.5/1440 | diff < 0.5/1440);



if length(i)>0 % slow mode

    for c=1:length(dnum)

        % how many days in this year?
        d=datevec(dnum(c));
        yyyy=d(1);
        daysperyear = 365;
        if (mod(yyyy,4)==0)
            daysperyear = 366;
        end
    
        % filename
        fname = sprintf('%s_%d.bob',filename,yyyy);    
        if ~exist(fname,'file')
            print_debug(['Creating ',fname],2)
            make1minfile(fname, daysperyear);
        end
    
        % write the data
        startsample = round((dnum(c) - datenum(yyyy,1,1)) * datapointsperday);
        offset = startsample*4;
        fid = fopen(fname,'r+');
        fseek(fid,offset,'bof');
        print_debug(sprintf('saving to %s, position %d',fname,startsample),3)
        fwrite(fid,data(c),'float32');
        fclose(fid);
    end
else
    % fast mode
    
    % how many days in this year?
    d=datevec(dnum(1));
    yyyy=d(1);
    daysperyear = 365;
    if (mod(yyyy,4)==0)
        daysperyear = 366;
    end
    
    % filename
    fname = sprintf('%s_%d.bob',filename,yyyy);    
    if ~exist(fname,'file')
        print_debug(['Creating ',fname],2)
        make1minfile(fname, daysperyear);
    end    
        
    % write the data
    startsample = round((dnum(1) - datenum(yyyy,1,1)) * datapointsperday);
    offset = startsample*4;
    fid = fopen(fname,'r+','l'); % little-endian. Anything written on a PC is little-endian by default. Sun is big-endian.
    fseek(fid,offset,'bof');
    print_debug(sprintf('saving to %s, position %d of %d',fname,startsample,(datapointsperday*daysperyear)),3)
    fwrite(fid,data,'float32');
    fclose(fid);
        

end







