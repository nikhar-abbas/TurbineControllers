% RUN BAR
% Run the NREL_5MW simulation initialized with this script

%% Setup Paths

% Fast Model 
% ModDir = '/Users/nabbas/Documents/TurbineModels/BAR';
ModDir = '/Users/nabbas/Documents/TurbineModels/External/BAR_005a';

% Controller path
ContPath = '/Users/nabbas/Documents/TurbineModels/TurbineControllers/SimulinkControllers/NREL_Baseline/';
addpath(ContPath)

%% Define Filenames
ModName = 'RotorSE_FAST_BAR_004.fst';
ElastoFile = 'RotorSE_FAST_BAR_004_ElastoDyn.dat';
ServoFile = 'RotorSE_FAST_BAR_004_ServoDyn.dat';

FAST_InputFileName = [ModDir filesep ModName];

%% Load CpSurface 
cpscan = load('/Users/nabbas/Documents/TurbineModels/BAR/CpScan.mat');
TSRvec = cpscan.TSR;
zind = find(cpscan.BlPitch == 0);
Cpvec = cpscan.Cpmat(:,zind)';
TSR_opt = TSRvec(Cpvec == max(Cpvec));

%10.5;
 %% Simulation and controller setup
servoparams = {'PCMode', 'VSContrl', 'HSSBrMode', 'YCMode'};
% Pre_FastMod([ModDir filesep ServoFile], servoparams, {4,4,4,4});
Pre_FastMod([ModDir filesep ServoFile], servoparams, {5,5,0,0});
FastIn = Pre_SimSetup(ModDir, ModName, ElastoFile);
% FastIn.RotSpeed = 0;
dt = FastIn.DT;
TMax = FastIn.TMax;         
ContParam = ControlParameters_NRELBaseline_BAR;

SH_MaxPit = ContParam.SH_MaxPit;

% FastIn.RotSpeed*pi/30 * ContParam.Ng
%% Define filters
[Filt.HSS.b,Filt.HSS.a] = filt_2lp_D(ContParam.filt_HSS,1,dt);
[Filt.BldPitch.b,Filt.BldPitch.a] = filt_1lp_D(1/ContParam.SH_Tau,dt);
[Filt.GBFilt.b,Filt.GBFilt.a] = filt_1lp_D(ContParam.filt_GB,dt); 

%% Load Outlist
OutName = 'RotorSE_FAST_BAR_004.SFunc.out';
SFunc_OutfileName = [ModDir filesep OutName];
OutList = Post_LoadOutlist(SFunc_OutfileName); 
                    
                    
%% Run Simulation
sim('NREL_Baseline_NoAct.mdl',[0,TMax]);

for i = 1:length(OutList)
    try
        simout.(OutList{i}) = FAST_Out.Data(:,i);
    catch
        warning(['Outlist Parameter ' OutList{i} ' was not loaded from the fast.out file.'])
    end
end
