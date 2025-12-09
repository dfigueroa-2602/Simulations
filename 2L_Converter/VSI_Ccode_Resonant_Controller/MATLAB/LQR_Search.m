function fitness = LQR_Search(Ts,R_mode,sw,A_aug,B_aug,Ad,Bd,Ard,Brd,Ha,beta_c,VDC,w,A_ref,Tsim,T_settling)
    nx = size(Bd,1); nu = size(Bd,2); nxr = size(Brd,1);
    Qx = repelem(sw(1:nx/2),2); Qu = repelem(sw(nx/2 + 1:nx/2 + nu/2),2);
    if isscalar(sw(nx/2 + 1:nx/2 + nu/2))
        Qu = Qu';
    end
    Qr = repelem(sw(nx/2 + nu/2 + 1:nx/2 + nu/2 + nxr/2),2);
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

    Kx = K(:,1:nx);
    Ku = K(:,(nx + 1):(nx + nu));
    Kr = K(:,(nx + nu + 1):end);

    Acl = A_aug - B_aug*K;
    spec = max(abs(eig(Acl)));
    if spec >= 1
        fitness = 1e6;
        disp('One of the particles is too close of the instable area!')
        return;
    end

    try
        fitness = Sim_VSI(Tsim,Ts,VDC,w,A_ref,T_settling,beta_c,Ad,Bd,Ard,Brd,Ha,Kx,Kr,Ku);
    catch ME
        fprintf('\nSimulation failed: %s\n', ME.message)
        disp(getReport(ME, 'extended'))
        fitness = 1e6;
        return;
    end
end