function [Kx,Kr,Kxx,Kerr,F] =  Final_Update(LQR_Mode,F_mode,R_mode,Best_Swarm,A_aug,B_aug,nx,nu,nr)
    Qx = repelem(Best_Swarm(1:nx/2),2);
    Qd = repelem(Best_Swarm(nx/2 + 1:nx/2 + nu/2),2);
    Qr = repelem(Best_Swarm(nx/2 + nu/2 + 1:nx/2 + nu/2 + nr/2),2);
    Q = diag([(10.^Qx)' (10.^Qd)' (10.^Qr)']);
    if R_mode == 1
        Ru = repelem(Best_Swarm(nx/2 + nu/2 + nr/2 + 1:end),2);
        R = diag((10.^Ru)');
    else
        R = blkdiag(1,1,1,1);
    end
    
    K = dlqr(A_aug,B_aug,Q,R);
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
end