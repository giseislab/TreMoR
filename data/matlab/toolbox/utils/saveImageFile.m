function result = saveImageFile(arg1, arg2, arg3);
% saveImageFile(IMGDIR, fname, res);
% saveImageFile(IMGFULLFILEPATH, res);
% res=200 for spectrograms
global paths PARAMS; % we need to knwo the value of PARAMS.mode
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

if ~exist(IMGDIR,'dir')
	mkdir(IMGDIR);
end

try
	% Save the image file
	print(gcf, '-dpng', sprintf('-r%d',res), outpath );

	% Lock the output directory if in archive mode - it means we do not want to delete these files ever
	if strcmp('PARAMS.mode','archive') 
		system(sprintf('touch %s/lock',IMGDIR));
	end

	% Did our image file actually get saved?
	if exist(outpath, 'file')
		print_debug(sprintf('Saved image file %s',outpath),2);
		result = 1;
	else
		print_debug(sprintf('Image file %s was not created',outpath),0);
	end
catch
	disp(sprintf('Could not save the image file %s',outpath));
end


