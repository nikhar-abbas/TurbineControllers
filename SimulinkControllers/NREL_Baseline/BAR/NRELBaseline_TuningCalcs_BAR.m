 function [PC_Kp, PC_Ki, VS_K] = NRELBaseline_TuningCalcs_BAR(param)
% BAR Scheduling and Tuning Parameters
% 
% Inputs: param - structure of parameters from *ControlParameters*.m
%
% Outputs: PC_Kp - Proportional Gain
%          PC_Ki - Integral Gain
%          VS_K -  K for tau_g = K*omega^2 law
%
% Nikhar Abbas

%% Torque controller

R = param.RotorRad;              % Swept Area Radius (m)
rho = param.rho;                 % Air Density (kg/m^3)
Cp = param.CpMax;                % Power Coefficient
lambda = param.TSRopt;            % Tip Speed ratio
Ng = param.Ng;                 % Gearbox Ratio

% Generator Torque Contant
VS_K = (pi*rho*(R)^5*Cp) / (2*lambda^3 * Ng^3); 


%% Pitch Controller

J = param.J;     % Drivetrain Inertia cast to LSS (kg*m^2)
Om_o = param.RRSpeed;            % Rated Low Speed Shaft (Rotor) Rotational Speed (rad/s)
zeta = 1;                     % Damping Ratio
om = 0.6;                      % Rotor Natural Frequency (rad/s)
dPdt = -3.4909e8;                % Pitch Sensitivity at theta = 0 (watt/rad)

% Gains
PC_Kp = (2 * J * Om_o * zeta * om) / (Ng * -dPdt);
PC_Ki = (J * Om_o * om^2) / (Ng * -dPdt);

% Gains from Alan, and adjusted
% PC_Kp          = 0.0238 * .2/.6;               % [s]
% PC_Ki          = 0.0169 * (.2/.6)^2;              % [-]

%%
% Om_o = 9.6 * pi/30;            % Rated Low Speed Shaft (Rotor) Rotational Speed (rad/s)
% zeta = 0.5;                     % Damping Ratio
% om = 0.4 ;                      % Rotor Natural Frequency (rad/s)
% dPdt = -3.4909e8;  
% Igen = 590.9651;                 % Generator Inertia reletave to HSS (kg*m^2)
% Irot = 301086080.000;            % Rotor Inertia (kg*m^2)
% Id = Irot + Ng^2 * Igen;     % Drivetrain Inertia cast to LSS (kg*m^2)
% A =  -.4643 ;
% B =  -.7695  ;
%               % Pitch Sensitivity at theta = 0 (watt/rad)
% 
% % Gains
% Kp = (-2*om*zeta-A)/(B*Ng);
% Ki = -om^2 /(B*Ng);
% Kpstab = -A/(B*Ng);
% look = -A-B*Ng*Kp;
% 
% PC_Kp = Kpstab;
% PC_Ki = Ki;
end