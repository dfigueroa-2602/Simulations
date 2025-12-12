clc;
Lf = 3e-3; Cf = 12e-6; Rf = 35e-3; RL = 47;
fsw = 5e3; Ts = 1/(2*fsw);

VDC = 540; f = 50; w = 2*pi*f;

A = [-Rf/Lf  0     -1/Lf   0    ;
      0     -Rf/Lf  0     -1/Lf ;
      1/Cf   0      0      0    ;
      0      1/Cf   0      0   ];

B = [1/Lf   0    ;
      0     1/Lf ;
      0     0    ;
      0     0   ];

P = [ 0     0    ;
      0     0    ;
     -1/Cf  0    ;
      0    -1/Cf];

nx = size(B,1); nu = size(B,2);
C = eye(nx); D = zeros(nx,nu);

ss_VSI = ss(A,B,C,D); [Ad,Bd,~,~] = ssdata(c2d(ss_VSI,Ts,'zoh'));

Ad_delay = [Ad Bd; zeros(nu,nx) zeros(nu)]; Bd_delay = [zeros(nx,nu); eye(nu)];

Ar1 = [0 w; -w 0];
Br1 = [1; 0];

ss_res1 = ss(Ar1,Br1,eye(2),[]); [Ard1,Brd1,~,~] = ssdata(c2d(ss_res1,Ts,'tustin'));

Ard = blkdiag(Ard1,Ard1);
Brd = blkdiag(Brd1,Brd1);

nxr = size(Brd,1); nur = size(Brd,2);

Ha = [1 0 0 0 ;
      0 1 0 0];

C_delay = [C zeros(nx,nu)];

Hx = C_delay([1 2],:);

Ad_aug = [Ad_delay zeros((nx+nu),nxr); -Brd*Hx Ard];
Bd_aug = [Bd_delay; zeros(nxr,nu)];

Tsim = 0.3; A_ref = 1; T_settling = 40e-3;

search = 0;

beta_c = 3e-5; n_part = 200; iter = 100;
c1 = 2.05; c2 = 2.05;
Qmax = 4; Rmax = 2; xi_Max = 0.2; xivel_max = 0.01; Qmax_vel = 1; Rmax_vel = 0.1; rang_coef = 0.6;

nQ = size(Bd_aug,1)/2; nR = size(Bd_aug,2); dim = nQ;

[vel_clamp,Kap,swarm,space_range] = Swarm_Init(n_part,0,0,nQ,nR,c1,c2,Qmax,Rmax,xi_Max,rang_coef,Qmax_vel,Rmax_vel,xivel_max);
xmax_val = 10; xmin = repmat(-xmax_val,dim,1); xmax = repmat(xmax_val,dim,1);

% aux = swarm(10,:,:);
% LQR_Search(Ts,0,0,model,squeeze(aux(1,1,:)),Ad_aug,Bd_aug,nx,nu,nxr,beta_c)

rng(1,'twister');
if search == 1
    swarms = {};
    % Randomize the seed, then open a pool of workers
    rng('shuffle'); if isempty(gcp('nocreate')), parpool; end

    % Initialization of important matrices
    b_fitness = zeros(iter,1); fitness = inf(1,n_part);
    gbest_vec = zeros(iter,1);
    % Initialize particles
    for i = 1:iter
        parfor n = 1:n_part
            try
                sw = swarm(n,:,:);
                sw = squeeze(sw(1,1,:));
                fitness(n) = LQR_Search(Ts,0,sw,Ad_aug,Bd_aug, ...
                    Ad,Bd,Ard,Brd,Ha,beta_c,VDC,w,A_ref,Tsim,T_settling);
            catch
                fitness(n) = 1e6;
                disp(['Evaluation for particle no. ' num2str(n) ' was aborted']);
            end
        end
        for n = 1:n_part
            if fitness(n) < swarm(n,4,1)
                swarm(n,3,:) = swarm(n,1,:);
                swarm(n,4,1) = fitness(n);
            end
        end
        PSO_Algorithm;
    end

    [Kx, Kr, Ku] = Final_Value(b_swarm,Ad_aug,Bd_aug,nx,nu,nxr,0);

    delete(gcp('nocreate'));
end

Kgain2Ccode({[Kx Ku Kr] Ard, Brd}, ...
            {'K_LQR_Values','Ard_Values','Brd_Values'}, ...
            'Matrices')