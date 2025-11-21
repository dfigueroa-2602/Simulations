clc; clear variables;

% Definition of variables
Vdc = 300;  Rf = 0.035;
Lf = 5e-3;  Cf = 12e-6;
Rg = 0.84;  Lg = 3.3e-3;

N = 2; f = 50; fg = 50;
% Base Voltage
Vb = Vdc*(sqrt(3)/3)/1.15;
wb = 2*pi*f;

max_iter = 30;

% Switching frequency and sampling
fs = 5000;  Ts = 1/fs;

A = [-Rf/Lf wb      0       0       -1/Lf   0       0;
     -wb    -Rf/Lf  0       0       0       -1/Lf   0;
     0      0       -Rg/Lg  wb      1/Lg    0       0;
     0      0       -wb     -Rg/Lg  0       1/Lg    -Vb/Lg;
     1/Cf   0       -1/Cf   0       0       wb      0;
     0      1/Cf    0       -1/Cf   -wb     0       0
     0      0       0       0       0       0       0];

B = [1/Lf     0 ;
      0       0 ;
      0       0 ;
      0       0 ;
      0       0 ;
      0       0 ;
      0      -1];

Bp = [  0     0 ;
        0     0 ;
      -1/Lg   0 ;
        0     0 ;
        0     0 ;
        0     0 ;
        0     1];

C = blkdiag(1,1,1,1,1,1,1);
D = zeros(length(A),size(B,2));

sys = ss(A,B,C,D);

% Discrete System
sysd = c2d(sys,Ts);
[~, Bpd] = c2d(A,Bp,Ts);
[Ad,Bd,Cd,Dd] = ssdata(sysd);

% State weights for real system
Q = eye(length(Ad));

Q(1,1) = 2e2; Q(2,2) = 2e2;
Q(3,3) = 1e4; Q(4,4) = 5e4;
Q(7,7) = 1e5;

% Actuation weights
R = eye(size(Bd,2));
R(1,1) = 5e4; R(2,2) = 200;

[K,Qp,~] = dlqr(Ad,Bd,Q,R);

rho = 0.05;   
alpha = 1.05;

%%
sim_OSQP = sim("Sim_OSQP_PC.slx");

disp(['Average Iterations Value: ', num2str(mean(sim_OSQP.iter.signals.values))])
disp(['Number of Maximum Iterations Occurences: ', num2str(length(find(sim_OSQP.status.signals.values == -2)))])
disp(['Number of Solved Inaccurate Occurences: ', num2str(length(find(sim_OSQP.status.signals.values == 2)))])

%%
clc
A_cl = Ad - Bd*K;
p = eig(A_cl);

figure(1);
plot(real(p),imag(p),'bx','MarkerSize',10,'LineWidth',2);
hold on
xline(0,'k--');
yline(0,'k--');

th = linspace(0,2*pi,400);
plot(cos(th),sin(th),'k--','LineWidth',1.2)
hold off;
xlabel('Real Axis')
ylabel('Imaginary Axis');
grid on;
axis equal

Lf_values = linspace(100e-6, 10e-3, 30);
colors = turbo(length(Lf_values));

figure(2); hold on; grid on;
for k = 1:length(Lf_values)
    Lf = Lf_values(k);
    A_var = [-Rf/Lf wb      0       0       -1/Lf   0       0;
             -wb    -Rf/Lf  0       0       0       -1/Lf   0;
             0      0       -Rg/Lg  wb      1/Lg    0       0;
             0      0       -wb     -Rg/Lg  0       1/Lg    -Vb/Lg;
             1/Cf   0       -1/Cf   0       0       wb      0;
             0      1/Cf    0       -1/Cf   -wb     0       0
             0      0       0       0       0       0       0];

    B_var = [1/Lf     0 ;
             0       0 ;
             0       0 ;
             0       0 ;
             0       0 ;
             0       0 ;
             0      -1];

    sysd_var = c2d(ss(A_var,B_var,C,D),Ts);
    [Ad_var,Bd_var,~,~] = ssdata(sysd_var);

    A_cl_var = Ad_var - Bd_var*K;
    p_var = eig(A_cl_var);

    plot(real(p_var),imag(p_var),'x','Color',colors(k,:),'LineWidth',2);

    if any(abs(p_var) >= 1)
        fprintf('Unstable at Lg = %.3e\n', Lf)
    end
end
xline(0,'k--');
yline(0,'k--');

th = linspace(0,2*pi,400);
plot(cos(th),sin(th),'k--','LineWidth',1.2)

hold off
xlabel('Real Axis')
ylabel('Imaginary Axis');
grid on;
axis equal


Lg_values = linspace(100e-6, 10e-3, 30);
colors = turbo(length(Lg_values));

