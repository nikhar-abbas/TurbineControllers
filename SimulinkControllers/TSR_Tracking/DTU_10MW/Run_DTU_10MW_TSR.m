%% TSR Referenece Controller 
% Run the DTU_10MW simulation initialized with this script
%
% This implements a controller to track tip-speed-ratio in below rated
% operation, and optimal rotor speed in above rated operation. A formal
% writeup of the logic used will be presented at WindTech 2019. 

%% Setup Paths

% Fast Model 
% ModDir = '/Users/nabbas/Documents/TurbineModels/DTU_10MW/DTU10MWRWT/Baseline';

% ModDir = '/Users/nabbas/Documents/TurbineModels/DTU_10MW/DTU10MWRWT_NAUTILUS_GoM_FAST_v1.00/Linearizations/Case1_AllFloat/';
% ModDir = '/Users/nabbas/Documents/TurbineModels/DTU_10MW/DTU10MWRWT_NAUTILUS_GoM_FAST_v1.00/Baseline/';

ModDir = '/Users/nabbas/Documents/TurbineModels/DTU_10MW/DTU10MWRWT_OO_GoM_FAST_v1.00/Linearizations/Case1_AllFloat/';

% Controller path
ContPath = '/Users/nabbas/Documents/TurbineModels/TurbineControllers/SimulinkControllers/TSR_Tracking/';
addpath(ContPath)

%% Define Filenames
% ModName = 'DTU_10MW_RWT.fst';
% ElastoFile = 'DTU_10MW_RWT_ElastoDyn.dat';
% ServoFile = 'DTU_10MW_ServoDyn.dat';
% ModName = 'DTU_10MW_NAUTILUS_GoM.fst';
% ElastoFile = 'DTU_10MW_NAUTILUS_GoM_ElastoDyn.dat';
% ServoFile = 'DTU_10MW_NAUTILUS_GoM_ServoDyn_Lin.dat';
ModName = 'DTU_10MW_OO_GoM.fst';
ElastoFile = 'DTU_10MW_OO_GoM_ElastoDyn.dat';
ServoFile = 'DTU_10MW_OO_GoM_ServoDyn.dat';

FAST_InputFileName = [ModDir filesep ModName];

%% Simulation and controller setup
servoparams = {'PCMode', 'VSContrl', 'HSSBrMode', 'YCMode'};
% Pre_FastMod([ModDir filesep ServoFile], servoparams, {4,4,4,4});
Pre_FastMod([ModDir filesep ServoFile], servoparams, {0,1,0,0});
FastIn = Pre_SimSetup(ModDir, ModName, ElastoFile);
dt = FastIn.DT;
TMax = FastIn.TMax;         
ContParam = Pre_ContParam_TSR_DTU10MW;

%% Load CpSurface 
cpscan = load('/Users/nabbas/Documents/TurbineModels/DTU_10MW/DTU10MWRWT/CpScan/CpScan.mat');
TSRvec = cpscan.TSR;
zind = find(cpscan.BlPitch == 0);
Cpvec = cpscan.Cpmat(:,zind)';
TSR_opt = TSRvec(Cpvec == max(Cpvec));
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
[Filt.HSS.b,Filt.HSS.a] = filt_2lp_D(ContParam.HSSfilt_omn,1,dt); % ContParam.HSSfilt_omn
[Filt.GBFilt.b,Filt.GBFilt.a] = filt_1lp_D(ContParam.HSSfilt_omn,dt); 
[Filt.Wind.b,Filt.Wind.a] = filt_1lp_D(ContParam.WindSpeedEstfilt_omn,dt); 

%% Load Outlist
OutName = 'DTU_10MW_OO_GoM.SFunc.out';
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

simout.ContParam = ContParam;
%% Plots, if you want them
Pl_FastPlots(simout);

% % Setpoint smoothing
% delplots = 1;
% if delplots
%     figure(1)
%     myplot(DelOmega); hold on
%     title('DelOmega')
%     figure(2)
%     myplot(Omega_tg_ref); hold on
%     title('Torque Reference')
%     figure(3)
%     myplot(Omega_bg_ref); hold on
%     title('BldPitch Reference')
% end
% 
% figure
% myplot(Omega_tg_ref); hold on
% myplot(Omega_bg_ref);
% myplot(simout.Time, simout.GenSpeed*pi/30);
% legend('Torque Ref','BldPitch Ref', 'GenSpeed')

