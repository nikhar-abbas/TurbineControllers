function param = Pre_ContParam_TSR_NREL5MW
% Control parameters input file for TSR_Tracking_*.mdl
%
% These parameters are specific for the NREL 5MW (fixed bottom) controller
%
% Nikhar Abbas - May 2019

% Turbine and Environmental ParametersParameters
param.J = 38677056.000 + 534.116;           % Total Rotor Inertia, kg-m^2.
param.RotorRad      = 63;                % Rotor Radius, m.
param.GBRatio       = 97;                   % Gearbox Ratio, -.
param.GenEff        = .944;                 % Generator Efficiency, 1/%
param.RRSpeed       = 12.1 * pi/30;          % Rated Rotor Speed, rad/s.
param.rho           = 1.225;                % Air Density, kg/m^3.

% Filter Cornering Frequencies
param.filt_HSS           = 4.519 * 1/2;    % Corner frequency in the recursive, second order low pass filter of the HSS Speed, Hz. -- Chosen to be 3/4 of the first drivetrain natural frequency
param.filt_WindSpeedEst  = 0.2;            % Corner frequency for Wind Speed Filt, Hz. -- (Currently arbitrary)
param.filt_GB            = 1/10;           % Corner frequeny for Gain Bias Filter, Hz. -- (Currently arbitrary)

% Variable Speed Torque Controller Parameters
param.VS_zeta = 0.7;                        % Damping constant, --
param.VS_om_n = 0.2; 1/(2*6.25);                 % Natural frequency, Hz. -- Time constant chosen to be on third the rotor frequency at rated. 

% Blade Pitch Controller Parameters
param.PC_zeta = 0.7;                         % Damping constant, --
param.PC_om_n = 0.5;                         % Natural frequency, Hz.

% Region 2.5 Gain Bias
param.VS_GainBias = 20; 0.8; 0.31; 0.031;              % VS Controller Bias Gian for Region 2.5 smoothing, -.
param.PC_GainBias = .0002 ;0.081; 0.081; 0.81;              % Pitch Controller Bias Gian for Region 2.5 smoothing, -.

% Wind Speed Estimator
param.WSE_v0    = 11.4;

% Pitch Controller Setpoints
param.PC_MaxPit     = 90 * (pi/180);        % Maximum pitch setting in pitch controller, rad.
param.PC_MaxRat     = 10 * (pi/180);        % Maximum pitch  rate (in absolute value) in pitch  controller, rad/s.
param.PC_MinPit     = -0.8  * (pi/180);        % Minimum pitch setting in pitch controller, rad.
param.PC_RefSpd     = 122.9096;              % Desired (reference) HSS speed for pitch controller, rad/s.
param.PC_Vrated     = 11.4; 11.4;                 % Rated wind speed, m/s.
param.PC_Vmax       = 25;                   % Maximum wind speed, m/s.

% Variable Speed Torque Controller setpoints
param.VS_MaxRat     = 15000.0;                                             % Maximum torque rate (in absolute value) in torque controller, N-m/s.
param.VS_Rgn3MP     = 1 * pi/180;                                          % Minimum pitch angle at which the torque is computed as if we are in region 3 regardless of the generator speed, rad. -- chosen to be 1.0 degree above PC_MinPit
param.VS_RtGnSp     = 122.9096;                                            % Rated generator speed (HSS side), rad/s. 
param.VS_RtPwr      = 5000000.0/param.GenEff;                              % Rated generator generator power in Region 3, Watts. -- chosen to be 10MW divided by the electrical generator efficiency of 96%
param.VS_RatedTq    = param.VS_RtPwr/param.PC_RefSpd;                      % Rated generator torque in Region 3 (HSS side), N-m.
param.VS_MaxTq      = param.VS_RatedTq * 1;                              % Maximum generator torque in Region 3 (HSS side), N-m.
param.VS_MinSpd     = 6.9*pi/30;                                           % Minimum rotor speed (rad/s)
param.VS_Vmin       = 3;                                                   % Minimum wind speed, m/s

end