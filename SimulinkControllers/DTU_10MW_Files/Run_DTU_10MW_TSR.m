%% TSR Refrenece Controller 
% Run the DTU_10MW simulation initialized with this script
%
% This implements a controller that employs the use of Tip-Speed-Ratio
% (TSR) tracking PI loops 

%% Setup Paths

% Add Controller and Fast8 directories to path
% addpath('C:\Users\Nikhar\Documents\Research\Controllers\NREL_5MW\')  % Controller
% addpath('C:\FAST8\bin')                                     % Fast8

% Fast Model 
ModName = 'DTU_10MW_RWT.fst';
ModDir = '/Users/nabbas/Documents/TurbineModels/DTU_10MW/DTU10MWRWT/Baseline';

% Controller path
ContPath = '/Users/nabbas/Documents/TurbineModels/SimulinkControllers/TSR_Tracking/';
addpath(ContPath)

FAST_InputFileName = [ModDir filesep ModName];

%% Simulation and controller setup
ElastoFile = 'DTU_10MW_RWT_ElastoDyn.dat';
ServoFile = 'DTU_10MW_ServoDyn.dat';
servoparams = {'PCMode', 'VSContrl', 'HSSBrMode', 'YCMode'};
Pre_FastMod([ModDir filesep ServoFile], servoparams, {4,4,4,4});
% Pre_FastMod([ModDir filesep ServoFile], servoparams, {5,5,0,0});
FastIn = SimSetup(ModDir, ModName, ElastoFile);
dt = FastIn.DT;
TMax = FastIn.TMax;         
ContParam = ControlParameters_TSR;

%% Load CpSurface 
cpscan = load('/Users/nabbas/Documents/TurbineModels/DTU_10MW/DTU10MWRWT/CpScan/MatFiles/CpScan_FullSurf.mat');
TSRvec = cpscan.TSR;
Cpvec = cpscan.Cpmat(:,(cpscan.BlPitch == 0))';
%% Define Filter Parameters
[Filt.HSS.b,Filt.HSS.a] = filt_2lp_D(ContParam.HSSfilt_omn,1,dt);
[Filt.Wind.b,Filt.Wind.a] = filt_2lp_D(ContParam.WindSpeedfilt_omn,1,dt); 

% To analytically find ContParam.WindSpeedfilt_omn
% WindSpeedfilt_omn = 1/(2*J).*rho.*Ar*R^2.*v_cutin.*(1./TSR_opt.^2).* (0 - Cp_opt); % assume operating at optimal

%% Load Outlist
OutName = 'DTU_10MW_RWT.SFunc.out';
SFunc_OutfileName = [ModDir filesep OutName];
OutList = Post_LoadOutlist(SFunc_OutfileName); 
%% Run Simulation
TSR_opt = TSRvec(Cpvec == max(Cpvec));
sim('TSR_Tracking_v0.mdl',[0,TMax]);

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

%%

% param = "GenPwr"
% 
% plot(simout.Time, simout.(param)), hold on
% plot(fastdll.Time, fastdll.(param)),