function [ numFunc, funcs ] = extractFunctions( filename )
%EXTRACTFUNCTIONS Extract all functions that are within a specified file
%
% This function will extract all the functions present in the file and save
% them inside the approrpiately named file inside the current directory.
%
% This will only extract functions at the first indentation level (no
% whitespace in front of the function declaration, so it leaves nested
% functions intact.
%
% 
% Usage:
%   [ numFunc ] = extractFunctions( filename );
%   [ numFunc, funcs ] = extractFunctions( filename );
%
% Inputs:
%   filename - The name of the file to parse
%
% Outputs:
%   numFunc - The number of functions extracted from the file
%   funcs   - The names of the functions extracted from the file (in a cell
%             array)
% 
%
% Created by: Ian McInerney
% Created on: February 20, 2018
% Version: 1.0
% Last Modified: February 20, 2018
%
% Revision History
%   1.0 - Initial release


%% Open the file
fr = fopen(filename);

if (fr == -1)
    error(['Unable to open file ' filename]);
end


%% Initialize some variables for the loop
fw = -1;
numFunc = 0;
funcs = {};


%% Loop while not end of file
while ( ~feof(fr) )
    % Read the line and see if it contains a function declaration
    l = fgets(fr);
    isFunc = regexpi(l, '^[^%\s]*function[\s\S]*\([\s\S]*\)');
    
    % The line defines a function
    if (~isempty( isFunc ) )
        % Close the current function file
        if (fw ~= -1)
            fclose(fw);
        end
        
        % Increment the counter
        numFunc = numFunc + 1;
        
        % Extract the function name
        fname = regexpi(l, '[\S]*\(', 'match');
        fname = fname{:};
        fname = fname(1:end-1);
        
        % Save the function name for return
        funcs{numFunc} = fname;
        
        % Make the file name
        fname = [fname, '.m'];
        
        % Open the file
        fw = fopen(fname, 'w');
        
        % If the file was unable to be opened for some reason, throw an
        % error and close the reading file
        if (fw == -1)
            fclose(fr);
            error(['Unable to open file ', fname]);
        end
    end
    
    % Write to the function file if it is open
    if (fw ~= -1)
        fprintf(fw, '%s', l);
    end
end


%% Close the files that are open
fclose(fr);
if (fw ~= -1)
    fclose(fw);
end

end

