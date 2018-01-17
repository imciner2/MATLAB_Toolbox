function [ un, l ] = uniquetol( u, tol )
%UNIQUETOL Find all unique values in a vector within a tolerance
%
% The functionality is similar to the Matlab provided unique function,
% except this function will search for approximate matches (e.g. see if the
% values are within the tolerance of eachother, and if they are then count
% them as a single value).
%
%
% Usage:
%   [ un ] = uniquetol( u, tol );
%   [ un, l ] = uniquetol( u, tol );
%
% Inputs:
%   u - The vector to use
%   tol - The tolerance to check with
%
% Outputs:
%   un - The unique values (sorted in ascending order)
%   l - The number of unique values found
%
%
% Created by: Ian McInerney
% Created on: January 17, 2018
% Version: 1.0
% Last Modified: January 17, 2018
%
% Revision History
%   1.0 - Initial release


%% Find the places in the matrix where it jumps
u = sort(u);
d = abs(diff(u));


%% Make sure to grab the first entry of the matrix
ind = (d > tol);
ind = [1==1;    % Quick and easy way to create a logic 1 variable
       ind];


%% Extract the matrix entries and compute the length
un = u( ind );
l = length(un);

end