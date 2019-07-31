%% TSR Tracking PlotScripts
% Just some fun plots that might be interesting for the TSR Tracking
% Controller. Need to run a messaround and/or runsim file first

%% Cp Surface
% cpscan = load('/Users/nabbas/Documents/TurbineModels/DTU_10MW/DTU10MWRWT/CpScan/CpScan.mat');
cpscan = load('/Users/nabbas/Documents/TurbineModels/NREL_5MW/CpScan/CpScan.mat');
TSRvec = cpscan.TSR;
zind = find(cpscan.BlPitch == 0);
Cpvec = cpscan.Cpmat(:,zind)';
TSR_opt = TSRvec(Cpvec == max(Cpvec));
xlim([-2 15]);
ylim([0 16]);

cps = cpscan.Cpmat;
cps(cps<0)=0;
surface(cpscan.BlPitch,cpscan.TSR,cps), hold on

ax = get(gca);
fig = get(gcf);
ax.FontSize = 20;
fs = 20; 
title('Cp Surface forNREL 5MW', 'FontSize',fs)
xlabel('Blade Pitch, deg', 'FontSize',fs)
ylabel('Tip Speed Ratio', 'FontSize',fs)
colorbar

% Add Max TSR
hold on
plot3(0,TSR_opt,max(Cpvec)+0.1,'rx','MarkerSize',15, 'linewidth',20)

% Add Bld Pitch Operating Points
[Avec,Bbvec,Beta_op,vv,Cp] = Pre_TSRtracking_Plant(ContParam,cpscan);

% Trim for BldPitch Controller
Bopind = find(Beta_op>0);
Avec_BPC = Avec(Bopind(1)-1:end);
Bbvec_BPC = Bbvec(Bopind(1)-1:end);
Betaop_BPC = Beta_op(Bopind(1)-1:end);
vv_bpc = vv(Bopind(1)-1:end);
Cp_op = Cp(Bopind(1)-1:end); % Need to get Cp from Pre_TSRtracking_Plant.m
lam_op = ContParam.RotorRad.*(ContParam.PC_RefSpd./ContParam.GBRatio)./vv_bpc;

Bmaxind = find(Betaop_BPC == max(Betaop_BPC));
Bmaxind = Bmaxind(1);
Betaop_BPC = Betaop_BPC(1:Bmaxind);
lam_op = lam_op(1:Bmaxind);
Cp_op = Cp_op(1:Bmaxind);
plot3(Betaop_BPC.*180/pi,lam_op, Cp_op+0.1,'r','linewidth',3)


%% Sim plots
% obviously, need to run a sim
fo_DRCt = Post_FastOutTrim(fo_DRC,500,500);
fo_DRCt = fo_DRC;
simpl_L = simout;
simpl = Post_FastOutTrim(simout,500,500);
simpl = simout;
% simpl = fo_DRCt; 

% figure
fs = 16
subplot(4,1,1)
plot(simpl.Time, simpl.Wind1VelX, 'linewidth', 1.5)
grid on
ylabel('Wind Speed, v','fontsize',fs)
xlabel('Time, s','fontsize',fs)
ax = get(gca);
ax.FontSize = fs;
ax.XLabel.FontSize = fs;
ax.YLabel.FontSize = fs;
ax.YLabel.Rotation = 0;
ax.YLabel.HorizontalAlignment = 'right';
hold on

subplot(4,1,2)
plot(simpl.Time, simpl.GenTq, 'linewidth', 1.5)
grid on
ylabel('Generator Torque, kNm','fontsize',fs)
xlabel('Time, s','fontsize',fs)
ax = get(gca);
ax.FontSize = fs;
ax.XLabel.FontSize = fs;
ax.YLabel.FontSize = fs;
ax.YLabel.Rotation = 0;
ax.YLabel.HorizontalAlignment = 'right';
hold on

subplot(4,1,3)
plot(simpl.Time, simpl.BldPitch1, 'linewidth', 1.5)
grid on
ylabel('Blade Pitch Angle, deg','fontsize',fs)
xlabel('Time, s','fontsize',fs)
ax = get(gca);
ax.FontSize = fs;
ax.XLabel.FontSize = fs;
ax.YLabel.FontSize = fs;
ax.YLabel.Rotation = 0;
ax.YLabel.HorizontalAlignment = 'right';
hold on

subplot(4,1,4)
plot(simpl.Time, simpl.GenSpeed, 'linewidth', 1.5)
grid on
ylabel('Generator Speed, rpm','fontsize',fs)
xlabel('Time, s','fontsize',fs)
ax = get(gca);
ax.XLabel.FontSize = fs;
ax.YLabel.FontSize = fs;
ax.FontSize = fs;
ax.YLabel.Rotation = 0;
ax.YLabel.HorizontalAlignment = 'right';
hold on


%% legend?
subplot(4,1,1)
leg = legend('Delft Research Controller','New Controller');

leg.FontSize = fs;
leg.Location = 'NorthEast';
% leg.Orientation = 'Horizontal';



%% Transition
figure
myplot(Omega_tg_ref); hold on
myplot(Omega_bg_ref);
myplot(simout.Time, simout.GenSpeed*pi/30);

leg = legend('Torque Ref','BldPitch Ref', 'GenSpeed')
leg.FontSize = fs
ax.XLabel.FontSize = fs;
ax.YLabel.FontSize = fs;
ax.FontSize = fs;

title('Transition Region Behavior', 'FontSize',fs)
xlabel('Time, s', 'FontSize',fs)
ylabel('Generator Speed, rpm', 'FontSize',fs)

xlim([100 300])



