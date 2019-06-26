function [K, Kp, Ki] = TuningCalcs 
% Controller Tuning Calculations
% DTU 10MW (fixed) Scheduling and Tuning Parameters

% You should/need to automate this

%% Torque controller

R = 86.2; %037;              % Swept Area Radius (m)
rho = 1.225;             % Air Density (kg/m^3)
Cp = .483;              % Power Coefficient
lambda = 7.5;           % Tip Speed ratio
Gb = 50;                 % Gearbox Ratio

% Generator Torque Contant
K = (pi*rho*(R)^5*Cp) / (2*lambda^3 * Gb^3);   
% Tau_K = 9.5e6/1e3; %Well, this is wrong.
% K=eta*0.5*rho*A*Cp_opt*R^3/lambda_opt^3
% Tau_K = 0.85;

%% Pitch Controller

Om_o = 9.6 * pi/30;            % Rated Low Speed Shaft (Rotor) Rotational Speed (rad/s)
zeta = 0.7;                     % Damping Ratio
om = 0.2 ;                      % Rotor Natural Frequency (rad/s)
Ngear = 50;                     % High-speed to Low-speed GB Ratio 
dPdt = -3.4909e8;  
Igen = 1500.5;                 % Generator Inertia reletave to HSS (kg*m^2)
Irot = 156348032.108;            % Rotor Inertia (kg*m^2)
Id = Irot + Ngear^2 * Igen;     % Drivetrain Inertia cast to LSS (kg*m^2)
              % Pitch Sensitivity at theta = 0 (watt/rad)

% Gains
Kp = (2 * Id * Om_o * zeta * om) / (Ngear * -dPdt);
Ki = (Id * Om_o * om^2) / (Ngear * -dPdt);

end