figure(3); hold on; grid on;
for k = 1:length(Lg_values)
    Lg = Lg_values(k);
    A_var = [-Rf/Lf wb      0       0       -1/Lf   0       0;
             -wb    -Rf/Lf  0       0       0       -1/Lf   0;
             0      0       -Rg/Lg  wb      1/Lg    0       0;
             0      0       -wb     -Rg/Lg  0       1/Lg    -Vb/Lg;
             1/Cf   0       -1/Cf   0       0       wb      0;
             0      1/Cf    0       -1/Cf   -wb     0       0
             0      0       0       0       0       0       0];

    B_var = [1/Lf     0 ;
             0       0 ;
             0       0 ;
             0       0 ;
             0       0 ;
             0       0 ;
             0      -1];

    sysd_var = c2d(ss(A_var,B_var,C,D),Ts);
    [Ad_var,Bd_var,~,~] = ssdata(sysd_var);

    A_cl_var = Ad_var - Bd_var*K;
    p_var = eig(A_cl_var);

    plot(real(p_var),imag(p_var),'x','Color',colors(k,:),'LineWidth',2);

    if any(abs(p_var) >= 1)
        fprintf('Unstable at Lg = %.3e\n', Lg)
    end
end
xline(0,'k--');
yline(0,'k--');

th = linspace(0,2*pi,400);
plot(cos(th),sin(th),'k--','LineWidth',1.2)

hold off
xlabel('Real Axis')
ylabel('Imaginary Axis');
grid on;
axis equal


Rg_values = linspace(10e-3, 1, 30);
colors = turbo(length(Rg_values));

figure(4); hold on; grid on;
for k = 1:length(Rg_values)
    Rg = Rg_values(k);
    A_var = [-Rf/Lf wb      0       0       -1/Lf   0       0;
             -wb    -Rf/Lf  0       0       0       -1/Lf   0;
             0      0       -Rg/Lg  wb      1/Lg    0       0;
             0      0       -wb     -Rg/Lg  0       1/Lg    -Vb/Lg;
             1/Cf   0       -1/Cf   0       0       wb      0;
             0      1/Cf    0       -1/Cf   -wb     0       0
             0      0       0       0       0       0       0];

    B_var = [1/Lf     0 ;
             0       0 ;
             0       0 ;
             0       0 ;
             0       0 ;
             0       0 ;
             0      -1];

    sysd_var = c2d(ss(A_var,B_var,C,D),Ts);
    [Ad_var,Bd_var,~,~] = ssdata(sysd_var);

    A_cl_var = Ad_var - Bd_var*K;
    p_var = eig(A_cl_var);

    plot(real(p_var),imag(p_var),'x','Color',colors(k,:),'LineWidth',2);
end
xline(0,'k--');
yline(0,'k--');

th = linspace(0,2*pi,400);
plot(cos(th),sin(th),'k--','LineWidth',1.2)

hold off
xlabel('Real Axis')
ylabel('Imaginary Axis');
grid on;
axis equal


Cf_values = linspace(1e-6, 150e-6, 30);
colors = turbo(length(Cf_values));

figure(5); hold on; grid on;
for k = 1:length(Cf_values)
    Cf = Cf_values(k);
    A_var = [-Rf/Lf wb      0       0       -1/Lf   0       0;
             -wb    -Rf/Lf  0       0       0       -1/Lf   0;
             0      0       -Rg/Lg  wb      1/Lg    0       0;
             0      0       -wb     -Rg/Lg  0       1/Lg    -Vb/Lg;
             1/Cf   0       -1/Cf   0       0       wb      0;
             0      1/Cf    0       -1/Cf   -wb     0       0
             0      0       0       0       0       0       0];

    B_var = [1/Lf     0 ;
             0       0 ;
             0       0 ;
             0       0 ;
             0       0 ;
             0       0 ;
             0      -1];

    sysd_var = c2d(ss(A_var,B_var,C,D),Ts);
    [Ad_var,Bd_var,~,~] = ssdata(sysd_var);

    A_cl_var = Ad_var - Bd_var*K;
    p_var = eig(A_cl_var);

    plot(real(p_var),imag(p_var),'x','Color',colors(k,:),'LineWidth',2);
end
xline(0,'k--');
yline(0,'k--');

th = linspace(0,2*pi,400);
plot(cos(th),sin(th),'k--','LineWidth',1.2)

hold off
xlabel('Real Axis')
ylabel('Imaginary Axis');
grid on;
axis equal

%%
fe = sim_OSQP.fe.signals.values(:);
ifd = sim_OSQP.ifdq.signals.values(:,1);
ifq = sim_OSQP.ifdq.signals.values(:,2);
iflim = sim_OSQP.ifdq.signals.values(:,3);

igd = sim_OSQP.igdq.signals.values(:,1);
igq = sim_OSQP.igdq.signals.values(:,2);
igdr = sim_OSQP.igdq.signals.values(:,3);

vcd = sim_OSQP.vcdq.signals.values(:,1);
vcq = sim_OSQP.vcdq.signals.values(:,2);

ifa = sim_OSQP.ifabc.signals.values(:,1);
ifb = sim_OSQP.ifabc.signals.values(:,2);
ifc = sim_OSQP.ifabc.signals.values(:,3);

iga = sim_OSQP.igabc.signals.values(:,1);
igb = sim_OSQP.igabc.signals.values(:,2);
igc = sim_OSQP.igabc.signals.values(:,3);

vsa = sim_OSQP.vsabc.signals.values(:,1);
vsb = sim_OSQP.vsabc.signals.values(:,2);
vsc = sim_OSQP.vsabc.signals.values(:,3);

