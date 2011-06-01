function [spectrogramPosition, tracePosition] = calculateFramePositions(numframes, frameNum, spectrogramFraction, panelWidth, panelHeight);
% [spectrogramPosition, tracePosition] = calculateFramePositions(numframes, frameNum, spectrogramFraction, panelWidth, panelHeight)
% Glenn Thompson, 1998-2009

frameHeight 		= panelHeight/numframes;
spectrogramHeight 	= spectrogramFraction * frameHeight;
traceHeight 		= (1 - spectrogramFraction) * frameHeight; 
panelLeft		= (1 - panelWidth)/2;
panelBase		= 0.03 + (1 - panelHeight)/2;
spectrogramPosition 	= [panelLeft, panelBase + (frameHeight * (frameNum - 1)), panelWidth, spectrogramHeight];
tracePosition 		= [panelLeft, panelBase + (frameHeight * (frameNum - 1)) + spectrogramHeight, panelWidth, traceHeight];

