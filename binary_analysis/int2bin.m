function [ binary, largestBit ] = int2bin( num )
%DEC2BIN Convert a decimal number into its binary equivalent
%
%  This function will convert the integer given into its binary
%  representation. Note, if a non-integer is specified then the binary
%  returned will be for the integer portion only.
%
% [ binary ] = int2bin( num )
%   Convert the integer in num to its binary representation
%
% Created by: Ian McInerney
% Created on: July 27, 2017
% Version: 1.0
% Last Modified: July 27, 2017
%
% Revision History:
%   1.0 - Initial Release


% Find the bit just above the number
largestBit = max( floor(log2(num)) + 1 );
binary = zeros(length(num), largestBit);

currentBit = largestBit;

%% Iterate over until the number is empty
while (currentBit > 0)
    
    % Determine the number without the bit position
    tempNum = num - 2.^(currentBit-1);
    
    % The bit occurs in the number if the temp number is positive
    binary( (tempNum >= 0) , currentBit) = 1;
    num( tempNum >= 0 ) = tempNum( tempNum >= 0);
    
    % Move to the next bit
    currentBit = currentBit - 1;
end

end