vga = sim_OSQP.vgabc.signals.values(:,1);
vgb = sim_OSQP.vgabc.signals.values(:,2);
vgc = sim_OSQP.vgabc.signals.values(:,3);

vca = sim_OSQP.vcabc.signals.values(:,1);
vcb = sim_OSQP.vcabc.signals.values(:,2);
vcc = sim_OSQP.vcabc.signals.values(:,3);

timeinit = 0.1;
t = (0:length(ifd)-1) * Ts;

err_ifdmeas = sim_OSQP.error.signals.values(:);
ifd_pred = sim_OSQP.ifd_med_pred.signals.values(:,2);
%%
close all
figure(1)
subplot(2,1,1)
plot(t,ifd)
hold on;
plot(t,ifd_pred)
hold off;
grid on;
xlim([timeinit t(end)]);
xlabel('Time [s]')
ylabel('Current [A]')
legend('Measured i_{fd}', 'Predicted i_{fd}','NumColumns',2,'location','southeast');
subplot(2,1,2)
plot(t,err_ifdmeas)
grid on;
xlim([timeinit t(end)]);
xlabel('Time [s]')
ylabel('Error [A]')

annotation("textbox", [0.9237 0.7445 0.0357 0.081], "String", "a)", "EdgeColor", "none")
annotation("textbox", [0.9201 0.2664 0.06011 0.06944], "String", "b)")

hTextboxshape = findall(gcf,"Type","textboxshape")
hTextboxshape(1).EdgeColor = "none"

%% ITERATIONS, CURRENTS AND VOLTAGES IN DQ COORDINATES
timeinit = 0.05;

figure(1)
t = (0:length(ifd)-1) * Ts;
iter = sim_OSQP.iter.signals.values;
plot(t,iter,'LineWidth',0.01,'Color','b')
%title('Solver Iteration Number')
ylabel('Iteraciones [-]');
xlabel('Tiempo [s]')
grid on;
xlim([timeinit t(end)]);
%set(gcf, "Position", [483 383 560 250])
set(gcf, "Position", [0 400 900 200])

figure(2)
status = sim_OSQP.status.signals.values;
for i = 1:length(status)
    if status(i) == -2
        status(i) = 0;
    end
end
plot(t, status, 'LineWidth', 0.01, 'Color', 'b')
ylabel('Estatus del solver');
xlabel('Tiempo [s]')
grid on;
xlim([timeinit t(end)]);
set(gcf, "Position", [0 400 900 200])

% Define the y-tick values and corresponding labels for -2, 1, and 2 with escaped underscores
yticks([0, 1, 2]);
yticklabels({'OSQP\_MAX\_ITER\_REACHED', 'OSQP\_SOLVED', 'OSQP\_SOLVED\_INACCURATE'});
% Adjust y-axis font size for better fit if needed
set(gca, 'FontSize', 8);

solve_time = sim_OSQP.solve_time.signals.values;
figure(3)
plot(t, solve_time, 'LineWidth', 0.01, 'Color', 'b')
ylabel('Tiempo por iteración');
xlabel('Tiempo [s]')
grid on;
xlim([timeinit t(end)]);
set(gcf, "Position", [0 400 900 200])

%%

figure(2)
subplot(3,1,1)
plot(t,ifd,'LineWidth',2,'Color','b')
hold on;
plot(t,ifq,'LineWidth',2,'Color','r')
text(0.74, 2.5, '(a)','VerticalAlignment','top','HorizontalAlignment', 'right', 'FontSize',12 );
hold off;
grid on;
ylabel('i_{f,dq} [A]',"Interpreter","tex",'FontSize',12);
ymin = -12;
ymax = 8;
ylim([ymin+4 ymax+2]);
yticks(ymin:2:ymax+2)
xticklabels([])
xlim([timeinit t(end)]);
xticks(0:0.05:t(end));
legend('i_{fd}','i_{fq}','Location','northeast','NumColumns',3);

ax1_pos = get(gca, "Position");
ax1_pos(4) = 0.27;
set(gca, "Position", ax1_pos)
set(gca, 'FontSize',10)

subplot(3,1,2)
plot(t,igd,'LineWidth',2,'Color','b')
hold on;
plot(t,igq,'LineWidth',2,'Color','r')
plot(t,igdr,'LineWidth',2,'Color',[0 0.4470 0.7410],'LineStyle','--')
line([0 0.5], [0 0],'LineWidth',2,'Color',[0.8500 0.3250 0.0980],'LineStyle','--')
text(0.74, 2, '(b)','VerticalAlignment','top','HorizontalAlignment', 'right', 'FontSize',12 );
hold off;
grid on;
ylabel('i_{g,dq} [A]',"Interpreter","tex",'FontSize',12);
ylim([ymin+4 ymax+2]);
yticks(ymin+4:2:ymax+2)
xticklabels([]);
xlim([timeinit t(end)]);
xticks(0:0.05:t(end));
legend('i_{gd}','i_{gq}','i_{gd,ref}','i_{gq,ref}','Location','northeast','NumColumns',4);

ax2_pos = get(gca, "Position");
ax2_pos(4) = 0.27;
set(gca, "Position", ax2_pos)
set(gca, 'FontSize',10)

