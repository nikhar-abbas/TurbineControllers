%% Cp Scan
% This script is written to analyze a given turbine model and construct a
% Cp surface.
%
%
% Inputs: None - this isn't a function. But you do need to set some things
%         up, this is explained more below
%
% Outputs: This function will save a structure called CpScan in your model
%          working directory
%
%
% NOTE: On OSX, this script needs to be run via the terminal - or via a
% MATLAB gui initiated in the terminal - due to $PATH configurations.
%
% ANOTHER NOTE: Line 68(ish) of this code calls the system command that
% the user has setup to run openfast. Generally, it is along the lines of
% "openfast (modelname).fst". You might need to edit this line accordingly.
%
% Recommended: Setup OpenFast model in it's own folder for Cp surface
% generation, setup model paths and filenames in this .m script
% accordingly, then run this script via terminal. 
%
% ---- Necessary Setup -----
% Elastodyn: Switch all degrees of freedom to False. 
% Servodyn: Switch all control modes to 0, and VSGenModel= 0 or 1;
% Aerodyn15: WakeMod=1, AFAeroMod=1, TwrPotent=0
% InflowWind: WindType=1, PLexp=0
% Model.fst: TMax = 1; CompElast=1, CompInflow=1, CompAero=2, CompServo=1
%
% !!!! RtAeroCp and RtTSR outputs must be enabled in AeroDyn15
%
%
%
% Nikhar Abbas - February 2019

%% Model Directory and Filenames
% ModDir = '/Users/nabbas/Documents/TurbineModels/NREL_5MW/CpScan';
ModDir = '/Users/nabbas/Documents/TurbineModels/DTU_10MW/DTU10MWRWT/CpScan';

% Important Parameter Files (In relation to ModDir)
Servo = 'DTU_10MW_ServoDyn.dat';
Elasto = 'DTU_10MW_RWT_ElastoDyn.dat';
Inflow = 'DTU_10MW_InflowWind.dat';
Aero = 'DTU_10MW_RWT_AeroDyn15.dat';
Init = 'DTU_10MW_RWT.fst';
Out = 'DTU_10MW_RWT.out';



%% Simulation setup
BlPitch = [-2:.5:60];                        % blade pitch angles
R = 89.1500*cos(2.5*pi/180);                 % rotor radius (m)
lambda = 1:.25:25;                           % tip speed ratios
v = 10;                                      % wind speed (m/s)
omega = (lambda*v/R) * (30/pi);              % Rotor speeds (rpm)


Pre_FastMod([ModDir filesep Inflow],{'HWindSpeed'},{v})

%% Run Simulation
for i = 1:length(BlPitch)
    for j = 1:length(omega)        
        % Modify Elastodyn
        Pre_FastMod([ModDir filesep Elasto],{'BlPitch','RotSpeed'},{BlPitch(i),omega(j)})       
        
        % Run simulation - note, this may need to be changed depending on OS and user-specific openfast configuration
        system(['openfast_dev ', ModDir, filesep, Init])
        
        % Load FAST output Data
        fastout = Post_LoadFastOut([ModDir filesep Out]);
        
        % Define TSR and CP Matrices (Rt Speed x BlPitch)
        TSRmat(j,i) = mean(fastout.RtTSR);
        Cpmat(j,i) = mean(fastout.RtAeroCp);
    end
end

%% Save Data
CpScan.BlPitch = BlPitch;
CpScan.TSR = lambda; 
CpScan.omega = omega;
CpScan.TSRmat = TSRmat;
CpScan.Cpmat = Cpmat;
save([ModDir, filesep, 'CpScan.mat'],'-struct','CpScan')




