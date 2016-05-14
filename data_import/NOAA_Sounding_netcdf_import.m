function [ soundingData ] = NOAA_Sounding_netcdf_import ( filename )
%NOAA_Sounding_netcdf_import Import a NOAA sounding binary file
%   This function will import the given NOAA netCDF binary sounding data
%   file to the MATLAB workspace

% Open the file
file = netcdf.open(filename, 'NOWRITE');

% Read in the World Meteorlogical Organization station number
id = netcdf.inqVarID(file, 'wmoStat');
soundingData.StationData.WMO_Number = netcdf.getVar(file, id);

% Read in the Weather Bureau Army Navy station number
id = netcdf.inqVarID(file, 'wbanStat');
soundingData.StationData.WBAN_Number = netcdf.getVar(file, id);

% Read in the station ID
id = netcdf.inqVarID(file, 'staName');
soundingData.StationData.Name = netcdf.getVar(file, id);

% Read in the station latitude
id = netcdf.inqVarID(file, 'staLat');
soundingData.StationData.Latitude = netcdf.getVar(file, id);

% Read in the station longitude
id = netcdf.inqVarID(file, 'staLon');
soundingData.StationData.Longitude = netcdf.getVar(file, id);

% Read in the station elevation
id = netcdf.inqVarID(file, 'staElev');
soundingData.StationData.Elevation = netcdf.getVar(file, id);

% Read in the sounding time
id = netcdf.inqVarID(file, 'relTime');
soundingData.StationData.SoundingTime = netcdf.getVar(file, id);

% Read in the instrument used
id = netcdf.inqVarID(file, 'sondTyp');
soundingData.StationData.InstrumentType = netcdf.getVar(file, id);


end

