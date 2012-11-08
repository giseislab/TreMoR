function [bname,dname,base,ext]=basename(fullpath);
% Glenn Thompson March 2003
% This function is designed to mimic the Basename module in Perl
% [bname,dname]=basename(fullpath);
% Related functions:
%   catpath;
% This is now largely redundant since MATLAB now includes
% fileparts and fullfile (see also filesep).
i1=findstr(fullpath,'\');
i2=findstr(fullpath,'/');
i = sort([i1 i2]);
if length(i)>0
    l0=i(end);
    l1=length(fullpath);
    bname=fullpath(l0+1:l1);
    dname=fullpath(1:l0-1);
else
    bname = fullpath;
    dname = '';
end
i = findstr(bname, '.');
if length(i)>0
    base = bname(1:i(end)-1);
    ext = bname(i(end)+1:end);
else
    base = bname;
    ext = '';
end
return;

% This whole function could now be replicated by:
function [filename, dirname, fileroot, fileext] = basename(fullpath)
[dirname, filename, ext] = fileparts(fullpath);

fileroot = filename; fileext = '';
i = findstr(filename, '.');
if length(i)>0
        fileroot = filename(1:i(end)-1);
        fileext = filename(i(end)+1:end);
end
