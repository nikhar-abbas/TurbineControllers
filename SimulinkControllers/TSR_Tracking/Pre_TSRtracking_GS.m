function [A,Bb,GS,Beta_op,vv] = Pre_TSRtracking_GS(ContParam,cpscan)
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
vv_br = [Vmin:.1:Vrat]; 
vv_ar = [Vrat:.1:Vmax];
vv_ar = vv_ar(1:end);
vv = [vv_br vv_ar];
TSR_br = ones(1,length(vv_br)) * TSRvec(Cpvec == max(Cpvec));
TSR_ar = RRspeed.*R./vv_ar;
% TSR_ar(TSR_ar > TSR_br(end))= TSR_br(end);
TSRop = [TSR_br TSR_ar];
Cpr = interp1(TSRvec,Cpvec,TSR_ar(1));
Cp_op_br = ones(1,length(vv_br)) * max(Cpvec);
Cp_op_ar = Cpr.*(TSR_ar./(TSRr)).^3;

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

% Operational Beta to be linearized around
CpMi = find(CpTSR == max(CpTSR));
Beta_op(toi) = interp1(CpTSR(CpMi:end),Betavec(CpMi:end),Cp_op(toi));
% Beta_op(toi) = interp1(CpTSR,Betavec,Cp_op(toi));

% Saturate TSR and Beta
Beta_op(toi) = max(min(Beta_op(toi),dB(end)),dB(1));
tsr_sat(toi) = max(min(tsr,dTSR(end)),dTSR(1));
tsr_sat(toi) = tsr_sat(toi);

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


dtdb(toi) = Ng/2*rho*Ar*R*(1/tsr_sat(toi))*dCpdB(toi)*vv(toi)^2;

dtdl = Ng/(2)*rho*Ar*R*vv(toi)^2*(1/tsr_sat(toi)^2)* (dCpdTSR(toi)*tsr_sat(toi) - Cp(toi)); % assume operating at optimal
dldo = R/vv(toi)/Ng;
dtdo = dtdl*dldo;

A(toi) = dtdo/J;            % Plant pole
B_t = -Ng^2/J;              % Torque input gain 
Bb(toi) = dtdb(toi)/J;     % BldPitch input gain

% Fit A
% pA = polyfit(vv,A,2);
% A = pA(1).*vv.^2+pA(2).*vv+pA(3);
% pBb = polyfit(vv,Bb,2);
% Bb = pBb(1).*vv.^2+pBb(2).*vv+pBb(3);

%% Wind Disturbance Input gain
% dldv = -tsr/vv(toi); 
% dtdv = dtdl*dldv;
% B_v = dtdv/J;

end



%% Gain Schedule

% ----- Generator torque controller -----
% Plant Linearization Points
Avs = A(TSRop == TSR_br(1));
Bvs = B_t;
vv_vs = vv((TSRop == TSR_br(1)));

% Linear fit for Avs w.r.t. v
pAvs = polyfit(vv_vs,Avs,1);
Avs_f = pAvs(1)*vv_vs + pAvs(2);


% Desired behavior
VS_zeta = ContParam.VS_zeta;
VS_om_n = ContParam.VS_om_n;

% % Torque Controller Gains, as a function of linearized v
% Kp_vs = 1/Bvs * (2*VS_zeta*VS_om_n + Avs_f);
% Ki_vs = VS_om_n^2/Bvs;
Kp_vs = 1/Bvs * (2*VS_zeta*VS_om_n + Avs);
Ki_vs = VS_om_n^2/Bvs;

% Linear fit for Kp_vs w.r.t. v
pKp_vs = polyfit(vv_vs,Kp_vs,1);
pKi_vs = Ki_vs;

% ------ Blade Pitch Controller ------
% Plant Linearization Points
Bop_pc = find(Beta_op>0 * pi/180);
Apc = A(Bop_pc(1):end);
Bb_pc = Bb(Bop_pc(1):end);
Betaop_pc = Beta_op(Bop_pc(1):end);
vv_pc = vv(Bop_pc(1):end);

% Desired behavior
PC_zeta = ContParam.PC_zeta;
PC_om_n = ContParam.PC_om_n;

