function [plotOutput gapInformation] = plotTimeData(time, data, varargin)
%PLOTTIMEDATA Plots a dataseries against time
%
% PLOTTIMEDATA(time, data,...) Plots a given data series against time
% without using MATLAB TimeSeries functions to provide a faster plot
% time than a TimeSeries object.
%
% Arguments:
%  time - The array containing the time strings
%  data - The array containing the data
% 
% Additional Arguments, to take the format 'Identifier', 'Value'
%  'DateInputFormat' - The format of the date string being provided in
%       the time array.
%       If providing date serial numbers, specify 'DateNum'
%       If providing a date vector, specify 'DateVector'
%           Must be formatted: time(:,1)=Year, time(:,2)=Month, time(:,3)=Day
%                              time(:,4)=Hour, time(:,5)=Minute, time(:,6)=Second
%       If providing a Year, Month, Day, specify 'YMD'
%           Must be formatted: time(:,1)=Year, time(:,2)=Month, time(:,3)=Day
%       Defaults to 'DateNum'
%       ex. 'DateInputFormat', 'mmm dd'
%
%  'Gaps' - How to handle gaps in the data
%       'Blank' - Leave the gaps blank on the graph
%       'Linear' - Perform a linear interpolation between start/end points
%       'ZeroOrder' - Perform a Zero-Order Hold interpolation between
%          start/end points
%       'Minimum' - Hold the minimum value surrouding the gap over the gap
%       Defaults to 'Blank'
% 
%  'GapLength' - The duration of time which is considered a gap (in seconds)
% 
%  'GapMarker' - Specify the type of marker (if any) to use for the start
%       and stop of gaps. Specified as either {'None'} for no marker
%       or {'+', 'b', '-', 'r'} to place a blue + marker at the start of
%       a gap and a red - marker at the end of a gap. The allowable marker
%       types and colors are the ones specified for a LineSeries object.
%       
%  'DateDisplayFormat' - The format of the date string to display on the
%       X-axis.
%       Defaults to 'mmm dd'
%
%  'Zoom' - Zoom into a specific date range specififed by cell array {min, max}
%       The dates should be specified in a date string format
%       ex. 'Zoom', {'Apr 08', 'Mar 10'}
% 
%  'PlotOptions' - Passes the next argument to the plot command. This
%       argument should only be used with single argument plot commands, if
%       you would like to specify the command and the value, just pass
%       those as arguments to this function
%       ex. 'PlotOptions', 'r'
%       NOT to be used with 'PlotOptions', 'Color', 'Red', instead just
%       specify 'Color', 'Red'
%
%   Other Options - This function accepts any other pair of arguments that
%       the Plot function accepts. It then passes those directly to the
%       plot function.
% 
% Output Variables:
%  plotOutput - A cell array containing the results of the plot function.
%       Cell 1 = Main data result
%       Cell 2 = Start gap marker result
%       Cell 3 = Stop gap marker result
% 
%  gapInformation - An array containing information about the gaps in the data
%       Column 1 = Start Date Serial Number
%       Column 2 = Start Data
%       Column 3 = Stop Date Serial Number
%       Column 4 = Stop Data
%
% 
% See also: PLOTTIMEPOINT, PLOTTIMEBAR, PLOT, SUBPLOT, HOLD
%
%
% Created by: Ian McInerney
% Created on: July 5, 2013
% Version: 1.0
% Last Modified: July 5, 2013


%% Set defaults for the plot

gapFill = 0; % Leave blanks for the gaps
gapLength = 1; % A gap is 1 second
gapMarker = {'None'}; % Default to having no marker
dateDisplayFormat = 'mmm dd'; % The format to display the dates on the axis
dateInputFormat = 'DateNum'; % Dates are given as serial numbers
plotOptions = {};
zoomParams = {'Min', 'Max'};


%% Parse the input arguments

% Determine the number of extra arguments provided to the function
nvarargs = length(varargin);
if (nvarargs == 0)
   % Assume the default for everything
