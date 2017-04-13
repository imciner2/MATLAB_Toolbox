function [ code ] = arrayToC( varName, var )
%ARRAYTOC Convert an array into C code
%   This function will convert an array into the C code for it.
%   The datatype used is float, and the precision is 5.3
%
%   The output string contains newline characters, so it should be fed
%   through an interpretor to create those lines (such as fprintf).
%
%   [ code ] = arrayToC( varName, var )
%       Create the C array called varName using the data in var
%
%
% Created by: Ian McInerney
% Created on: April 13, 2017
% Version: 1.0
% Last Modified: April 13, 2017

% Find the size of the array
[rowSize, columnSize] = size(var);

% Create the first part of the variable initialization
code = sprintf('float %s[%d][%d] = {', varName, rowSize, columnSize);
code = strcat(code, '\n');

for (i = 1:1:rowSize)
    % Add the opening curly brace
    code = strcat(code, '{ ');
    
    for (j = 1:1:columnSize)
        % Print the variable
        temp = sprintf(' %5.3f', var(i, j) );
        code = strcat(code, temp);
        
        % If there are more variables, add a comma
        if (j ~= columnSize)
            code = strcat(code, ', ');
        end
    end
    
    % Add the trailing curly brace
    code = strcat(code, ' }');
    
    % If there are more lines, add a comma
    if (i ~= rowSize)
        code = strcat(code, ',');
    end
    code = strcat(code, '\n');
end

% Add the final curly brace
code = strcat(code, '};\n');

end