subplot(3,1,3)
plot(t,vcd,'LineWidth',2,'Color','b')
hold on;
plot(t,vcq,'LineWidth',2,'Color','r')
text(0.74, 180, '(c)','VerticalAlignment','top','HorizontalAlignment', 'right', 'FontSize',12 );
hold off;
grid on;
ylabel('V_{c,dq} [V]',"Interpreter","tex",'FontSize',12);
yticks(-100:50:300)
ylim([-100 300]);
xlim([timeinit t(end)]);
xlabel('Tiempo [s]')
legend('v_{cd}','v_{cq}','Location','northeast','NumColumns',2);

ax3_pos = get(gca, "Position");
ax3_pos(4) = 0.27;
set(gca, "Position", ax3_pos)
set(gca, 'FontSize',10)
set(gcf, "Position", [0 400 900 500])
%% Transient Plots for dq Measurements
traninit1 = 0.12;
tranend1 = 0.18;

traninit2 = 0.32;
tranend2 = 0.38;

traninit3 = 0.47;
tranend3 = 0.53;

figure(2)

% First Transient
subplot(3,3,1)
plot(t,ifd,'LineWidth',2,'Color','b')
hold on;
plot(t,ifq,'LineWidth',2,'Color','r')
text(0.74, 8, '(a)','VerticalAlignment','top','HorizontalAlignment', 'right', 'FontSize',12 );
hold off;
grid on;
ylabel('i_{f,dq} [A]',"Interpreter","tex",'FontSize',12);
ymin = -10;
ymax = 14;
ylim([ymin ymax]);
yticks(ymin:2:ymax)
xticklabels([])
xticks(0:0.05:t(end));

xlim([traninit1 tranend1])
ylim([ymin+2 ymax]);
xticks(0:0.01:t(end));

ax1_pos = get(gca, "Position");
ax1_pos(1) = 0.06;
ax1_pos(3) = 0.27;
ax1_pos(4) = 0.27;
set(gca, "Position", ax1_pos)

% Second Transient
subplot(3,3,2)
plot(t,ifd,'LineWidth',2,'Color','b')
hold on;
plot(t,ifq,'LineWidth',2,'Color','r')
hold off;
grid on;
yticklabels([])
ymin = -10;
ymax = 14;
ylim([ymin ymax]);
yticks(ymin:2:ymax)
xticklabels([])
xticks(0:0.05:t(end));

xlim([traninit2 tranend2])
ylim([ymin+2 ymax]);
xticks(0:0.01:t(end));

ax1_pos = get(gca, "Position");
ax1_pos(1) = 0.36;
ax1_pos(3) = 0.27;
ax1_pos(4) = 0.27;
set(gca, "Position", ax1_pos)

% Third Transient
subplot(3,3,3)
plot(t,ifd,'LineWidth',2,'Color','b')
hold on;
plot(t,ifq,'LineWidth',2,'Color','r')
text(0.54, 4, '(a)','VerticalAlignment','top','HorizontalAlignment', 'right', 'FontSize',12 );
hold off;
grid on;
yticklabels([])
ymin = -10;
ymax = 14;
yticks(ymin:2:ymax)
xticklabels([])
xticks(0:0.05:t(end));

xlim([traninit3 tranend3])
ylim([ymin+2 ymax]);
xticks(0:0.01:t(end));

ax1_pos = get(gca, "Position");
ax1_pos(1) = 0.66;
ax1_pos(3) = 0.27;
ax1_pos(4) = 0.27;
set(gca, "Position", ax1_pos)
legend('i_{fd}','i_{fq}','Location','northeast','NumColumns',3);

% Grid Currents
subplot(3,3,4)
plot(t,igd,'LineWidth',2,'Color','b')
hold on;
plot(t,igq,'LineWidth',2,'Color','r')
plot(t,igdr,'LineWidth',2,'Color',[0 0.4470 0.7410],'LineStyle','--')
line([0 0.5], [0 0],'LineWidth',2,'Color',[0.8500 0.3250 0.0980],'LineStyle','--')
hold off;
grid on;
ylabel('i_{g,dq} [A]',"Interpreter","tex",'FontSize',12);
ymin = -10;
ymax = 14;
yticks(ymin:2:ymax)
xticklabels([])
xticks(0:0.05:t(end));

xlim([traninit1 tranend1])
ylim([ymin+2 ymax]);
xticks(0:0.01:t(end));

ax1_pos = get(gca, "Position");
ax1_pos(1) = 0.06;
ax1_pos(3) = 0.27;
ax1_pos(4) = 0.27;
set(gca, "Position", ax1_pos)

subplot(3,3,5)
plot(t,igd,'LineWidth',2,'Color','b')
hold on;
plot(t,igq,'LineWidth',2,'Color','r')
plot(t,igdr,'LineWidth',2,'Color',[0 0.4470 0.7410],'LineStyle','--')
line([0 0.5], [0 0],'LineWidth',2,'Color',[0.8500 0.3250 0.0980],'LineStyle','--')
hold off;
grid on;
ymin = -10;
ymax = 14;
yticklabels([])
yticks(ymin:2:ymax)
xticklabels([])
xticks(0:0.05:t(end));

xlim([traninit2 tranend2])
ylim([ymin+2 ymax]);
xticks(0:0.01:t(end));