% % Linear fit for Apc w.r.t. beta
% pApc = polyfit(Betaop_pc,Apc,1);
% pBb_pc = polyfit(Betaop_pc,Bb_pc,1);
% Apc_f = pApc(1)*Betaop_pc + pApc(2);
% Bb_pc_f = pBb_pc(1)*Betaop_pc + pBb_pc(2);

% Linear fit for Apc w.r.t. v
pApc = polyfit(vv_pc,Apc,1);
pBb_pc = polyfit(vv_pc,Bb_pc,1);
Apc_f = pApc(1)*vv_pc + pApc(2);
Bb_pc_f = pBb_pc(1)*vv_pc + pBb_pc(2);

% % Blade Pitch Gains, as a function of linearized v or related beta
Kp_pc = 1./Bb_pc_f .* (2*PC_zeta*PC_om_n + Apc_f);
Ki_pc = PC_om_n^2./Bb_pc_f ;
% Kp_pc = 1./Bb_pc .* (2*PC_zeta*PC_om_n + Apc);
% Ki_pc = PC_om_n^2./Bb_pc ;

% % Linear fit, as a function of beta
% pKp_pc = polyfit(Betaop_pc,Kp_pc,1);
% pKi_pc = polyfit(Betaop_pc,Ki_pc,1);

% % Linear fit, as a function of v
% pKp_pc = polyfit(vv_pc,Kp_pc,1);
% pKi_pc = polyfit(vv_pc,Ki_pc,1);



% ----- Save -----
% GS.pKp_vs = pKp_vs;
% GS.pKi_vs = pKi_vs;
% GS.pKp_pc = pKp_pc;
% GS.pKi_pc = pKi_pc;
GS.Kp_vs = Kp_vs;
GS.Ki_vs = Ki_vs*ones(1,length(Kp_vs));
GS.Kp_pc = Kp_pc;
GS.Ki_pc = Ki_pc;
GS.pA = polyfit(vv,A,1);
GS.VS_vv = vv_vs; 
GS.PC_vv = vv_pc;
GS.PC_beta = Betaop_pc;
% %% Gain Schedule
% 
% % ----- Generator torque controller -----
% % Plant Linearization Points
% Avs = A(TSRop == TSR_br(1));
% Bvs = B_t;
% vv_vs = vv((TSRop == TSR_br(1)));
% 
% % Desired behavior
% VS_zeta = ContParam.VS_zeta;
% VS_om_n = ContParam.VS_om_n;
% 
% % Torque Controller Gains, as a function of v
% Kp_vs = 1/Bvs * (2*VS_zeta*VS_om_n + Avs);
% Ki_vs = VS_om_n^2/Bvs;
% 
% % Linear fit for Kp_vs, as a function of v
% pKp_vs = polyfit(vv_vs,Kp_vs,1);
% pKi_vs = Ki_vs;
% 
% % ------ Blade Pitch Controller ------
% % Plant Linearization Points
% Bop_pc = find(Beta_op>0);
% Apc = A(Bop_pc(1)-1:end);
% Bb_pc = Bb(Bop_pc(1)-1:end);
% Betaop_pc = Beta_op(Bop_pc(1)-1:end);
% vv_pc = vv(Bop_pc(1)-1:end);
% 
% % Desired behavior
% PC_zeta = ContParam.PC_zeta;
% PC_om_n = ContParam.PC_om_n;
% 
% % Blade Pitch Gains, as a function of v or related beta
% Kp_pc = 1./Bb_pc .* (2*PC_zeta*PC_om_n + Apc);
% Ki_pc = PC_om_n^2./Bb_pc ;
% 
% % Linear fit, as a function of beta
% pKp_pc = polyfit(Betaop_pc,Kp_pc,1);
% pKi_pc = polyfit(Betaop_pc,Ki_pc,1);
% 
% % ----- Save -----
% GS.pKp_vs = pKp_vs;
% GS.pKi_vs = pKi_vs;
% GS.pKp_pc = pKp_pc;
% GS.pKi_pc = pKi_pc;
% 

end