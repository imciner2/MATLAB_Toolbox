function [ euler ] = quat2euler( q )
% QUAT2EULER Convert a quaternion rotation to an Euler angle rotation using
% the Aerospace sequence (Yaw-Pitch-Roll)
%
% [ euler ] = quat2euler( q )
%   q - The quaternion rotation representation
%   euler - The euler angles in psi, theta, phi order
%
% Created by: Ian McInerney
% Created on: February 14, 2017
% Version: 1.0
% Last Modified: February 14, 2017
%
% Revision History:
%   1.0 - Initial Release

euler = zeros(3,1);

q0 = q(1);
q1 = q(2);
q2 = q(3);
q3 = q(4);

% Make some intermediate values
l1 = q0^2 + q1^2 - q2^2 - q3^2;
l2 = 2*(q1*q2 + q0*q3);
l3 = 2*(q1*q3 - q0*q2);
n3 = q0^2 - q1^2 - q2^2 + q3^2;
m3 = 2*(q2*q3 + q0*q1);

% Find the pitch
theta = asin(-l3);

% Find the Yaw
psi = acos( l1 / cos(theta) )*sign(l2);

% Find the roll
phi = acos(n3 / cos(theta) )*sign(m3);

euler(1) = psi;
euler(2) = theta;
euler(3) = phi;

end