elseif ( mod(nvarargs,2) ~= 0 )
    % Not enough input arguments, they must come in pairs
    error('Not enough input arguments to the function');
else
    j=1;
    for (i=1:2:nvarargs)
        switch(varargin{i})
            case 'DateInputFormat'
                dateInputFormat = varargin{i+1};
            case 'Gaps'
                % Determine what to do with gaps in the data
                switch(varargin{i+1})
                    case 'Blank'
                        % Leave the spaces where the gaps are blank
                        gapFill = 0;
                    case 'Linear'
                        % Do a linear interpolation across the gaps
                        gapFill = 1;
                    case 'ZeroOrder'
                        % Do a Zero-order hold across the gaps
                        gapFill = 2;
                    case 'Minimum'
                        % Hold the minimum value (from either side) across
                        % the gap
                        gapFill = 3;
                end
            case 'GapLength'
                % The length of time to be considered a gap
                gapLength = varargin{i+1};
            case 'GapMarker'
                % The markers to use for the start and stop points of gaps
                gapMarker = varargin{i+1};
            case 'DateDisplayFormat'
                % The display format for the dates on the axis
                dateDisplayFormat = varargin{i+1};
            case 'Zoom'
                % Zoom the x-axis into a specific time range
                zoomParams = varargin{i+1};
            case 'PlotOptions'
                % Single arguments to be passed to the plot function
                plotOptions{j} = varargin{i+1};
                j=j+1;
            otherwise
                % Options to be passed to the plot function
                plotOptions{j} = varargin{i};
                plotOptions{j+1} = varargin{i+1};
                j=j+2;
        end 
    end
end


%% Create the time data to plot

% Convert the date information into the date serial numbers for plotting
if (strcmp(dateInputFormat, 'DateNum'))
    % No conversion necessary
    dateSerials = time;
elseif (strcmp(dateInputFormat, 'DateVector'))
    % Date vector can be passed directly
    dateSerials = datenum(time);
elseif (strcmp(dateInputFormat, 'YMD'))
    % YMD format can be passed directly
    dateSerials = datenum(time);
else
    % Specify the input format to speed up the conversion
    dateSerials = datenum(time, dateInputFormat);
end

% Determine where the gaps in the data exist
interval = 1/86400*gapLength;
gap = diff(dateSerials);
indices = find(gap > interval)+1;

% The lengths of various arrays
numIndices = size(indices,1);
numDates = size(dateSerials,1);
newLength = numIndices+numDates;

% Create a new array to hold the data and the times
filledTimes = zeros(newLength,1);
filledData = zeros(newLength,1);

% Column 1 = Start Date Serial Number
% Column 2 = Start Data
% Column 3 = Stop Date Serial Number
% Column 4 = Stop Data
gapInformation = zeros(numIndices,4);

% Find the first datablock
startBlockWriteIndex = 1;
startBlockReadIndex = 1;
stopBlockWriteIndex = indices(1)-1;
stopBlockReadIndex = indices(1)-1;

% Copy the first datablock into the new arrays
filledTimes(startBlockWriteIndex:stopBlockWriteIndex,1) = dateSerials(startBlockReadIndex:stopBlockReadIndex,1);
filledData(startBlockWriteIndex:stopBlockWriteIndex,1) = data(startBlockReadIndex:stopBlockReadIndex,1);

