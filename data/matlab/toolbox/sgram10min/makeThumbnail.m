function makeThumbnail(spthumbfile, timestamp)
%  makeThumbnail(spdir, timestamp)
try 
	% create a small png if possible
	title(' '); 
	set(gcf,'numbertitle','off');
	
	ax=get(gcf, 'Children');
	numpanels = length(ax);

	for c=1:numpanels
		% change panel positions to fill plot (spectrograms only, remove seismograms)
		%bottom = 1 - c/numpanels;
		%top = bottom + c/numpanels;
		%set(ax(c),'position',[0 bottom  1 top],'XTick',[], 'YTick', [],'box','off' )

		% remove all labels - we don't want those in the thumbnail
		set(ax(c),'XTickLabel',[''],'YTickLabel',['']);
		set(get(ax(c),'YLabel'),'String','');	
		set(get(ax(c),'XLabel'),'String','');	
		

	end

	%paths.ALCHEMY = '/usr/local/bin/alchemy';
	%eval(['!',paths.ALCHEMY, ' ',spfilename, ' -Zm2 -Zc1 -Zb 1i 1.6i 0.8i 0.9i -Zo 200p -Z+ ',spthumbname, ' ---n -o -Q']);
	%print(gcf, '-dpng', '-r19', spthumbfile);
	saveImageFile(spthumbfile, 19);
catch
	disp('Could not create thumbnail image');
end
	

	


