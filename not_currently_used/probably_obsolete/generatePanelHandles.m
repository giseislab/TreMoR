function h = generatePanelHandles(numgraphs, onepanel)
% h = generatePanelHandles(numgraphs, onePanel)
for c = numgraphs:-1:1
	if onepanel == 0
		[frame1pos, frame2pos] = calculatePanelPositions(numgraphs, numgraphs-c+1, 1, 0.8, 0.8);
	else
		frame1pos = [0.1 0.1 0.8 0.8];
	end
	h(c) = axes('position',frame1pos);
end