ax1_pos = get(gca, "Position");
ax1_pos(1) = 0.36;
ax1_pos(3) = 0.27;
ax1_pos(4) = 0.27;
set(gca, "Position", ax1_pos)

subplot(3,3,6)
plot(t,igd,'LineWidth',2,'Color','b')
hold on;
plot(t,igq,'LineWidth',2,'Color','r')
plot(t,igdr,'LineWidth',2,'Color',[0 0.4470 0.7410],'LineStyle','--')
line([0 0.5], [0 0],'LineWidth',2,'Color',[0.8500 0.3250 0.0980],'LineStyle','--')
text(0.54, 4, '(b)','VerticalAlignment','top','HorizontalAlignment', 'right', 'FontSize',12 );
hold off;
grid on;
ymin = -10;
ymax = 14;
yticklabels([])
yticks(ymin:2:ymax)
xticklabels([])
xticks(0:0.05:t(end));

xlim([traninit3 tranend3])
ylim([ymin+2 ymax]);
xticks(0:0.01:t(end));

ax1_pos = get(gca, "Position");
ax1_pos(1) = 0.66;
ax1_pos(3) = 0.27;
ax1_pos(4) = 0.27;
set(gca, "Position", ax1_pos)
legend('i_{gd}','i_{gq}','i_{gd,ref}','i_{gq,ref}','Location','northeast','NumColumns',2);

subplot(3,3,7)
plot(t,vcd,'LineWidth',2,'Color','b')
hold on;
plot(t,vcq,'LineWidth',2,'Color','r')
hold off;
grid on;
ylabel('V_{c,dq} [V]',"Interpreter","tex",'FontSize',12);
yticks(-50:50:300)
ylim([-50 300]);
xlim([traninit1 tranend1])
xticks(0:0.01:t(end));

ax1_pos = get(gca, "Position");
ax1_pos(1) = 0.06;
ax1_pos(3) = 0.27;
ax1_pos(4) = 0.27;
set(gca, "Position", ax1_pos)

subplot(3,3,8)
plot(t,vcd,'LineWidth',2,'Color','b')
hold on;
plot(t,vcq,'LineWidth',2,'Color','r')
hold off;
grid on;
yticks(-50:50:300)
yticklabels([])
ylim([-50 300]);
xlim([traninit2 tranend2])
xticks(0:0.01:tranend3);
xlabel('Tiempo [s]')

ax1_pos = get(gca, "Position");
ax1_pos(1) = 0.36;
ax1_pos(3) = 0.27;
ax1_pos(4) = 0.27;
set(gca, "Position", ax1_pos)

subplot(3,3,9)
plot(t,vcd,'LineWidth',2,'Color','b')
hold on;
plot(t,vcq,'LineWidth',2,'Color','r')
text(0.54, 170, '(c)','VerticalAlignment','top','HorizontalAlignment', 'right', 'FontSize',12 );
hold off;
grid on;
yticks(-50:50:300)
yticklabels([])
ylim([-50 300]);
xlim([traninit3 tranend3])
xticks(traninit3:0.01:tranend3);
legend('v_{cd}','v_{cq}','Location','northeast','NumColumns',2);

ax1_pos = get(gca, "Position");
ax1_pos(1) = 0.66;
ax1_pos(3) = 0.27;
ax1_pos(4) = 0.27;
set(gca, "Position", ax1_pos)

set(gcf, "Position", [0 400 900 500])
%% CURRENTS AND VOLTAGES IN ABC COORDINATES

figure(3)
subplot(3,1,1)
plot(t, ifa,'LineWidth',2,'Color','b')
hold on;
plot(t, ifb,'LineWidth',2,'Color','r')
plot(t, ifc,'LineWidth',2,'Color','g')
plot(t,iflim,'LineWidth',2,'Color','black','LineStyle','--')
text(0.74, 2, '(a)','VerticalAlignment','top','HorizontalAlignment', 'right', 'FontSize',12 );
hold off;
grid on;
ylabel('i_{f,abc} [A]',"Interpreter","tex",'FontSize',12);
xticklabels([]);
xticks(0:0.05:t(end));
ylim([-8 12]);
yticks(-8:2:12)
xlim([timeinit t(end)]);
legend('i_{fa}','i_{fb}','i_{fc}', 'Límite de Corriente','Location','northeast','NumColumns',4);

ax4_pos = get(gca, "Position");
ax4_pos(4) = 0.27;
set(gca, "Position", ax4_pos)
set(gca, 'FontSize',10)
set(gca, 'FontSize',10)

subplot(3,1,2)
plot(t, iga,'LineWidth',2,'Color','b')
hold on;
plot(t, igb,'LineWidth',2,'Color','r')
plot(t, igc,'LineWidth',2,'Color','g')
text(0.74, 3, '(b)','VerticalAlignment','top','HorizontalAlignment', 'right', 'FontSize',12 );
hold off;
grid on;
xticklabels([]);
ylim([-8 12]);
yticks(-8:2:12);
xticks(0:0.05:t(end));
xlim([timeinit t(end)]);
ylabel('i_{g,abc} [A]',"Interpreter","tex",'FontSize',12);
legend('i_{ga}','i_{gb}','i_{gc}','Location','northeast','NumColumns',3);

