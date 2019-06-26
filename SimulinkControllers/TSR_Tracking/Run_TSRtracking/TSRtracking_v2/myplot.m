function [fig,p,ax] = myplot(y, varargin)
% This plots a figure using some personal plot settings. The inputs are identical to MATLAB's plot function.
%
% Nikhar Abbas


%% create figure, get properties
if ~isempty(varargin)
    p = plot(y,varargin{:});
else
    p = plot(y);
end


fig = gcf;
ax = gca;
%% Setup figure, plottining properties, and axis shenanigans
% Three parts/properties here: Figure, plot, and axis. The three parts can be
% modified to change the three primary properties


% % Figure
fig.Units = 'inches';
% figure size
width = 5; % inches
height = 3; % inches
fig.PaperPosition = [0 0 width height];
% fig.Position = fig.PaperPosition;

% Plot
if ~any(strcmpi('linewidth',varargin))  % defaults to thicker linewidth, unless otherwise defined
    for ip = 1:length(p)
        p(ip).LineWidth = 1.5;
    end
end

% Axis
ax.XGrid = 'on';
ax.YGrid = 'on';
ax.FontSize = 12;



% print('testfig', '-dpng', '-r300');


end

