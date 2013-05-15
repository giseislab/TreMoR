function [v] = avovolcs2volcanoes(pffile)
print_debug(sprintf('> %s', mfilename),4)

if ~exist('pffile', 'var') 
	pffile=(['pf/avo_volcs.pf']);
end
if exist(pffile, 'file')
    
	
	print_debug(sprintf('Trying to read %s\n', pffile),2)
	A=importdata(pffile);
    for c=1:length(A.textdata)
        v{c} = underscore2camelcase(A.textdata{c});
    end
else
	error(sprintf('%s: %s does not exist',mfilename, pffile));
end

print_debug(sprintf('< %s', mfilename),4)


function str = underscore2camelcase(str)
str = strcat(str(1) ,regexprep(str(2:end), '_', '') );



