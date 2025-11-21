function fitness = Sim_PSO_HDT_Discrete(LQR_Mode,F_mode,R_mode,mdl,sw,A_aug,B_aug,nx,nu,nr,beta_c)

    Ts = 1/20000;

    Qx = repelem(sw(1:nx/2),2);
    Qd = repelem(sw(nx/2 + 1:nx/2 + nu/2),2);
    Qr = repelem(sw(nx/2 + nu/2 + 1:nx/2 + nu/2 + nr/2),2);
    Q = diag([(10.^Qx)' (10.^Qd)' (10.^Qr)']);
    if R_mode == 1
        Ru = repelem(sw(nx/2 + nu/2 + nr/2 + 1:end),2);
        R = diag((10.^Ru)');
    else
        R = blkdiag(1,1,1,1);
    end

    if any(R(:) < 0,1) || any(Q(:) < 0,1)
        disp('One of the elements of the Q and R matrixes is negative!')
        fitness = 1e6; return;
    end
    
    try
        [K,~,~] = dlqr(A_aug, B_aug, Q, R);
    catch
        disp('Error in the LQR')
        fitness = 1e6; return;
    end
    Kr = K(:,(nx + nu + 1):end);
    if LQR_Mode == 1
        Kx = K(:,1:(nx + nu));
        Kxx = zeros(nu,nx);
        Kerr = zeros(nu,nu);
    else
        Kx = zeros(nu,(nx + nu));
        Kxx = K(:,[1:2,7:14]);
        Kerr = K(:,3:6);
    end
    
    if F_mode == 1
        C_delay = [eye(nx) zeros(nx,nu)];
        H = C_delay([3 4 5 6], :);
        Cff = [H , zeros(size(H,1), size(Kr,2))];
    
        Iaug = eye(size(K,2));
        M = Cff * ((Iaug - A_aug + B_aug*K) \ B_aug);
        F = pinv(M);
    else
        F = zeros(nu,nu);
    end

    ws = get_param(mdl,'modelworkspace');
    ws.assignin('Kx', Kx);
    ws.assignin('Kr', Kr);
    ws.assignin('Kxx', Kxx);
    ws.assignin('Kerr', Kerr);
    ws.assignin('F', F);

    Acl = A_aug - B_aug*K;
    spec = max(abs(eig(Acl)));
    if spec >= 1
        fitness = 1e6;
        disp('One of the particles is too close of the instable area!')
        return;
    end

    try
        simOut = sim(mdl);
    catch ME
        fprintf('\nSimulation failed: %s\n', ME.message)
        disp(getReport(ME, 'extended'))
        fitness = 1e6;
        return;
    end
    e = simOut.get('error_v');
    du = simOut.get('du_v');
    v     = simOut.get('v_mag');    i = simOut.get('i_mag');
    vref  = simOut.get('vref_mag'); iref = simOut.get('iref_mag');
    du_v  = simOut.get('du_v');

    N = size(e,1); t  = (0:N-1).' * Ts;
    
    % J_control = (1/N) * Σ ( e^T e + β Δu^T Δu )
    term_e   = sum(e.^2, 2);          % [N x 1]
    term_du  = sum(du.^2, 2);         % [N x 1]
    fitness  = (1/N) * sum( term_e + beta_c * term_du);
end