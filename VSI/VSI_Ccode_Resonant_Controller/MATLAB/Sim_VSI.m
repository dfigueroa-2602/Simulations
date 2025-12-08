function fitness = Sim_VSI(Tsim,Ts,VDC,w,A_ref,t_settling,beta_c,Ad,Bd,Ard,Brd,Ha,Kx,Kr,Ku)

% Samples Calculator
N = round(Tsim / Ts);

% Sizes calculator
nx = size(Bd,1); nu = size(Bd,2); nxr = size(Brd,1);

% Time vector
t = (0:N-1).' * Ts;

% Preallocate states and inputs
x_k  = zeros(nx,1);
x_k_1  = zeros(nx,1);
xu_k = zeros(nu,1);
xr_k = zeros(nxr,1);
xr_k_1 = zeros(nxr,1);
u_k = zeros(nu,1);
u_prev  = zeros(nu,1);

% Preallocate fitness functions
e_log  = zeros(N,nu);
du_log = zeros(N,nu);

tau = t_settling / 4;   % 4τ = 20 ms -> τ = 5 ms
env = 1 - exp(-t/tau);    % grows from 0 to 1
v_alpha = A_ref * env .* sin(w*t); v_beta  = A_ref * env .* cos(w*t);

v_ref  = [v_alpha v_beta];

for k = 1:N

    % To take the states with references
    vC = Ha*x_k;

    % Reference at this instant
    v_ref_k = v_ref(k,:).';

     % Error
    e_k = v_ref_k - vC;
    e_log(k,:) = e_k.';
    
    % Resonant states calculator
    xr_k_1 = Ard*xr_k + Brd*e_k;
    
    % Control law
    u_k = -Kr*xr_k - Ku*xu_k - Kx*x_k;

    % Saturation for numerical purposes
    u_k_sat = max(min(u_k, VDC), -VDC);

    % Plant with delayed input
    x_k_1 = Ad*x_k + Bd*xu_k;
    
    % Difference of actuation calculation
    du_k = u_k - u_prev;
    du_log(k,:) = du_k.';
    u_prev = u_k_sat;
    
    % States update
    x_k = x_k_1;
    xr_k = xr_k_1;
    xu_k = u_k_sat;
end

term_e  = sum(e_log.^2, 2);                    % [N x 1]
term_du = sum(du_log.^2, 2);                   % [N x 1]
fitness = (1/N) * sum(term_e + beta_c*term_du);