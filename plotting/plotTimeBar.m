function plotOutput = plotTimeBar(time, varargin)
%PLOTTIMEBAR Creates a vertical bar on a time-based graph
% 
% PLOTTIMEBAR(time, ...) Creates a vertical bar on a time-based graph
% which takes up the entire vertical height of the graph without using
% any MATLAB builtin TimeSeries functions, which improves speed.
% 
% Arguments:
%  time - The time string saying where to place the point
%  height - The height at which to place the point
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
%       Defaults to 'dd-mmm-yyyy HH:MM:SS'
%       ex. 'DateInputFormat', 'mmm dd'
%
%  'Width' - The width of the bar.
%       Defaults to line width 2.
%
%  'Color' - The color of the bar
%       Defaults to a line color of Red.
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
%  plotOutput - The results of the plot function.
%
% See also: PLOTTIMEPOINT, PLOTTIMEDATA, PLOT, SUBPLOT, HOLD
%
% 
% Created by: Ian McInerney
% Created on: July 5, 2013
% Version: 1.0
% Last Modified: July 5, 2013


%% Set defaults for the plot

dateInputFormat = 'dd-mmm-yyyy HH:MM:SS'; % Dates are given as a string
width = 2; % Default to line width 2
color = {'Red'};
plotOptions = {};


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
            case 'PlotOptions'
                % Single arguments to be passed to the plot function
                plotOptions{j} = varargin{i+1};
                j=j+1;
            case 'Width'
                width = varargin{i+1};
            case 'Color'
                color{1} = varargin{i+1};
            otherwise
                % Options to be passed to the plot function
                plotOptions{j} = varargin{i};
                plotOptions{j+1} = varargin{i+1};
                j=j+2;
        end 
    end
end


%% Convert the time to a date serial number for plotting

if (strcmp(dateInputFormat, 'DateNum'))
    % No conversion necessary
    plotTime = time;
elseif (strcmp(dateInputFormat, 'DateVector'))
    % Date vector can be passed directly
    plotTime = datenum(time);
elseif (strcmp(dateInputFormat, 'YMD'))
    % YMD format can be passed directly
    plotTime = datenum(time);
else
    % Specify the input format to speed up the conversion
    plotTime = datenum(time, dateInputFormat);
end


%% Plot the point on the graph

% Determine the limits of the currently plotted graph
yaxis = ylim;

% Create the line
plotOutput = line([plotTime plotTime], [yaxis(1) yaxis(2)], 'Color', color{1}, 'LineWidth', width);


end