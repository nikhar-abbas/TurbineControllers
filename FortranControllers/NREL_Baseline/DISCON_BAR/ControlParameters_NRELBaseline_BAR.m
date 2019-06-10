function param = ControlParameters_NRELBaseline_BAR
%Control parameters for BAR controller


% Turbine and Environmental ParametersParameters
param.J = 301086080.000 + 590.965098296*96.76^2;                            % Total Rotor Inertia, kg-m^2.
param.RotorRad      = 103.1143;                                             % Rotor Radius, m.
param.Ng            = 96.76;                                                % Gearbox Ratio, -.
param.GenEff        = 0.944;                                                % Generator Efficiency, 1/%
param.RRSpeed       = 6.3346 * pi/30;                                       % Rated Rotor Speed, rad/s.
param.rho           = 1.198;                                                % Air Density, kg/m^3.

% Cp Surfacer Parameters
param.CpMax = 0.4921;                                                       % Maximum Cp, -. Found using An_CpScan.m
param.TSRopt = 8.8;                                                         % TSR at CpMax, -. 

% Load PC Gains and VS_K
[PC_Kp, PC_Ki, VS_K] = NRELBaseline_TuningCalcs_BAR(param);

% Generator speed filter
param.filt_HSS    = 0.25; 1.570796;                                         % Corner frequency (-3dB point) in the recursive, single-pole, low-pass filter, Hz. -- chosen to be 1/4 the blade edgewise natural frequency ( 1/4 of approx. 1Hz = 0.25Hz = 1.570796rad/s)
param.filt_GB     = 1/10;                                                   % Cornering frequency of first order LPF for region 2.5 smoothing, Hz

% Region 2.5 Gain Bias
param.GainBias_Mode     = 0;                                                % Gain Bias Mode, 0 = None, 1 = Schlipf Methods.
param.VS_GainBias       = 30; 0.031;                                        % VS Controller Bias Gian for Region 2.5 smoothing, -.
param.PC_GainBias       = 0.0001; 0.81;                                     % Pitch Controller Bias Gian for Region 2.5 smoothing, -.

% Pitch Controller 
param.PC_DT         = 0.01;                                                 % Communication interval for pitch  controller, sec.
param.PC_KI         = PC_Ki;                                                % Integral gain for pitch controller at rated pitch (zero), (-).
param.PC_KK         = 21 * pi/180;                               % Pitch angle where the the derivative of the aerodynamic power w.r.t. pitch has increased by a factor of two relative to the derivative at rated pitch (zero), rad.
param.PC_KP         = PC_Kp;                                                % Proportional gain for pitch controller at rated pitch (zero), sec.
param.PC_MaxPit     = 90 * pi/180;                                          % Maximum pitch setting in pitch controller, rad.
param.PC_MaxRat     = 2 * pi/180;                                           % Maximum pitch rate (in absolute value) in pitch  controller, rad/s.
param.PC_MinPit     = -0.8  * (pi/180);                                     % Minimum pitch setting in pitch controller, rad.
param.PC_RefSpd     = 64.1862;                                              % Desired (reference) HSS speed for pitch controller, rad/s.

% Variable Speed Torque Controller
param.VS_CtInSp     = 100 * pi/30;                                          % Transitional generator speed (HSS side) between regions 1 and 1 1/2, rad/s.
param.VS_MaxRat     = 15e5;                                                 % Maximum torque rate (in absolute value) in torque controller, N-m/s.
param.VS_RtPwr      = 5000000/param.GenEff;                                              % Rated generator generator power in Region 3, Watts. -- chosen to be 5MW divided by the electrical generator efficiency of 94.4%
param.VS_RatedTq    = param.VS_RtPwr/param.PC_RefSpd;                       % Rated Torqure, Nm.
param.VS_MaxTq      = param.VS_RatedTq * 1.1;                               % Maximum generator torque in Region 3 (HSS side), N-m. -- chosen to be 10% above VS_RtTq = 43.09355kNm
param.VS_Rgn2K      = VS_K;                                                 % Generator torque constant in Region 2 (HSS side), N-m/(rad/s)^2.
param.VS_Rgn2Sp     = 150 * pi/30;                                          % Transitional generator speed (HSS side) between regions 1 1/2 and 2, rad/s.
param.VS_Rgn3MP     = 1 * pi/180;                                           % Minimum pitch angle at which the torque is computed as if we are in region 3 regardless of the generator speed, rad. -- chosen to be 1.0 degree above PC_MinPit
param.VS_RtGnSp     = param.PC_RefSpd * 1;                                  % Rated generator speed (HSS side), rad/s.
param.VS_SlPc       = 15;                                                   % Generator Slip Percentage, %.

% Shutdown Controller
param.SH_MaxPit   = 35 * pi/180;            % Maximum Blade Pitch before shutdown, rad.
param.SH_Tau  = 10;                   % Time constant for filtered shutdown signal

% Actuator Model
param.PitchActuator.Mode            = 0;                                    % 0: none; 1: Delay; 2: PT2 (omega, xi, x1_con)
param.PitchActuator.omega           = 2*pi;                                 % [rad/s]
param.PitchActuator.zeta            = 0.7;                                  % [-]
param.PitchActuator.theta_max     	= 90 * pi/180;                          % [rad]
param.PitchActuator.theta_min     	= deg2rad(-.80);                        % [rad]
param.PitchActuator.Delay           = 2;                                    % [s]
[b,a] = filt_2lp_D(param.PitchActuator.omega,param.PitchActuator.zeta,param.PC_DT);
param.PitchActuator.TFb             = b;
param.PitchActuator.TFa             = a;


end