function makeThumbnail(spthumbfile)
%try 
	% create a small png if possible
	title(' '); 
	set(gcf,'numbertitle','off');
	
	ax=get(gcf, 'Children');
	numpanels = length(ax);

	% First remove all labels and titles 
	for c=1:numpanels

		% remove all labels - we don't want those in the thumbnail
		set(ax(c),'XTickLabel',[''],'YTickLabel',['']);
		set(get(ax(c),'YLabel'),'String','');	
		set(get(ax(c),'XLabel'),'String','');	
		set(get(ax(c),'Title'),'String','');	
	end

	% Next remove all trace panels
	for c=1:numpanels/2
	        set(ax(c), 'Visible', 'off')
	        grandchildren = get(ax(c), 'Children');
	        set(grandchildren, 'Visible', 'off')
	end

	% Now maximise the spectrogram panels
	h = 2/numpanels;
	for c=numpanels/2+1:numpanels
	        pos = get(ax(c), 'position');
	        set(ax(c), 'position', [0 (c-1/h-1)*h 1 h] )
	end
	
	%get(gcf, 'PaperPosition'); % [0.25 0.25 8 10.5]
	%set(gcf, 'PaperPosition', [0.25 0.25 .96 1.5]); % when display on
	set(gcf, 'PaperPosition', [0.25 0.25 1.3356 2.0834]); % when display off
	saveImageFile(spthumbfile, 100);
%catch
%	disp('Could not create thumbnail image');
%end
	

	