ax5_pos = get(gca, "Position");
ax5_pos(4) = 0.27;
set(gca, "Position", ax5_pos)
set(gca, 'FontSize',10)

subplot(3,1,3)
plot(t, vca,'LineWidth',2,'Color','b')
hold on;
plot(t, vcb,'LineWidth',2,'Color','r')
plot(t, vcc,'LineWidth',2,'Color','g')
text(0.74, 100, '(c)','VerticalAlignment','top','HorizontalAlignment', 'right', 'FontSize',12 );
hold off;
grid on;
ylim([-200 300]);
yticks(-200:50:300);
xlim([timeinit t(end)]);
ylabel('v_{c,abc} [V]',"Interpreter","tex",'FontSize',12);
xlabel('Tiempo [s]')
legend('v_{ca}','v_{cb}','v_{cc}','Location','northeast','NumColumns',3);

ax6_pos = get(gca, "Position");
ax6_pos(4) = 0.27;
set(gca, "Position", ax6_pos)
set(gca, 'FontSize',10)
%set(gcf, "Position", [483 383 560 600])
set(gcf, "Position", [0 400 900 500])

%% Transient Plots for abc Measurements
figure(3)

% First Transient
subplot(3,3,1)
plot(t, ifa,'LineWidth',2,'Color','b')
hold on;
plot(t, ifb,'LineWidth',2,'Color','r')
plot(t, ifc,'LineWidth',2,'Color','g')
plot(t,iflim,'LineWidth',2,'Color','black','LineStyle','--')
hold off;
grid on;
ylabel('i_{f,abc} [A]',"Interpreter","tex",'FontSize',12);
ymin = -10;
ymax = 10;
ylim([ymin ymax]);
yticks(ymin:2:ymax)
xticklabels([])
xticks(0:0.05:t(end));

xlim([traninit1 tranend1])
ylim([ymin+2 ymax]);
xticks(0:0.01:t(end));

ax1_pos = get(gca, "Position");
ax1_pos(1) = 0.06;
ax1_pos(3) = 0.27;
ax1_pos(4) = 0.27;
set(gca, "Position", ax1_pos)

% Second Transient
subplot(3,3,2)
plot(t, ifa,'LineWidth',2,'Color','b')
hold on;
plot(t, ifb,'LineWidth',2,'Color','r')
plot(t, ifc,'LineWidth',2,'Color','g')
plot(t,iflim,'LineWidth',2,'Color','black','LineStyle','--')
hold off;
grid on;
yticklabels([])
ymin = -10;
ymax = 10;
ylim([ymin ymax]);
yticks(ymin:2:ymax)
xticklabels([])
xticks(0:0.05:t(end));

xlim([traninit2 tranend2])
ylim([ymin+2 ymax]);
xticks(0:0.01:t(end));

ax1_pos = get(gca, "Position");
ax1_pos(1) = 0.36;
ax1_pos(3) = 0.27;
ax1_pos(4) = 0.27;
set(gca, "Position", ax1_pos)

% Third Transient
subplot(3,3,3)
plot(t, ifa,'LineWidth',2,'Color','b')
hold on;
plot(t, ifb,'LineWidth',2,'Color','r')
plot(t, ifc,'LineWidth',2,'Color','g')
plot(t,iflim,'LineWidth',2,'Color','black','LineStyle','--')
text(0.54, 2.5, '(a)','VerticalAlignment','top','HorizontalAlignment', 'right', 'FontSize',12 );
hold off;
grid on;
yticklabels([])
ymin = -10;
ymax = 10;
yticks(ymin:2:ymax)
xticklabels([])
xticks(0:0.05:t(end));

xlim([traninit3 tranend3])
ylim([ymin+2 ymax]);
xticks(0:0.01:t(end));

ax1_pos = get(gca, "Position");
ax1_pos(1) = 0.66;
ax1_pos(3) = 0.27;
ax1_pos(4) = 0.27;
set(gca, "Position", ax1_pos)
legend('i_{fa}','i_{fb}','i_{fc}', 'Límite de Corriente','Location','northeast','NumColumns',4);

% Grid Currents
subplot(3,3,4)
plot(t, iga,'LineWidth',2,'Color','b')
hold on;
plot(t, igb,'LineWidth',2,'Color','r')
plot(t, igc,'LineWidth',2,'Color','g')
hold off;
grid on;
ylabel('i_{g,abc} [A]',"Interpreter","tex",'FontSize',12);
ymin = -10;
ymax = 10;
yticks(ymin:2:ymax)
xticklabels([])
xticks(0:0.05:t(end));

xlim([traninit1 tranend1])
ylim([ymin+2 ymax]);
xticks(0:0.01:t(end));

ax1_pos = get(gca, "Position");
ax1_pos(1) = 0.06;
ax1_pos(3) = 0.27;
ax1_pos(4) = 0.27;
set(gca, "Position", ax1_pos)

subplot(3,3,5)
plot(t, iga,'LineWidth',2,'Color','b')
hold on;
plot(t, igb,'LineWidth',2,'Color','r')
plot(t, igc,'LineWidth',2,'Color','g')
hold off;
grid on;
ymin = -10;
ymax = 10;
yticks(ymin:2:ymax)
yticklabels([])
xticks(0:0.05:t(end));

