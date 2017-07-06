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
% Version: 1.1
% Last Modified: June 30, 2017
%
% Revision History:
%   1.0 - Initial Release
%   1.1 - Adapted loop to check cell contents and generalize axes processing

%% Open the figure and not display it
fig = openfig(figureFile, 'new', 'invisible');


%% Get the axis object and then pull the data from it
ax = get(fig, 'CurrentAxes');
if ( isempty(ax) )
    error('Figure contains no axis.');
end

data = get(ax, 'Children');

axesData.x = get(data, 'XData');
axesData.y = get(data, 'YData');
axesData.z = get(data, 'ZData');

%% Get the legend entries
lgnd = get(ax, 'Legend');
lgndText = get(lgnd, 'String');

%% Make data series
[numSeries, numPoints] = size(axesData.x);
disp(['Extracting ', num2str(numSeries), ' data series in figure ', figureFile]);
seriesData.numSeries = numSeries;

axes = ['x', 'y', 'z'];
for (i=1:1:numSeries)
    seriesData.(['series', num2str(i)]).name = lgndText{numSeries-i+1};
    
    % Iterate over each axes
    for (j=1:1:length(axes))
        
        % Extract the axes data
        if iscell( axesData.(axes(j)) )
            doubleData = double( axesData.(axes(j)){i} );
        else
            doubleData = double( axesData.(axes(j)) );
        end
        
        % Check if there is data
        [gar, si] = size(doubleData);
        if si ~= 0
            seriesData.(['series', num2str(i)]).(axes(j)) = doubleData;
            
            % Pull out the legend entry
            legEntry = get(get(ax, [upper( axes(j) ), 'Label']), 'String');
            if ischar(legEntry)
                seriesData.([axes(j), 'label']) = legEntry;
            else
                seriesData.([axes(j), 'label']) = cell2mat(legEntry);
            end
        end
    end
end

end

