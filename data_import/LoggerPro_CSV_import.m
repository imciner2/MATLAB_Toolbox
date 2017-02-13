function [ data ] = LoggerPro_CSV_import(filename)
%LOGGERPRO_CSV_IMPORT Imports a CSV logfile made by the Logger Pro
%data analysis program
%
% This function will import a CSV log file created by the Logger Pro
% data analysis program by Vernier (Tested with version 3.12 )
%
% Inputs:
%   filename - Filename to the log file to import
%
% Outputs:
%   data - Data structure of the data contained in the file
%
%
% Created by: Ian McInerney
% Created on: February 12, 2017
% Version: 1.0
% Last Modified: February 12, 2017
%
% Revision History:
%   1.0 - Initial Release

%% Open the file and get all the data
file = fopen(filename);
fileData = textscan(file, '%s', 'Delimiter', '\r\n');

numDataPoints = length(fileData{1});
data.hi = 0;

%% Parse each row individually, its slow but it works
for ( i=1:1:numDataPoints )
    % Pull out the line from the cell array and separate based on commas
    fullLine = fileData{1}(i);
    line = strsplit(fullLine{1}, ',');
    
    numColumns = length(line);
    for ( j = 1:1:numColumns )
        % The first line contains the headers
        if ( i == 1 )
            name = sscanf(line{j}, '"Latest: %s ()"');
            units = sscanf(line{j}, ['"Latest: ' name ' (%s)"']);
            
            dataTypes{j} = name;
            
            % Go to end-2 because for some reason the above sscanf appends
            % the )" to the output
            data.(name).units = units(1:end-2);
        else
            data.(dataTypes{j}).data(i-1,1) = str2double(line{j});
        end
    end
end

end