function [ r, c ] = domTest( A )
% DOMTEST Test for dominance of the rows/columns in A
%
% This function will test for the diagonal dominance of the rows/columns of A.
% This checks to see if the sum of the absolute value of the non-diagonal
% entries is greater than the absolute value of the diagonal entry.
%
%
% Usage: 
%   [ r, c ] = DOMTEST( A );
%
% Inputs:
%   A - 
%
% Outputs:
%   r - 1 if row dominant, 0 otherwise
%   c - 1 if column dominant, 0 otherwise
%
%
% Created by: Ian McInerney
% Created on: November 1, 2018
% Version: 1.0
% Last Modified: November 1, 2018
%
% Revision History
%   1.0 - Initial release


%% Extract the diagonal
d = diag(A);

D = diag(d);
Ad = A - D;


%% Take the absolute value of the terms
Ad = abs( Ad );
d  = abs( d );

%% Sum the off-diagonal terms
sr = sum( Ad, 2 );
sc = sum( Ad, 1 )';


%% Subtract them from the diagonal
dr = d - sr;
dc = d - sc;


%% Figure out the dominance
r = all(dr > 0);
c = all(dc > 0);

end