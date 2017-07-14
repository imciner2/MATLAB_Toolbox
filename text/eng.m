function [ str ] = eng( num, decimals )
%ENG Format the number in engineering notation for display
%
% This function will format the given number into engineering notation (aka
% scientific notation with only exponents that are powers of 3).
%
% [ str ] = eng( numbers, decimals)
%
% Inputs:
%   numbers - Array containing the numbers
%   decimals - The number of decimal places to use
%
% Outputs:
%   str - String containing all converted numbers
%
% Created by: Ian McInerney
% Created on: July 12, 2017
% Version: 1.2
% Last Modified: July 14, 2017
%
% Revision History:
%   1.0 - Initial Release
%   1.1 - Fixed decimal place creation
%   1.2 - Streamlined decimal creation

if ( ~exist('decimals') )
    decimals = 3;
end

for i=1:1:length( num )
    tempNum = num(i);
    
    % Put a negative sign out front if needed
    if ( sign(tempNum) == -1 )
        signStr = '-';
    else
        signStr = ' ';
    end
    
    % Figure out the order of magnitude for the number
    order = floor(log10( tempNum ));
    extraPlaces = mod(order, 3);
    decimalPlaces = order - extraPlaces;
    
    % Figure out the integer portion of the number
    integerPortion = floor( tempNum / 10^(decimalPlaces)  );
    
    % Figure out the decimal portion of the number
    decimalPortion = tempNum - integerPortion*(10^decimalPlaces);
    decimalPortion = decimalPortion / (10^decimalPlaces+1);
    decimalPortion = round(decimalPortion, decimals);
    formatString   = ['%' num2str(decimals) '.' num2str(decimals) 'f'];
    decimalString  = sprintf(formatString, decimalPortion);
    
    % Create the new string
    newStr = sprintf('%s%i.%sE%+03i', signStr, integerPortion, decimalString(3:end), decimalPlaces);
    
    % Add it to the array
    if (i > 1)
        str = sprintf('%s\t%s', str,  newStr);
    else
        str = newStr;
    end
    
end
