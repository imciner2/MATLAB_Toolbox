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
% Version: 1.2
% Last Modified: July 18, 2017
%
% Revision History:
%   1.0 - Initial Release
%   1.1 - Adapted loop to check cell contents and generalize axes processing
%   1.2 - Adapted to work with subplots in a figure

%% Open the figure and not display it
fig = openfig(figureFile, 'new', 'invisible');


%% Get the axis objects
ax = get(fig, 'Children');
if ( isempty(ax) )
    error('Figure contains no axis.');
end

numPlots = length(ax);
axesTypes = strcmp( get(ax, 'type'), 'axes');
disp(['Extracting ', num2str( sum(axesTypes) ), ' subplots in figure ', figureFile]);


%% Iterate over the number of plots in the figure
currentPlot = 1;
for (k=1:1:numPlots)
    %% Make sure the child is actually an axes (sometimes legends show up here)
    if ( ~strcmp(get(ax(k), 'type'), 'axes') )
        continue
    end
    
    %% Extract the subplot title
    ti = get( ax(k), 'Title');
    tempData.title = get(ti, 'String');
    
    %% Get the data from the axes
    data = get(ax(k), 'Children');
    axesData.x = get(data, 'XData');
    axesData.y = get(data, 'YData');
    axesData.z = get(data, 'ZData');

    %% Get the legend entries (if it exists)
    lgnd = get(ax(k), 'Legend');
    if ( ~isempty(lgnd) )
        lgndText = get(lgnd, 'String');
    end

    %% Make data series
    [numSeries, numPoints] = size(axesData.x);
    disp(['Extracting ', num2str(numSeries), ' data series in subplot ', num2str(currentPlot), ' of figure ', figureFile]);
    tempData.numSeries = numSeries;

    axes = ['x', 'y', 'z'];
    for (i=1:1:numSeries)
        if exist('lgndText')
            tempData.(['series', num2str(i)]).name = lgndText{numSeries-i+1};
        end

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
                tempData.(['series', num2str(i)]).(axes(j)) = doubleData;

                % Pull out the axes label entry
                legEntry = get(get(ax(k), [upper( axes(j) ), 'Label']), 'String');
                if ischar(legEntry)
                    tempData.([axes(j), 'label']) = legEntry;
                else
                    tempData.([axes(j), 'label']) = cell2mat(legEntry);
                end
            end
        end
    end
    
    %% Copy the plot data into the main variable to return it
    if (numPlots > 1)
        seriesData.(['subplot', num2str(currentPlot)]) = tempData;
    else
        seriesData = tempData;
    end
    currentPlot = currentPlot + 1;
    
    clear tempData;
end

end

