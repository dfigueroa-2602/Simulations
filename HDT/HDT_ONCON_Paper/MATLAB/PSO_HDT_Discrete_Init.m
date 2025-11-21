Sim_Variables;
model = 'PSO_HDT_Discrete';

search = 0;

LQR_Mode = 1; % 1 if LQR is done normally, 0 if the Kerr gain is added.
xi_Mode = 0; % 1 to search for a xi, 0 to not search.
R_mode = 0; % 1 to search for R weights, 0 to not search.
F_mode = 0; % 1 to inject the ref for improvement, 0 to not do it.

if xi_Mode == 1
    PSO_HDT_Disc_Res_xi;
    nxi = 1;
else
    xi = 0.0;
    PSO_HDT_Disc_Res;
    nxi = 0;
end

beta_c = 2e-7; n_part = 70; iter = 70;
c1 = 2.05; c2 = 2.05;
Qmax = 20; Rmax = 2; xi_Max = 0.2; xivel_max = 0.01; Qmax_vel = 3; Rmax_vel = 0.1; rang_coef = 0.6;
if R_mode == 1
    nQ = 11; nR = 2;
else
    nR = 0; nQ = 11;
end
dim = nQ + nR + nxi; % 10 states + 2 resonant per ref. state * 4 + 4 inputs + 4 inputs = 26/2
[vel_clamp,Kap,swarm,space_range] = Swarm_Init(n_part,R_mode,xi_Mode,nQ,nR,c1,c2,Qmax,Rmax,xi_Max,rang_coef,Qmax_vel,Rmax_vel,xivel_max);
xmax_val = 12; xmin = repmat(-xmax_val,dim,1); xmax = repmat(xmax_val,dim,1);

if search == 1
    swarms = {};
    % Randomize the seed, open a pool of workers where each of them the model
    % is loaded, the fast restart is enabled and parameters are pushed.
    Parallel_Injection;
    % Initialization of important matrices
    b_fitness = zeros(iter,1); fitness = inf(1,n_part);
    gbest_vec = zeros(iter,1);
    % Initialize particles
    for i = 1:iter
        parfor n = 1:n_part
            try
                sw = swarm(n,:,:);
                sw = squeeze(sw(1,1,:));
                if xi_Mode == 1
                    fitness(n) = Sim_PSO_HDT_Discrete_xi(LQR_Mode,F_mode,R_mode,model,sw,Ad_delay,Bd_delay,H,nx,nu,beta_c);
                else
                    fitness(n) = Sim_PSO_HDT_Discrete(LQR_Mode,F_mode,R_mode,model,sw,A_aug_delay,B_aug_delay,nx,nu,nr,beta_c);
                end
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
    
    spmd
        set_param(model,'FastRestart','off');
        close_system(model,0);
    end 
    delete(gcp('nocreate'));

    sw_best = squeeze(swarm(gbest,3,:));
    if xi_Mode == 1
        [Ard,Brd,Kx,Kr,Kxx,Kerr,F] = Final_Update_xi(LQR_Mode,F_mode,xi_Mode,R_mode,sw_best,Ad_delay,Bd_delay,H,nx,nu,nr,w,Ts);
        save('C:\Users\Dave\Documents\git\Simulations\PLECS\HDT\MAT_Resonant','Ar','Br','Ard','Brd','Ad_delay','Bd_delay');
    else
        [Kx,Kr,Kxx,Kerr,F] = Final_Update(LQR_Mode,F_mode,R_mode,sw_best,A_aug_delay,B_aug_delay,nx,nu,nr);
    end
    load_system(model)
    ws = get_param(model,'modelworkspace');
    ws.assignin('Ard',Ard);
    ws.assignin('Brd',Brd);
    ws.assignin('A',A);
    ws.assignin('B',B);
    ws.assignin('C',C);
    ws.assignin('Ts',Ts);
    ws.assignin('Kx', Kx);
    ws.assignin('Kr', Kr);
    ws.assignin('Kxx', Kxx);
    ws.assignin('Kerr', Kerr);
    ws.assignin('F', F);
    ws.assignin('beta_c',beta_c);
    test = sim(model);
    save_system(model,[],'OverwriteIfChangedOnDisk',true);
    
    save('C:\Users\Dave\Documents\git\Simulations\PLECS\HDT\MAT_Res_LQR','Kx','Kr','Kxx','Kerr','F')
    
    %save('Bests\Best7','Kx','Kr','Kxx','Kerr');
    
    sig1 = test.s1;
    sig2 = test.s2;
    error = test.e_mag;
    N  = numel(sig1)/2;
    t  = (0:N-1).' * Ts;
    figure(1)
    subplot(3,1,1)
    plot(t,sig1)
    legend('Vcs','Reference')
    ylabel('Voltage [V]')
    grid on;
    subplot(3,1,2)
    plot(t,sig2)
    legend('Ifp','Reference')
    ylabel('Current [A]') 
    grid on;
    subplot(3,1,3)
    plot(t,error)
    legend('Error Vcs','Error Ifp')
    grid on;
else
    if isempty(swarms)
        warning('Simulate first! There is no data to plot')
        return
    end
    Draw_Plots;
end