xlim([traninit2 tranend2])
ylim([ymin+2 ymax]);
xticks(0:0.01:t(end));
xticklabels([])

ax1_pos = get(gca, "Position");
ax1_pos(1) = 0.36;
ax1_pos(3) = 0.27;
ax1_pos(4) = 0.27;
set(gca, "Position", ax1_pos)

subplot(3,3,6)
plot(t, iga,'LineWidth',2,'Color','b')
hold on;
plot(t, igb,'LineWidth',2,'Color','r')
plot(t, igc,'LineWidth',2,'Color','g')
text(0.54, 2.5, '(b)','VerticalAlignment','top','HorizontalAlignment', 'right', 'FontSize',12 );
hold off;
grid on;
ymin = -10;
ymax = 10;
yticks(ymin:2:ymax)
yticklabels([])
xticklabels([])
xticks(0:0.05:t(end));

xlim([traninit3 tranend3])
ylim([ymin+2 ymax]);
xticks(0:0.01:t(end));

ax1_pos = get(gca, "Position");
ax1_pos(1) = 0.66;
ax1_pos(3) = 0.27;
ax1_pos(4) = 0.27;
set(gca, "Position", ax1_pos)
legend('i_{ga}','i_{gb}','i_{gc}','Location','northeast','NumColumns',3);

subplot(3,3,7)
plot(t, vca,'LineWidth',2,'Color','b')
hold on;
plot(t, vcb,'LineWidth',2,'Color','r')
plot(t, vcc,'LineWidth',2,'Color','g')
hold off;
grid on;
ylabel('V_{c,abc} [V]',"Interpreter","tex",'FontSize',12);
yticks(-250:50:300)
ylim([-250 300]);
xlim([traninit1 tranend1])
xticks(0:0.01:t(end));

ax1_pos = get(gca, "Position");
ax1_pos(1) = 0.06;
ax1_pos(3) = 0.27;
ax1_pos(4) = 0.27;
set(gca, "Position", ax1_pos)

subplot(3,3,8)
plot(t, vca,'LineWidth',2,'Color','b')
hold on;
plot(t, vcb,'LineWidth',2,'Color','r')
plot(t, vcc,'LineWidth',2,'Color','g')
hold off;
grid on;
yticks(-250:50:300)
yticklabels([])
ylim([-250 300]);
xlim([traninit2 tranend2])
xticks(0:0.01:tranend3);
xlabel('Tiempo [s]')

ax1_pos = get(gca, "Position");
ax1_pos(1) = 0.36;
ax1_pos(3) = 0.27;
ax1_pos(4) = 0.27;
set(gca, "Position", ax1_pos)

subplot(3,3,9)
plot(t, vca,'LineWidth',2,'Color','b')
hold on;
plot(t, vcb,'LineWidth',2,'Color','r')
plot(t, vcc,'LineWidth',2,'Color','g')
text(0.54, 50, '(c)','VerticalAlignment','top','HorizontalAlignment', 'right', 'FontSize',12 );
hold off;
grid on;
yticks(-250:50:300)
yticklabels([])
ylim([-250 300]);
xlim([traninit3 tranend3])
xticks(traninit3:0.01:tranend3);
legend('v_{ca}','v_{cb}','v_{cc}','Location','northeast','NumColumns',3);

ax1_pos = get(gca, "Position");
ax1_pos(1) = 0.66;
ax1_pos(3) = 0.27;
ax1_pos(4) = 0.27;
set(gca, "Position", ax1_pos)

set(gcf, "Position", [0 400 900 500])

%% INVERTER VOLTAGE IN ABC COORDINATES
figure(4)
subplot(2,1,1)
plot(t, vsa,'LineWidth',2,'Color','b')
hold on;
plot(t, vsb,'LineWidth',2,'Color','r')
plot(t, vsc,'LineWidth',2,'Color','g')
text(0.74, 70, '(a)','VerticalAlignment','top','HorizontalAlignment', 'right', 'FontSize',12 );
hold off;
grid on;
ylabel('V_{s,abc} [V]',"Interpreter","tex",'FontSize',12);
ylim([-200 250]);
yticks(-200:50:250)
xlim([timeinit t(end)]);
legend('v_{sa}','v_{sb}','v_{sc}','Location','northeast','NumColumns',3);
ax6_pos = get(gca, "Position");
ax6_pos(4) = 0.4;
set(gca, "Position", ax6_pos)
set(gca, 'FontSize',10)


subplot(2,1,2)
plot(t, fe,'LineWidth',2,'Color','b')
hold on
text(0.74, 49.5, '(b)','VerticalAlignment','top','HorizontalAlignment', 'right', 'FontSize',12 );
hold off
grid on;
ylabel('f_s [Hz]',"Interpreter","tex",'FontSize',12);
ylim([46 52]);
yticks(46:1:52)
xlim([timeinit t(end)]);
xlabel('Tiempo [s]')
ax7_pos = get(gca, "Position");
ax7_pos(4) = 0.4;
set(gca, "Position", ax7_pos)
set(gca, 'FontSize',10)
%set(gcf, "Position", [483 383 560 350])
set(gcf, "Position", [0 400 900 380])

