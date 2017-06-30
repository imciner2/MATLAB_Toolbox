function [ seriesData ] = ImportDataFromFigure( figureFile )
%IMPORTDATAFROMFIGURE Imports data from a MATLAB figure file
%
% This function reads in a MATLAB figure file and then extracts
% the datapoints on the 3 axes (X, Y, Z) if they exist.
%
% [ seriesData ] = ImportDataFromFigure( figureFile )
% 
% Inputs:
%   figureFile - Filename of the figure to import data from
%
% Outputs:
%   seriesData - Structure containing the series data from the figure
%
%
% Created by: Ian McInerney
% Created on: June 30, 2017
% Version: 1.0
% Last Modified: June 30, 2017
%
% Revision History:
%   1.0 - Initial Release

%% Open the figure and not display it
fig = openfig(figureFile, 'new', 'invisible');


%% Get the axis object and then pull the data from it
ax = get(fig, 'CurrentAxes');
if ( isempty(ax) )
    error('Figure contains no axis.');
end

data = get(ax, 'Children');

x = get(data, 'XData');
y = get(data, 'YData');
z = get(data, 'ZData');

%% Get the legend entries
lgnd = get(ax, 'Legend');
lgndText = get(lgnd, 'String');

%% Make data series
[numSeries, numPoints] = size(x);
disp(['Extracting ', num2str(numSeries), ' data series in figure ', figureFile]);
for (i=1:1:numSeries)
    seriesData.(['series', num2str(i)]).name = lgndText{i};
    
    % Extract the X axis data if there is any
    [gar, xSize] = size(x{i});
    if xSize ~= 0
        seriesData.(['series', num2str(i)]).x = cell2mat(x(i));
        seriesData.xlabel = cell2mat(get(get(ax, 'XLabel'), 'String'));
    end
   
    % Extract the Y axis data if there is any
    [gar, ySize] = size(y{i});
    if ySize ~= 0
        seriesData.(['series', num2str(i)]).y = cell2mat(y(i));
        seriesData.ylabel = cell2mat(get(get(ax, 'YLabel'), 'String'));
    end
    
    % Extract the Z axis data if there is any
    [gar, zSize] = size(z{i});
    if zSize ~= 0
        seriesData.(['series', num2str(i)]).z = cell2mat(z(i));
        seriesData.zlabel = cell2mat(get(get(data, 'ZLabel'), 'String'));
    end
end

end

