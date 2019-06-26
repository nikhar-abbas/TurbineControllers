function [b,a] = filt_2lp_D(om,zeta, dt)
%%
% This function describes the discrete time transfer function for a first
% order low pass filter of the form: H(s) = om/(s+om)
%
% Inputs: om - cutoff frequency
%         zeta - damping constant
%         dt - discrete timestep length
%
% Outputs: b - filter numerator coefficients
%          a - filter denominator coefficients  
%
% Nikhar Abbas - March 2019



%%
a1 = -(-2*zeta*om + sqrt((2*zeta*om)^2 - 4 * om^2))/2; 
a2 = -(-2*zeta*om - sqrt((2*zeta*om)^2 - 4 * om^2))/2; 
alph1 = exp(-dt*a1);
alph2 = exp(-dt*a2);
K = ((1-alph1)*(1-alph2))/4;


b = K * [1, 2, 1];
a = [1 -(alph1+alph2) alph1*alph2];

end