function param = Pre_ContParam_TSR_DTU10MW
% Control parameters input file for TSR_Tracking_*.mdl
%
% These parameters are specific for the DTU 10MW (fixed bottom) controller
%
% Nikhar Abbas - May 2019

% Turbine and Environmental ParametersParameters
param.J = 156348032.208 + 1500;           % Total Rotor Inertia, kg-m^2.
param.RotorRad      = 89.15;                % Rotor Radius, m.
param.GBRatio       = 50;                   % Gearbox Ratio, -.
param.GenEff        = 0.96;                 % Generator Efficiency, 1/%
param.RRSpeed       = 9.6 * pi/30;          % Rated Rotor Speed, rad/s.
param.rho           = 1.225;                % Air Density, kg/m^3.

% Filter Cornering Frequencies
param.HSSfilt_omn           = 4.519 * 1/2;    % Corner frequency in the recursive, second order low pass filter of the HSS Speed, Hz. -- Chosen to be 3/4 of the first drivetrain natural frequency
param.WindSpeedEstfilt_omn  = 0.25;            % Corner frequency for Wind Speed Filt, Hz. -- (Currently arbitrary)
param.GBfilt_omn            = 1/10;           % Corner frequeny for Gain Bias Filter, Hz. -- (Currently arbitrary)

% Variable Speed Torque Controller Parameters
param.VS_zeta = 0.7;                        % Damping constant, --
param.VS_om_n = 0.2; 1/(2*6.25);                 % Natural frequency, Hz. -- Time constant chosen to be on third the rotor frequency at rated. 

% Blade Pitch Controller Parameters
param.PC_zeta = 0.7;                         % Damping constant, --
param.PC_om_n = 0.15;                         % Natural frequency, Hz.

% Wind Speed Estimator
param.WSE_v0 = 11.5;

% Region 2.5 Gain Bias
param.VS_GainBias = 50; 0.31; 0.031;              % VS Controller Bias Gian for Region 2.5 smoothing, -.
param.PC_GainBias = 0.001; 0.081; 0.81;              % Pitch Controller Bias Gian for Region 2.5 smoothing, -.

% Pitch Controller Setpoints
param.PC_MaxPit     = 90 * (pi/180);        % Maximum pitch setting in pitch controller, rad.
param.PC_MaxRat     = 10 * (pi/180);        % Maximum pitch  rate (in absolute value) in pitch  controller, rad/s.
param.PC_MinPit     = 0  * (pi/180);        % Minimum pitch setting in pitch controller, rad.
param.PC_RefSpd     = 50.2655;              % Desired (reference) HSS speed for pitch controller, rad/s.
param.PC_Vrated     = 11.4;                 % Rated wind speed, m/s.
param.PC_Vmax       = 24;                   % Maximum wind speed, m/s.

% Variable Speed Torque Controller setpoints
param.VS_MaxRat     = 1.5e5;                                                % Maximum torque rate (in absolute value) in torque controller, N-m/s.
param.VS_Rgn3MP     = 2 * pi/180;                                           % Minimum pitch angle at which the torque is computed as if we are in region 3 regardless of the generator speed, rad. -- chosen to be 1.0 degree above PC_MinPit
param.VS_RtGnSp     = 50.2655;                                              % Rated generator speed (HSS side), rad/s. 
param.VS_RtPwr      = 10000000.0/param.GenEff;                              % Rated generator generator power in Region 3, Watts. -- chosen to be 10MW divided by the electrical generator efficiency of 96%
param.VS_RatedTq    = param.VS_RtPwr/param.PC_RefSpd * param.GenEff;        % Rated generator torque in Region 3 (HSS side), N-m.
param.VS_MaxTq      = param.VS_RatedTq * 1.1;                               % Maximum generator torque in Region 3 (HSS side), N-m.
param.VS_MinSpd     = 6*pi/30;                                              % Minimum rotor speed (rad/s)
param.VS_Vmin       = 4;                                                    % Minimum wind speed, m/s

end