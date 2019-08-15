%% TSR Referenece Controller 
% Run the NREL 5MW Turbine simulation initialized with this script
%
% This implements a controller to track tip-speed-ratio in below rated
% operation, and optimal rotor speed in above rated operation. A formal
% writeup of the logic used will be presented at WindTech 2019. 

%% Setup Paths

% Fast Model 
ModDir = '/Users/nabbas/Documents/TurbineModels/NREL_5MW/5MW_Land';

% Controller path
ContPath = '/Users/nabbas/Documents/TurbineModels/TurbineControllers/SimulinkControllers/TSR_Tracking/';
addpath(ContPath)

%% Define Filenames
ModName = '5MW_Land.fst';
ElastoFile = 'NRELOffshrBsline5MW_Onshore_ElastoDyn.dat';
ServoFile = 'NRELOffshrBsline5MW_Onshore_ServoDyn.dat';

FAST_InputFileName = [ModDir filesep ModName];

%% Simulation and controller setup
servoparams = {'PCMode', 'VSContrl', 'HSSBrMode', 'YCMode'};
Pre_FastMod([ModDir filesep ServoFile], servoparams, {4,4,4,4});
% Pre_FastMod([ModDir filesep ServoFile], servoparams, {5,5,0,0});
FastIn = Pre_SimSetup(ModDir, ModName, ElastoFile);
dt = FastIn.DT;
TMax = FastIn.TMax;         
ContParam = Pre_ContParam_TSR_NREL5MW;

%% Load CpSurface 
cpscan = load('/Users/nabbas/Documents/TurbineModels/NREL_5MW/CpScan/CpScan.mat');
TSRvec = cpscan.TSR;
zind = find(cpscan.BlPitch == 0);
Cpvec = cpscan.Cpmat(:,zind)';
TSR_opt = TSRvec(Cpvec == max(Cpvec));
TSR_opt = 7.55;
% % Betavec = cpscan.BlPitch(zind:end);
% % Cpmat = cpscan.Cpmat(:,zind:end);

%% Find plant parameters
[Avec,Bbvec,GS,Beta_op,vv] = Pre_TSRtracking_GS(ContParam,cpscan);
ContParam.GS = GS;

% Trim for BldPitch Controller
Bopind = find(Beta_op>0);
Avec_BPC = Avec(Bopind(1):end);
Bbvec_BPC = Bbvec(Bopind(1):end);
Betaop_BPC = Beta_op(Bopind(1):end);
vv_bpc = vv(Bopind(1):end);
%% Define Filter Parameters
[Filt.HSS.b,Filt.HSS.a] = filt_2lp_D(ContParam.filt_HSS,1,dt); % ContParam.HSSfilt_omn
[Filt.GBFilt.b,Filt.GBFilt.a] = filt_1lp_D(ContParam.filt_GB,dt); 
[Filt.Wind.b,Filt.Wind.a] = filt_1lp_D(ContParam.filt_WindSpeedEst,dt); 

%% Load Outlist
OutName = '5MW_Land.SFunc.out';
SFunc_OutfileName = [ModDir filesep OutName];
OutList = Post_LoadOutlist(SFunc_OutfileName); 
%% Run Simulation
% % TSR_opt = TSRvec(Cpvec == max(Cpvec));
sim('TSR_Tracking_v2.mdl',[0,TMax]);

for i = 1:length(OutList)
    try
        simout.(OutList{i}) = FAST_Out.Data(:,i);
    catch
        warning(['Outlist Parameter ' OutList{i} ' was not loaded from the fast.out file.'])
    end
end
simout.VSparams_a = VS_params.signals.values(:,1);
simout.VSparams_rotspeederr = VS_params.signals.values(:,2);
simout.VSparams_Ki = VS_params.signals.values(:,3);
simout.VSparams_Kp = VS_params.signals.values(:,4);
simout.TSR = simout.RotSpeed./simout.Wind1VelX * ContParam.RotorRad * pi/30;
simout.VSparams_omopt = Om_opt.Data;

simout.PCparams_a = PC_params.signals.values(:,1);
simout.PCparams_rotspeederr = PC_params.signals.values(:,2);
simout.PCparams_Ki = PC_params.signals.values(:,3);
simout.PCparams_Kp = PC_params.signals.values(:,4);
simout.PCparams_B_ss = PC_params.signals.values(:,5);

simout.vhat = vhat.Data;
simout.ContParam = ContParam;
%% Plots, if you want them
% Pl_FastPlots(simout);

% Setpoint smoothing
delplots = 1;
if delplots
    figure(1)
    myplot(DelOmega); hold on
    title('DelOmega')
    figure(2)
    myplot(Omega_tg_ref); hold on
    title('Torque Reference')
    figure(3)
    myplot(Omega_bg_ref); hold on
    title('BldPitch Reference')
end
 
figure
myplot(Omega_tg_ref); hold on
myplot(Omega_bg_ref);
myplot(simout.Time, simout.GenSpeed*pi/30);
leg = legend('Torque Controller Reference','Blade Pitch Controller Reference', 'Generator Speed');
leg.Location = 'SouthEast';
xlabel('Time (s)')
ylabel('Generator Speed (rad/s)')
title('Setpoint Smoother Shifting Logic')
set(gca,'FontSize',12)