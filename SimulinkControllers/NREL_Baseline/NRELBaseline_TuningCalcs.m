% Controller Tuning Calculations

% NREL 5MW OC3HYWIND Scheduling and Tuning Parameters
%% Torque controller

R = 62.94;              % Swept Area Radius (m)
rho = 1.225;             % Air Density (kg/m^3)
Cp = .482;              % Power Coefficient
lambda = 7.55           % Tip Speed ratio
Gb = 97;                 % Gearbox Ratio

% Generator Torque Contant
K = (pi*rho*(R)^5*Cp) / (2*lambda^3 * Gb^3) 


%% Pitch Controller

Igen = 534.116;                 % Generator Inertia reletave to HSS (kg*m^2)
Irot = 38759227.492;            % Rotor Inertia (kg*m^2)
Ngear = 50;                     % High-speed to Low-speed GB Ratio 
Id = Irot + Ngear^2 * Igen;     % Drivetrain Inertia cast to LSS (kg*m^2)
Om_o = 12.1 * pi/30;            % Rated Low Speed Shaft (Rotor) Rotational Speed (rad/s)
zeta = 0.7;                     % Damping Ratio
om = 0.6 ;                      % Rotor Natural Frequency (rad/s)
dPdt = -25.52e6;                % Pitch Sensitivity at theta = 0 (watt/rad)

% Gains
Kp = (2 * Id * Om_o * zeta * om) / (Ngear * -dPdt)
Ki = (Id * Om_o * om^2) / (Ngear * -dPdt)

