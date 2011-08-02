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


%volcano = camelcase2underscore(volcano);


print_debug(sprintf('< %s', mfilename),4)


