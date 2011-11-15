function result = saveImageFile(arg1, arg2, arg3);
% saveImageFile(IMGDIR, fname, res);
% saveImageFile(IMGFULLFILEPATH, res);
% A good value for res is 60 or 70
result = 0;
switch nargin
	case 2,
		[fname, IMGDIR] = basename(arg1); 
		outpath = arg1;
		res = arg2;
	case 3,	
		[IMGDIR, fname] = deal(arg1, arg2);
		outpath = catpath(arg1, sprintf('%s.png',arg2));
		res = arg3;
 	otherwise return;
end
res = 200;

if ~exist(IMGDIR,'dir')
	mkdir(IMGDIR);
end

try
	print(gcf, '-dpng', sprintf('-r%d',res), outpath );
	if exist(outpath, 'file')
		print_debug(sprintf('Saved image file %s',outpath),2);
		result = 1;
	else
		print_debug(sprintf('Failed to save image file %s',outpath),0);
	end
catch
	disp(sprintf('Could not save the image file %s',outpath));
end


