function fitness = Sim_CSI(Tsim,Ts,VDC,w,A_ref,t_settling,beta_c,Ad,Bd,Ard,Brd,Ha,Kx,Kr,Ku)

% Samples Calculator
N = round(Tsim / Ts);

% Sizes calculator
nx = size(Bd,1); nu = size(Bd,2); nxr = size(Brd,1);

% Time vector
t = (0:N-1).' * Ts;

% Preallocate states and inputs
x_k  = zeros(nx,1);
xu_k = zeros(nu,1);
xr_k = zeros(nxr,1);
u_prev  = zeros(nu,1);

% Preallocate fitness functions
e_log  = zeros(N,nu);
du_log = zeros(N,nu);

% Refernce Generator
t_step = 0.1;
tau = t_settling / 4;
env = 1 - exp(-t/tau);
A_vec = A_ref*ones(N,1);
A_vec(t >= t_step) = A_ref;

i_alpha = A_vec .* env .* sin(w*t);
i_beta  = A_vec .* env .* cos(w*t);
i_ref   = [i_alpha i_beta];

for k = 1:N

    % To take the states with references
    iC = Ha*x_k;

    % Reference at this instant
    i_ref_k = i_ref(k,:).';

     % Error
    e_k = i_ref_k - iC;
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