% Iterate over the gap locations and form the new array
for (i=1:1:numIndices)
    % Determine the serial numbers for the start and stop times of the gap
    startGapSerial = dateSerials(indices(i)-1);
    stopGapSerial = dateSerials(indices(i));
    midGapSerial = (startGapSerial+stopGapSerial)/2;
    
    % Determine the data values for the start, stop and middle of the gap
    startGapData = data(indices(i)-1);
    stopGapData = data(indices(i));
    midGapData = (startGapData+stopGapData)/2;
    
    % Determine the new index for the next datablock to copy
    startBlockWriteIndex = indices(i)+i;
    startBlockReadIndex = indices(i);
    if (i==numIndices)
        stopBlockWriteIndex = newLength;
        stopBlockReadIndex = numDates;
    else
        stopBlockWriteIndex = indices(i+1)+i-1;
        stopBlockReadIndex = indices(i+1)-1;
    end

    % Determine the proper method to fill in the gap in the array
    switch (gapFill)
        case 0
            % Leave the gap blank
            filledTimes(startBlockWriteIndex-1,1) = midGapSerial;
            filledData(startBlockWriteIndex-1,1) = NaN;
        case 1
            % Linear Interpolation
            filledTimes(startBlockWriteIndex-1,1) = midGapSerial;
            filledData(startBlockWriteIndex-1,1) = midGapData;
        case 2
            % Zero-order hold across the gap
            filledTimes(startBlockWriteIndex-1,1) = stopGapSerial-(1/86400);
            filledData(startBlockWriteIndex-1,1) = startGapData;
        case 3
            % Minimum value from either side of the gap
            if (startGapData > stopGapData)
                % Take the minimum value from the end of the gap
                filledTimes(startBlockWriteIndex-1,1) = startGapSerial+(1/86400);
                filledData(startBlockWriteIndex-1,1) = stopGapData;
            else
                % Take the minimum vlaue from the beginning of the gap
                filledTimes(startBlockWriteIndex-1,1) = stopGapSerial-(1/86400);
                filledData(startBlockWriteIndex-1,1) = startGapData;
            end
    end

    % Store information about the gap into an array to return to the user
    gapInformation(i,1) = startGapSerial;
    gapInformation(i,2) = startGapData;
    gapInformation(i,3) = stopGapSerial;
    gapInformation(i,4) = stopGapData;

    % Copy the next block of data into the array
    filledTimes(startBlockWriteIndex:stopBlockWriteIndex,1) = dateSerials(startBlockReadIndex:stopBlockReadIndex,1);
    filledData(startBlockWriteIndex:stopBlockWriteIndex,1) = data(startBlockReadIndex:stopBlockReadIndex,1);
end


%% Create the plot
hold on;
plotOutput{1} = plot(filledTimes, filledData, plotOptions{1:length(plotOptions)});


%% Add the gap markers if desired
if (~strcmp(gapMarker{1},'None'))
    % Markers are desired
    startMarker = gapMarker{1};
    startColor = gapMarker{2};
    stopMarker = gapMarker{3};
    stopColor = gapMarker{4};
    
    % Iterate over each gap point pair and plot the marker
    [numPoints gar] = size(gapInformation);
    for (i=1:1:numPoints)
        plotOutput{2} = plot(gapInformation(i,1), gapInformation(i,2), 'Marker', startMarker, 'MarkerEdgeColor', startColor,'MarkerFaceColor', startColor);
        plotOutput{3} = plot(gapInformation(i,3), gapInformation(i,4), 'Marker', stopMarker, 'MarkerEdgeColor', stopColor,'MarkerFaceColor', stopColor);
    end
end


%% Format the plot

% Determine the minimum and maximum desired plot range
if (strcmp(zoomParams{1},'Min'))
    XaxisMin = min(dateSerials);
else
    XaxisMin = datenum(zoomParams{1});
end

if (strcmp(zoomParams{2},'Max'))
    XaxisMax = max(dateSerials);
else
    XaxisMax = datenum(zoomParams{2});
end
xlim([XaxisMin XaxisMax]);

% Create the axis labels
numTicks = 25;

% Create equally spaced tickmarks
incrementTicks = (XaxisMax-XaxisMin)/numTicks;
tickNumbers = XaxisMin:incrementTicks:XaxisMax;
tickText = datestr(tickNumbers, dateDisplayFormat);

% Set the axis
set(gca, 'XTick', tickNumbers);
set(gca, 'XTickLabel', tickText);


end