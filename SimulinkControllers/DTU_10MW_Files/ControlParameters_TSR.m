function param = ControlParameters_TSR
%Control parameters for DTU 10MW (fixed bottom) controller

% Turbine Parameters
param.J = 156348032.208;                  % Rotor Inertia (kg-m^2)
param.RotorRad      = 89.15;                % Rotor Radius
param.GBRatio       = 50;                   % Gearbox Ratio
param.GenEff        = 96;                   % Generator Efficiency (%)
param.RRSpeed       = 9.6;                  % Rated Rotor Speed (rpm)
                        % Gearbox Ratio
% Load Tunings
[K, Kp, Ki] = TuningCalcs;

% Generator speed filter
param.HSSfilt_omn          = 4.519 * 3/4;       % Corner frequency in the recursive, second order low pass filter of the HSS Speed - Chosen to be 3/4 of the first drivetrain natural frequency (Hz)
param.WindSpeedfilt_omn    = 0.0259;            % Corner frequency for GenTq (Hz) - Calculated as the theoretical system pole at cut in wind speed
                                                % WindSpeedfilt_omn = 1/(2*J)*rho*pi*R^4*v_cutin*(1/TSR_opt^2)* (0 - Cp_opt); % assume operating at optimal conditions
                                                %   - Cp_opt and TSR_opt can be found using the Cp surface 
% % Pitch Controller 
param.PC_DT         = 0.00125;              % Communication interval for pitch  controller, sec.
param.PC_KI         = Ki;                   % Integral gain for pitch controller at rated pitch (zero), (-).
param.PC_KK         = 164.13; 2.8646;       % Pitch angle where the the derivative of the aerodynamic power w.r.t. pitch has increased by a factor of two relative to the derivative at rated pitch (zero), rad.
param.PC_KK2        = 702.09; 
param.PC_KP         = Kp;                   % Proportional gain for pitch controller at rated pitch (zero), sec.
param.PC_MaxPit     = 90 * (pi/180);        % Maximum pitch setting in pitch controller, rad.
param.PC_MaxRat     = 10 * (pi/180);        % Maximum pitch  rate (in absolute value) in pitch  controller, rad/s.
param.PC_MinPit     = 0  * (pi/180);        % Minimum pitch setting in pitch controller, rad.
param.PC_RefSpd     = 50.2655;              % Desired (reference) HSS speed for pitch controller, rad/s.

% Variable Speed Torque Controller
param.VS_DT         = 0.0125;               % Communication interval for torque controller, sec.
param.VS_MaxRat     = 1.5e5;                % Maximum torque rate (in absolute value) in torque controller, N-m/s.
param.VS_CtInSp     = 26.1799;              % Transitional generator speed (HSS side) between regions 1 and 1 1/2, rad/s.
param.VS_Rgn2Sp     = 31.4159;              % Transitional generator speed (HSS side) between regions 1 1/2 and 2, rad/s.
param.VS_Rgn3MP     = 0.0175;               % Minimum pitch angle at which the torque is computed as if we are in region 3 regardless of the generator speed, rad. -- chosen to be 1.0 degree above PC_MinPit
param.VS_RtGnSp     = 50.2655;              % Rated generator speed (HSS side), rad/s. 
param.VS_RtPwr      = 10000000.0/0.96;      % Rated generator generator power in Region 3, Watts. -- chosen to be 10MW divided by the electrical generator efficiency of 96%
param.VS_SlPc       = 0; %25;               % Rated generator slip percentage in Region 2 1/2, %.
param.VS_MaxTq      = param.VS_RtPwr/param.PC_RefSpd;       % Maximum generator torque in Region 3 (HSS side), N-m. -- chosen to be VS_RtTq 
param.VS_MinSpd     = 6*pi/30;              % Minimum rotor speed (rad/s)


% Housekeeping
param.UnDb          = 85;                   % I/O unit for the debugging information
param.Un            = 87;                   % I/O unit for pack/unpack (checkpoint & restart)
param.R2D           = 57.295780;            % Factor to convert radians to degrees.
param.RPS2RPM       = 9.5492966;            % Factor to convert radians per second to revolutions per minute.
param.rho           = 1.225;                % Air Density (kg/m^3)
end