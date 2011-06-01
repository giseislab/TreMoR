function saveImageFile(arg1, arg2, arg3);
% saveImageFile(IMGDIR, fname, res);
% saveImageFile(IMGFULLFILEPATH, res);
% A good value for res is 60 or 70

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

IMGDIR
if ~exist(IMGDIR,'dir')
	mkdir(IMGDIR);
end

try
	print(gcf, '-dpng', sprintf('-r%d',res), outpath );
	%disp(sprintf('Saved image file %s',outpath));
catch
	disp(sprintf('Could not save the image file %s',outpath));
end


