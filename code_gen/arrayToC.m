function [ code ] = arrayToC( varName, var, varargin )
%ARRAYTOC Convert an array into C code
% This function will convert an array into the C code for it.
%
% The output string contains newline characters, so it should be fed
% through an interpretor to create those lines (such as fprintf).
%
%
% Usage: 
%   [ code ] = arrayToC( varName, var );
%   [ code ] = arrayToC( varName, var, type );
%   [ code ] = arrayToC( varName, var, type, format );
%   [ code ] = arrayToC( varName, var, type, format, modifier );
%
% Inputs:
%   varName  - The variable name to use in the C code
%   var      - The variable from MATLAB to convert
%   type     - The type of the C variable (defaults to double if empty)
%   format   - The fprintf format string for the variable conversion
%              (defaults to 5.2f if emmpty). Do not include the % sign
%   modifier - Any modifiers to add to the start of the variable declaration
%
% Output:
%   code - A string containing the formatted C code
%
%
% Created by: Ian McInerney
% Created on: April 13, 2017
% Version: 1.1
% Last Modified: March 13, 2019
%
% Revision History:
%   1.0 - Initial release
%   1.1 - Added type, modifiers, and format strings

% Determine if a type size was provided
p = inputParser;
addOptional(p, 'type', 'double', @(x) isstring(x) || ischar(x));
addOptional(p, 'format', '5.3f', @(x) isstring(x) || ischar(x));
addOptional(p, 'modifier', '', @(x) isstring(x) || ischar(x));
parse(p,varargin{:});

% Extract the matrices
type      = p.Results.type;
formatStr = p.Results.format;
modifier  = p.Results.modifier;

% Find the size of the array
[rowSize, columnSize] = size(var);

% Create the modifier and type
if ( isempty(modifier) )
    code = sprintf('%s', type);
else
    code = sprintf('%s %s', modifier, type);
end

% Create the first part of the variable initialization
if ( rowSize == 1 && columnSize == 1 )
    % Only 1 number to print, just do it now
    temp = sprintf([' %s = %', formatStr, ';\n'], varName, var);
    code = strcat(code, temp);
    return;
    
elseif ( rowSize == 1 || columnSize == 1 )
    % One of the provided dimensions is 1, so use a 1D array
    var = reshape( var, [1, max( columnSize, rowSize )] );
    [rowSize, columnSize] = size(var);
    temp = sprintf(' %s[%d] = ', varName, columnSize);
    code = strcat(code, temp);
    
else
    % Create a 2D array
    temp = sprintf(' %s[%d][%d] = {', varName, rowSize, columnSize);
    code = strcat(code, temp);
end
code = strcat(code, '\n');

for (i = 1:1:rowSize)
    % Add the opening curly brace
    code = strcat(code, '{ ');
    
    for (j = 1:1:columnSize)
        % Print the variable
        temp = sprintf([' %', formatStr], var(i, j) );
        code = strcat(code, temp);
        
        % If there are more variables, add a comma
        if (j ~= columnSize)
            code = strcat(code, ', ');
        end
    end
    
    % Add the trailing curly brace
    if (rowSize > 1)
        code = strcat(code, ' }');
        
        % If there are more lines, add a comma
        if (i ~= rowSize)
            code = strcat(code, ',');
        end
        code = strcat(code, '\n');
    end
end

% Add the final curly brace
code = strcat(code, '};\n');

end

