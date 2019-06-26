% RUN NREL_5MW
% Run the NREL_5MW simulation initialized with this script

%% Setup Paths

% Add Controller and Fast8 directories to path
% addpath('C:\Users\Nikhar\Documents\Research\Controllers\NREL_5MW\')  % Controller
% addpath('C:\FAST8\bin')                                     % Fast8

% Fast Model Path
ModName = '5MW_Land_Shutdown.fst';
% ModName = 'istc2.00-3.00..fst';
ModDir = '/Users/nabbas/Documents/TurbineModels/NREL_5MW/5MW_Land_Shutdown';

FAST_InputFileName = [ModDir filesep ModName];
 %% Simulation and controller setup
ServoFile = 'NRELBsline5MW_Onshore_ServoDyn.dat';
servoparams = {'PCMode', 'VSContrl', 'HSSBrMode', 'YCMode'};
% Pre_FastMod([ModDir filesep ServoFile], servoparams, {4,4,4,4});
Pre_FastMod([ModDir filesep ServoFile], servoparams, {5,5,0,0});
ElastoName = 'NRELBsline5MW_Onshore_ElastoDyn.dat';
FastIn = SimSetup(ModDir, ModName, ElastoName);
dt = FastIn.DT;
TMax = FastIn.TMax;         
ContParam = ControlParameters;

SH_MaxPit = ContParam.SH_MaxPit;
%% Define filters
% [Filt.BldPitch.b,Filt.BldPitch.a] = filt_2lp_D(1/ContParam.SH_Tau * 2 * pi,1,dt);
[Filt.BldPitch.b,Filt.BldPitch.a] = filt_1lp_D(1/ContParam.SH_Tau,dt);

%% Load Outlist
OutName = '5MW_Land_Shutdown.SFunc.out';
SFunc_OutfileName = [ModDir filesep OutName];
OutList = Post_LoadOutlist(SFunc_OutfileName); 
                    
                    
%% Run Simulation
sim('NREL_5MW_Shutdown.mdl',[0,TMax]);

for i = 1:length(OutList)
    try
        simout.(OutList{i}) = FAST_Out.Data(:,i);
    catch
        warning(['Outlist Parameter ' OutList{i} ' was not loaded from the fast.out file.'])
    end
end
