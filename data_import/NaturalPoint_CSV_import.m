function [ frame, trackable, info ] = NaturalPoint_CSV_import(filename)
%NATURALPOINT_CSV_IMPORT Imports a CSV logfile made by the NaturalPoint
%tracking tools program.
%
% This function will import a CSV log file created by the NaturalPoint
% TrackingTools software (tested on version 2.3.3).
%
% Inputs:
%   filename - Filename to the log file to import
%
% Outputs:
%   frame - Structure containing information about each captured frame
%   trackable - Structure containing information about each trackable
%   info - Structure containing information about the log in general
%
%
% Created by: Ian McInerney
% Created on: September 16, 2016
% Version: 1.1
% Last Modified: February 14, 2017
%
% Revision History:
%   1.0 - Initial Release
%   1.1 - Sanitized trackable names to remove spaces and hyphens

%% Open the file and get all the data
file = fopen(filename);
fileData = textscan(file, '%s', 'Delimiter', '\r\n');


numDataPoints = length(fileData{1});
trackable.hi = 0;

%% Parse each row individually, its slow but it works
foundFrame = 0;
for ( i=1:1:numDataPoints )
    % Pull out the line from the cell array and separate based on commas
    fullLine = fileData{1}(i);
    line = strsplit(fullLine{1}, ',');
    
    % Go through and figure out what kind of line this is
    if ( ~isempty(strfind( line{1}, 'comment')) )
        % This line is a comment, it can be ignored
        % (after all, who actually reads the comments anyway, it takes all
        % the fun out of coding)
        
    elseif ( ~isempty(strfind( line{1}, 'info')) )
        % This line is an info line
        % Copy the data into the info structure for return
        info.(sprintf('%s', line{2})) = str2double(line{3});
        
    elseif ( ~isempty(strfind( line{1}, 'trackable')) && foundFrame )
        % This line contains trackable information
        % There is a weird line in the logfile where trackable lines will
        % appear before any frames occur, and those lines are incomplete.
        % So ignore those log lines
        
        % Sanitize the input
        name = strrep( line{4},'"','');
        name = strrep( name, ' ', '_');
        name = strrep( name, '-', '_');
        
        frameNumber = str2double(line{2})+1;
        markerCount = str2double(line{7});
        
        if ( isempty(cell2mat(strfind(fieldnames(trackable), name))) )
            % The trackable doesn't exist in the structure, create slots
            % for it
            if ~isfield(info, 'framecount')
                % TODO: Implement a nicer handling of unknown data lengths
                error('NaturalPoint_CSV_Import::Unknown number of frames');
            end
            trackable.(sprintf('%s', name)).id = line{5};
            trackable.(sprintf('%s', name)).name = name;
            trackable.(sprintf('%s', name)).time = nan(info.framecount,1);
            trackable.(sprintf('%s', name)).frame = nan(info.framecount,1);
            trackable.(sprintf('%s', name)).lastTrackedFrame = nan(info.framecount,1);
            trackable.(sprintf('%s', name)).markerCount = nan(info.framecount,1);
            for (j = 1:1:markerCount)
                trackable.(sprintf('%s', name)).marker(j).x = nan(info.framecount,1);
                trackable.(sprintf('%s', name)).marker(j).y = nan(info.framecount,1);
                trackable.(sprintf('%s', name)).marker(j).z = nan(info.framecount,1);
                trackable.(sprintf('%s', name)).marker(j).xPointCloud = nan(info.framecount,1);
                trackable.(sprintf('%s', name)).marker(j).yPointCloud = nan(info.framecount,1);
                trackable.(sprintf('%s', name)).marker(j).zPointCloud = nan(info.framecount,1);
                trackable.(sprintf('%s', name)).marker(j).tracked = nan(info.framecount,1);
                trackable.(sprintf('%s', name)).marker(j).quality = nan(info.framecount,1);
            end
            trackable.(sprintf('%s', name)).error = nan(info.framecount,1);
        end
        
        % Pull out the data for the overall trackable
        trackable.(sprintf('%s', name)).frame(frameNumber) = frameNumber;
        trackable.(sprintf('%s', name)).time(frameNumber) = str2double(line{3});
        trackable.(sprintf('%s', name)).lastTrackedFrame(frameNumber) = str2double(line{6});
        trackable.(sprintf('%s', name)).markerCount(frameNumber) = markerCount;
        
        % The next field to parse
        l = 8;
        
        % Pull out the data for the remaining markers
        for ( j=1:1:markerCount )
            trackable.(sprintf('%s', name)).marker(j).x(frameNumber) = str2double(line{l});
            trackable.(sprintf('%s', name)).marker(j).y(frameNumber) = str2double(line{l+1});
            trackable.(sprintf('%s', name)).marker(j).z(frameNumber) = str2double(line{l+2});
            l = l+3;
        end
        
        % Pull out the point cloud location
        for ( j=1:1:markerCount )
            trackable.(sprintf('%s', name)).marker(j).xPointCloud(frameNumber) = str2double(line{l});
            trackable.(sprintf('%s', name)).marker(j).yPointCloud(frameNumber) = str2double(line{l+1});
            trackable.(sprintf('%s', name)).marker(j).zPointCloud(frameNumber) = str2double(line{l+2});
            l = l+3;
        end
        
        % Pull out if the marker is tracked
        for ( j=1:1:markerCount )
            trackable.(sprintf('%s', name)).marker(j).tracked(frameNumber) = str2double(line{l});
            l = l+1;
        end
        
        % Pull out if the quality
        for ( j=1:1:markerCount )
            trackable.(sprintf('%s', name)).marker(j).quality(frameNumber) = str2double(line{l});
            l = l+1;
        end
        
        % Pull out the marker error
        trackable.(sprintf('%s', name)).error(frameNumber) = str2double(line{l});
        
    elseif ( ~isempty(strfind( line{1}, 'frame')) )
        % This line contains frame information
        if (foundFrame == 0)
            % Create the barebones frame structure since it hasn't been
            % done before
            frame.number = nan(info.framecount,1);
            frame.time = nan(info.framecount,1);
            frame.trackableCount = nan(info.framecount,1);
            frame.markerCount = nan(info.framecount,1);
        end
        foundFrame = 1;
        
        frameNumber = str2double(line{2})+1;
        trackableCount = str2double(line{4});
        
        % Populate some fields for the entire frame
        frame.number(frameNumber) = frameNumber;
        frame.time(frameNumber) = str2double(line{3});
        frame.trackableCount(frameNumber) = trackableCount;
        
        l = 5;  % The next field to use
        for (j = 1:1:trackableCount)
            id = str2double(line{l});

            if ( isempty(cell2mat(strfind(fieldnames(frame), sprintf('ID_%d',id))) ) )
                % The trackable doesn't exist in the structure, create slots
                % for it
                if ~isfield(info, 'framecount')
                    % TODO: Implement a nicer handling of unknown data lengths
                    error('NaturalPoint_CSV_Import::Unknown number of frames');
                end
                frame.(sprintf('ID_%d',id)).xPos = nan(info.framecount,1);
                frame.(sprintf('ID_%d',id)).yPos = nan(info.framecount,1);
                frame.(sprintf('ID_%d',id)).zPos = nan(info.framecount,1);
            
                % Pull out the quaternion attitude of the trackable
                frame.(sprintf('ID_%d',id)).qx = nan(info.framecount,1);
                frame.(sprintf('ID_%d',id)).qy = nan(info.framecount,1);
                frame.(sprintf('ID_%d',id)).qz = nan(info.framecount,1);
                frame.(sprintf('ID_%d',id)).qw = nan(info.framecount,1);
            
                % Pull out the Euler angles of the trackable
                frame.(sprintf('ID_%d',id)).yaw = nan(info.framecount,1);
                frame.(sprintf('ID_%d',id)).pitch = nan(info.framecount,1);
                frame.(sprintf('ID_%d',id)).roll = nan(info.framecount,1);
            end
            
            frame.(sprintf('ID_%d',id)).id = id;
            
            % Pull out the X position of the trackable
            frame.(sprintf('ID_%d',id)).xPos(frameNumber) = str2double(line{l+1});
            frame.(sprintf('ID_%d',id)).yPos(frameNumber) = str2double(line{l+2});
            frame.(sprintf('ID_%d',id)).zPos(frameNumber) = str2double(line{l+3});
            
            % Pull out the quaternion attitude of the trackable
            frame.(sprintf('ID_%d',id)).qx(frameNumber) = str2double(line{l+4});
            frame.(sprintf('ID_%d',id)).qy(frameNumber) = str2double(line{l+5});
            frame.(sprintf('ID_%d',id)).qz(frameNumber) = str2double(line{l+6});
            frame.(sprintf('ID_%d',id)).qw(frameNumber) = str2double(line{l+7});
            
            % Pull out the Euler angles of the trackable
            frame.(sprintf('ID_%d',id)).yaw(frameNumber) = str2double(line{l+8});
            frame.(sprintf('ID_%d',id)).pitch(frameNumber) = str2double(line{l+9});
            frame.(sprintf('ID_%d',id)).roll(frameNumber) = str2double(line{l+10});
            
            l = l+11;   % Update the next field counter
        end
        
        % Get the marker information
        markerCount = str2double(line{l});
        frame.markerCount(frameNumber) = markerCount;
        
        if ( isempty(cell2mat(strfind(fieldnames(frame), 'markers')) ) )
            % Marker does not exist, create it
            for (k = 1:1:markerCount)
                frame.markers(k).xPos = nan(info.framecount,1);
                frame.markers(k).yPos = nan(info.framecount,1);
                frame.markers(k).zPos = nan(info.framecount,1);
                frame.markers(k).id = nan(info.framecount,1);
            end
        end
        numMark = length(frame.markers);

        if (numMark < markerCount)
            % More markers in this frame than before, add new places
            for (k = (numMark+1):1:markerCount)
                frame.markers(k).xPos = nan(info.framecount,1);
                frame.markers(k).yPos = nan(info.framecount,1);
                frame.markers(k).zPos = nan(info.framecount,1);
                frame.markers(k).id = nan(info.framecount,1);
            end
        end
        
        l = l+1;
        for (j = 1:1:markerCount)

            % Pull out the information for the marker
            frame.markers(j).xPos(frameNumber) = str2double(line{l});
            frame.markers(j).yPos(frameNumber) = str2double(line{l+1});
            frame.markers(j).zPos(frameNumber) = str2double(line{l+2});
            frame.markers(j).id(frameNumber) = str2double(line{l+3});
            l = l+4;    % Update the next field location
        end
        
    elseif ( ~isempty(strfind( line{1}, 'lefthanded')) )
        % This uses a left-handed coordinate system
        info.hand = 'Left';
        
    elseif ( ~isempty(strfind( line{1}, 'righthanded')) )
        % This uses a right-handed coordinate system
        info.hand = 'Right';
        
    end
end


end