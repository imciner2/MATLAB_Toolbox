function bitUsage(time, num, varargin )
%BITUSAGE Plot the bit usage over time for the numbers given
%
% Create a plot showing the bit usage at specific times.
%
% bitUsage(time, num, ... )
%   Find the bit usage for the numbers given in num, plotted against the
%   time.
%
% Additional Arguments, to take the format 'Identifier', 'Value'
%  'Title'  - The title string to use on the plot
%  'xlabel' - The label to apply on the x axis
%
% Created by: Ian McInerney
% Created on: July 27, 2017
% Version: 1.0
% Last Modified: July 27, 2017
%
% Revision History:
%   1.0 - Initial Release

%% Parse the input arguments
plotTitle = 'Bit Usage';
plotxLabel = 'Time (S)';

% Determine the number of extra arguments provided to the function
nvarargs = length(varargin);
if (nvarargs == 0)
   % Assume the default for everything
elseif ( mod(nvarargs,2) ~= 0 )
    % Not enough input arguments, they must come in pairs
    error('Not enough input arguments to the function');
else
    for (i=1:2:nvarargs)
        switch(varargin{i})
            case 'Title'
                % A custom plot title
                plotTitle = varargin{i+1};
            case 'xlabel'
                % A custom label for the x axes
                plotxLabel = varargin{i+1};
        end 
    end
end


%% Convert to the binary representation
[binary, numBits] = int2bin( num );


%% Create the plot
figure;
title(plotTitle);
xlabel(plotxLabel);
ylabel('Bit');
yticks([0:1:numBits]);
hold on;

for ( i = 1:1:numBits )
    % Iterate over the bits and add them to the plot
    usagePattern = 0.5*binary(:,i) + i - 1;
    plot(time, usagePattern, 'b')
end

end

