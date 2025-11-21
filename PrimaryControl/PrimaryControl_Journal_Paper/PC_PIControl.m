clc; clear variables; %Test

% Definition of variables
Vdc = 300;  Rf = 0.035;
Lf = 5e-3;  Cf = 12e-6;
Rg = 0.84;  Lg = 3.3e-3;
N = 2; f = 50; fg = 50;
Vb = Vdc*(sqrt(3)/3)/1.15;
wb = 2*pi*f;
fs = 5000;  Ts = 1/fs;

wc = 2*pi*10;
kP = ((2*pi*50.5) - (2*pi*49.5))/(2*10e3);
kQ = (1.05*Vb - 0.95*Vb)/(10e3);

fci = 200;      wci = 2*pi*fci;      % inner i_f
fcv = fci/10;   wcv = 2*pi*fcv;      % outer v_c  (≈ 1/10)

% Kp_if = Lf * wci*1000;
% Ki_if = Rf * wci;
Ki = 0.01;
Kp_if = (sqrt(2)*sqrt(sqrt(5) - 2))*Ki*wci;
Ki_if = (sqrt(5) - 2)*Ki*wci^2;
Kv = 0.00075;
Kp_vc = (sqrt(2)*sqrt(sqrt(5) - 2))*Kv*wcv;
Ki_vc = (sqrt(5) - 2)*Kv*wcv^2;

% Límites y anti-windup (tensión de mando vs y saturación admisible):
Vs_max = 0.95*(sqrt(3)/3)*Vdc;   Vs_min = -Vs_max;

PI_params = struct( ...
    'Kp_if',Kp_if, ...
    'Ki_if',Ki_if, ...
    'Kp_vc',Kp_vc, ...
    'Ki_vc',Ki_vc, ...
    'Vs_min',Vs_min,'Vs_max',Vs_max, ...
    'kP',kP,'kQ', kQ);

disp('PI cascada diseñado:'); disp(PI_params);