function [panelPosition, tracePosition] = calculatePanelPositions(numframes, frameNum, fractionalPanelHeight, panelWidth, panelHeight);
%CALCULATEPANELPOSITIONS
% [panelPosition, tracePosition] = calculatePanelPositions(numframes, frameNum, fractionalPanelHeight, panelWidth, panelHeight)

% AUTHOR: Glenn Thompson, University of Alaska Fairbanks
% $Date$
% $Revision$

frameHeight 		= panelHeight/numframes;
fractionalAxesHeight 	= fractionalPanelHeight * frameHeight;
traceHeight 		= (1 - fractionalPanelHeight) * frameHeight; 
%panelLeft		= (1 - panelWidth)/2;
panelLeft		= 0.08;
panelBase		= 0.025 + (1 - panelHeight)/2;
panelPosition 	= [panelLeft, panelBase + (frameHeight * (frameNum - 1)), panelWidth, fractionalAxesHeight];
tracePosition 		= [panelLeft, panelBase + (frameHeight * (frameNum - 1)) + fractionalAxesHeight, panelWidth, traceHeight];

