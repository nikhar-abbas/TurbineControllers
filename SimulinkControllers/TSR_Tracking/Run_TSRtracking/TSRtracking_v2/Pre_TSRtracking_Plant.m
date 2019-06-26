function [A,Bb,Beta_op,vv] = Pre_TSRtracking_Plant(ContParam,cpscan)
% This function finds the linearized plant parameters for a specific
% turbine. In below rated operation, the plant is linearized about the
% optimal tip-speed ratio. In above rated, the plant is linearized about
% the operating point at rated rotor speed, and depends on wind speed. The
% linearized model is defined by:
% omega = A(v) + Bt*tau_g + Bb*beta
% Note: Because Bt is unchanged in all operation, it is not calculated here
% specifically, and is calculated in the torque controller gain schedule
% that is a part of TSR_tracking.mdl. 
%
%
% Inputs: ContParam - Structure of control parameters found in
%                     ControlParameters_TSR.m
%         cpscan - Structure of Cp surface data found after running
%                  An_Cpscan.m
% Outputs: A - Vector of system matrices at varied wind speeds.
%          Bb - Vector of blade pitch input gain matrices at varied wind
%               speeds
%          Beta_op - Vectore of operational blade pitch angles at varied
%                    wind speeds, deg. 
%          vv - Wind speeds swept and linearized at, m/s. 
%
% Nikhar Abbas - May 2019

%% Load Turbine Parameters
J = ContParam.J;
rho = ContParam.rho;                            % Air Density (kg/m^3)
R = ContParam.RotorRad;                         % Rotor Radius (m)
Ar = pi*R^2; 
Ng = ContParam.GBRatio; 
RRspeed = ContParam.RRSpeed; 
Vmin = ContParam.VS_Vmin;
Vrat = ContParam.PC_Vrated;
Vmax = ContParam.PC_Vmax;

%% Load Cp data
TSRvec = cpscan.TSR;
Cpvec = cpscan.Cpmat(:,(cpscan.BlPitch == 0));
Betavec = cpscan.BlPitch .* pi/180;
Cpmat = cpscan.Cpmat;

%% Find Cp Operating Points
TSRr = RRspeed*R/Vrat;
vv_br = [Vmin:.2:Vrat-eps]; 
vv_ar = [Vrat:.2:Vmax];
vv_ar = vv_ar(2:end);
vv = [vv_br vv_ar];
TSR_br = ones(1,length(vv_br)) * TSRvec(Cpvec == max(Cpvec));
TSR_ar = RRspeed.*R./vv_ar;
TSRop = [TSR_br TSR_ar];
Cpr = interp1(TSRvec,Cpvec,TSR_ar(1));
Cp_op_br = ones(1,length(vv_br)) * max(Cpvec);
Cp_op_ar = Cpr.*(TSR_ar./TSRr).^3;

Cp_op = [Cp_op_br Cp_op_ar];


%% Find linearized state matrices
A = zeros(1,length(TSRop));
Bb = zeros(1,length(TSRop));
for toi = 1:length(TSRop)
    
tsr = TSRop(toi); % Operational TSR

% Difference vectors
dB = Betavec(1:end-1) + (Betavec(2) - Betavec(1))/2;
dTSR = TSRvec(1:end-1) + (TSRvec(2) - TSRvec(1))/2;

% ---- Cp Operating conditions ----
CpTSR = zeros(1,length(Betavec));
CpB = zeros(1,length(TSRvec));
for Bi = 1:length(Betavec)
    CpTSR(Bi) = interp1(TSRvec, Cpmat(:,Bi), tsr); % Vector of Cp values corresponding to operational TSR
end

%Saturate operational TSR
Cp_op(toi) = max( min(Cp_op(toi), max(CpTSR)), min(CpTSR));

% Operational Beta to being linearized around
CpMi = find(CpTSR == max(CpTSR));
Beta_op(toi) = interp1(CpTSR(CpMi:end),Betavec(CpMi:end),Cp_op(toi));

% Saturate TSR and Beta
Beta_op(toi) = max(min(Beta_op(toi),dB(end)),dB(1));
tsr_sat(toi) = max(min(tsr,dTSR(end)),dTSR(1));


for TSRi = 1:length(TSRvec)
    CpB(TSRi) = interp1(Betavec,Cpmat(TSRi,:),Beta_op(toi)); % Vector of Cp values corresponding to operational Beta
end

% Derivative Vectors
dCp_B = diff(CpTSR)./diff(Betavec); % Difference of Cp w.r.t. Beta
dCp_tsr = diff(CpB)./diff(TSRvec); % Difference of Cp w.r.t. TSR


% Operating Points on Cp Surface
Cp(toi) = interp1(Betavec,CpTSR,Beta_op(toi));
dCpdB(toi) = interp1(dB,dCp_B,Beta_op(toi));
dCpdTSR(toi) = interp1(dTSR,dCp_tsr,tsr_sat(toi));


dtdb(toi) = 1/2*rho*Ar*R*dCpdB(toi)*vv(toi)^3 * 1/RRspeed;

dtdl = 1/(2)*rho*Ar*R*vv(toi)^2*(1/tsr_sat(toi)^2)* (dCpdTSR(toi)*tsr_sat(toi) - Cp(toi)); % assume operating at optimal
dldo = R/vv(toi);
dtdo = dtdl*dldo;

A(toi) = dtdo/J;            % Plant pole
% B_t = -Ng/J;              % Torque input gain 
Bb(toi) = dtdb(toi)/J;     % BldPitch iinput gain

%% Wind Disturbance Input gain
% dldv = -tsr/vv(toi); 
% dtdv = dtdl*dldv;
% B_v = dtdv/J;

end

end