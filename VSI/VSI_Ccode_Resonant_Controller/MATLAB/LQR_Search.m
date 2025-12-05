function fitness = LQR_Search(Ts,F_mode,R_mode,mdl,sw,A_aug,B_aug,nx,nu,nr,beta_c)
    Qx = repelem(sw(1:nx/2),2);
    Qu = repelem(sw(nx/2 + 1:nx/2 + nu/2),2);
    if isscalar(sw(nx/2 + 1:nx/2 + nu/2))
        Qu = Qu';
    end
    Qr = repelem(sw(nx/2 + nu/2 + 1:nx/2 + nu/2 + nr/2),2);
    Q = diag([(10.^Qx)' (10.^Qu)' (10.^Qr)']);
    if R_mode == 1
        Ru = repelem(sw(nx/2 + nu/2 + nr/2 + 1:end),2);
        R = diag((10.^Ru)');
    else
        R = blkdiag(1,1);
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
    Kx = K(:,1:nx);
    Ku = K(:,(nx + 1):(nx + nu));

    
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
    ws.assignin('Ku', Ku);

    Acl = A_aug - B_aug*K;
    spec = max(abs(eig(Acl)));
    if spec >= 0.999
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
    du = squeeze(du).';
    e = squeeze(e).';

    N = size(e,1); t  = (0:N-1).' * Ts;
    
    % J_control = (1/N) * Σ ( e^T e + β Δu^T Δu )
    term_e   = sum(e.^2, 2);          % [N x 1]
    term_du  = sum(du.^2, 2);         % [N x 1]
    fitness  = (1/N) * sum( term_e + beta_c * term_du);
end