%% Transient Plots for abc Measurements
figure(3)

% First Transient
subplot(2,3,1)
plot(t, vsa,'LineWidth',2,'Color','b')
hold on;
plot(t, vsb,'LineWidth',2,'Color','r')
plot(t, vsc,'LineWidth',2,'Color','g')
hold off;
grid on;
ylabel('v_{s,abc} [V]',"Interpreter","tex",'FontSize',12);
ymin = -200;
ymax = 250;
ylim([ymin ymax]);
yticks(ymin:50:ymax)
xticklabels([])
xticks(0:0.05:t(end));

xlim([traninit1 tranend1])
ylim([ymin+2 ymax]);
xticks(0:0.01:t(end));

ax6_pos = get(gca, "Position");
ax6_pos(4) = 0.4;
set(gca, "Position", ax6_pos)
set(gca, 'FontSize',10)



% Second Transient
subplot(2,3,2)
plot(t, vsa,'LineWidth',2,'Color','b')
hold on;
plot(t, vsb,'LineWidth',2,'Color','r')
plot(t, vsc,'LineWidth',2,'Color','g')
hold off;
grid on;
yticklabels([])
ymin = -200;
ymax = 250;
ylim([ymin ymax]);
yticks(ymin:50:ymax)
xticklabels([])
xticks(0:0.05:t(end));

xlim([traninit2 tranend2])
ylim([ymin+2 ymax]);
xticks(0:0.01:t(end));

ax6_pos = get(gca, "Position");
ax6_pos(4) = 0.4;
set(gca, "Position", ax6_pos)
set(gca, 'FontSize',10)



% Third Transient
subplot(2,3,3)
plot(t, vsa,'LineWidth',2,'Color','b')
hold on;
plot(t, vsb,'LineWidth',2,'Color','r')
plot(t, vsc,'LineWidth',2,'Color','g')
text(0.54, 50, '(a)','VerticalAlignment','top','HorizontalAlignment', 'right', 'FontSize',12 );
hold off;
grid on;
yticklabels([])
ymin = -200;
ymax = 250;
yticks(ymin:50:ymax)
xticklabels([])
xticks(0:0.05:t(end));

xlim([traninit3 tranend3])
ylim([ymin+2 ymax]);
xticks(0:0.01:t(end));

ax6_pos = get(gca, "Position");
ax6_pos(4) = 0.4;
set(gca, "Position", ax6_pos)
set(gca, 'FontSize',10)

legend('v_{sa}','v_{sb}','v_{sc}','Location','northeast','NumColumns',4);

% Grid Currents
subplot(2,3,4)
plot(t, fe,'LineWidth',2,'Color','b')
grid on;
ylabel('f_s [Hz]',"Interpreter","tex",'FontSize',12);
ymin = 42;
ymax = 53;
yticks(ymin:1:ymax)
xticks(0:0.05:t(end));

xlim([traninit1 tranend1])
ylim([ymin+2 ymax]);
xticks(0:0.01:t(end));

ax7_pos = get(gca, "Position");
ax7_pos(4) = 0.4;
set(gca, "Position", ax7_pos)
set(gca, 'FontSize',10)

subplot(2,3,5)
plot(t, fe,'LineWidth',2,'Color','b')
grid on;
ymin = 42;
ymax = 53;
yticklabels([])
xticks(0:0.05:t(end));

xlim([traninit2 tranend2])
ylim([ymin+2 ymax]);
yticks(ymin:1:ymax)
xticks(0:0.01:tranend2);

ax7_pos = get(gca, "Position");
ax7_pos(4) = 0.4;
set(gca, "Position", ax7_pos)
set(gca, 'FontSize',10)

subplot(2,3,6)
plot(t, fe,'LineWidth',2,'Color','b')
text(0.54, 48.5, '(b)','VerticalAlignment','top','HorizontalAlignment', 'right', 'FontSize',12 );
hold off;
grid on;
ymin = 42;
ymax = 53;
yticklabels([])
yticks(ymin:1:ymax)
xticks(0:0.05:tranend3);

xlim([traninit3 tranend3])
ylim([ymin+2 ymax]);
xticks(0:0.01:t(end));

ax7_pos = get(gca, "Position");
ax7_pos(4) = 0.4;
set(gca, "Position", ax7_pos)
set(gca, 'FontSize',10)
set(gcf, "Position", [0 400 900 500])
%%
figure(5)
plot(t,(vca - vga),'LineWidth',2,'Color',[0 0.4470 0.7410])
hold on;
plot(t,(vcb - vgb),'LineWidth',2,'Color',[0.8500 0.3250 0.0980])
plot(t,(vcc - vgc),'LineWidth',2,'Color',[0.4660 0.6740 0.1880])
hold off;
grid on;
ylabel('Diferencia de Voltaje [V]',"Interpreter","tex",'FontSize',12);
ylim([-10 12]);
yticks(-10:2:12)
xlim([timeinit t(end)]);
xlabel('Tiempo [s]')
legend('\Delta V_{a}','\Delta V_{b}','\Delta V_{c}','Location','northeast','NumColumns',3);
set(gca, 'FontSize',10)
%set(gcf, "Position", [483 383 560 250])
set(gcf, "Position", [0 400 900 200])