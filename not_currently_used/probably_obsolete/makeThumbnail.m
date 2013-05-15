function makeThumbnail(spthumbfile)
%try 
	% create a small png if possible
	title(' '); 
	set(gcf,'numbertitle','off');

	removetraces;
	
	ax=get(gcf, 'Children');
	numpanels = length(ax);

	% when -nodisplay the -r option is ignored and 72dpi resolution is used.
	% So to get a 96x150 px image, I need to use a height of the figure of 150/72 inches
	% To get consistent results when there is a display, I would need to use -r72
	% Note: this suggests that to get high resolution images, I might want to set a large size (in inches) for the spectrogram image and print it at 72 dpi. Then image resize it, and image resize the thumbnail. 

	set(gcf, 'PaperPosition', [0.25 0.25 96/72 150/72]);
	saveImageFile(spthumbfile, 72);
%catch
%	disp('Could not create thumbnail image');
%end
	

	


