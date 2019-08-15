function param = ControlParameters_NRELBaseline
%Control parameters for NREL 5MW Land Based controller

% Generator speed filter
param.CornerFreq    = 1.570796;            % Corner frequency (-3dB point) in the recursive, single-pole, low-pass filter, rad/s. -- chosen to be 1/4 the blade edgewise natural frequency ( 1/4 of approx. 1Hz = 0.25Hz = 1.570796rad/s)
% param.OnePlusEps    = 1.0 + EPSILON(OnePlusEps)       % The number slighty greater than unity in single precision.

% Pitch Controller 
param.PC_DT         = 0.00125;              % Communication interval for pitch  controller, sec.
param.PC_KI         = 0.008068634;         % JASON:REDUCE GAINS FOR HYWIND::0.008068634;   --- Integral gain for pitch controller at rated pitch (zero), (-).
param.PC_KK         = 0.1099965;            % Pitch angle where the the derivative of the aerodynamic power w.r.t. pitch has increased by a factor of two relative to the derivative at rated pitch (zero), rad.
param.PC_KP         = 0.01882681;          % JASON:REDUCE GAINS FOR HYWIND:0.01882681 --- Proportional gain for pitch controller at rated pitch (zero), sec.
param.PC_MaxPit     = pi/2;                 % Maximum pitch setting in pitch controller, rad.
param.PC_MaxRat     = 0.1396263;            % Maximum pitch  rate (in absolute value) in pitch  controller, rad/s.
param.PC_MinPit     = 0.0;                  % Minimum pitch setting in pitch controller, rad.
param.PC_RefSpd     = 122.9096;             % Desired (reference) HSS speed for pitch controller, rad/s.

% Variable Speed Torque Controller
param.VS_CtInSp     = 70.16224;             % Transitional generator speed (HSS side) between regions 1 and 1 1/2, rad/s.
param.VS_DT         = 0.00125;              % Communication interval for torque controller, sec.
param.VS_MaxRat     = 15000.0;              % Maximum torque rate (in absolute value) in torque controller, N-m/s.
param.VS_MaxTq      = 47402.91;             % Maximum generator torque in Region 3 (HSS side), N-m. -- chosen to be 10% above VS_RtTq = 43.09355kNm
param.VS_Rgn2K      = 2.332287;             % Generator torque constant in Region 2 (HSS side), N-m/(rad/s)^2.
param.VS_Rgn2Sp     = 91.21091;             % Transitional generator speed (HSS side) between regions 1 1/2 and 2, rad/s.
param.VS_Rgn3MP     = 0.01745329;           % Minimum pitch angle at which the torque is computed as if we are in region 3 regardless of the generator speed, rad. -- chosen to be 1.0 degree above PC_MinPit
param.VS_RtGnSp     = 121.6805;             % Rated generator speed (HSS side), rad/s. -- chosen to be 99% of PC_RefSpd
param.VS_RtPwr      = 5296610.0;            % Rated generator generator power in Region 3, Watts. -- chosen to be 5MW divided by the electrical generator efficiency of 94.4%
param.VS_SlPc       = 10.0;                 % Rated generator slip percentage in Region 2 1/2, %.

% Shutdown Controller
param.SH_MaxPit   = 15 * pi/180; 22;                   % Maximum Blade Pitch before shutdown, rad.
param.SH_Tau  = 10;                   % Time constant for filtered shutdown signal

% Housekeeping
param.UnDb          = 85;                   % I/O unit for the debugging information
param.Un            = 87;                   % I/O unit for pack/unpack (checkpoint & restart)
param.R2D           = 57.295780;            % Factor to convert radians to degrees.
param.RPS2RPM       = 9.5492966;            % Factor to convert radians per second to revolutions per minute.
param.GBRatio       = 97;                   % Gearbox Ratio
param.GenEff        = 94.4;                 % Generator Efficiency (%)
param.RRSpeed       = 12.1;                 % Rated Rotor Speed (rpm)
end