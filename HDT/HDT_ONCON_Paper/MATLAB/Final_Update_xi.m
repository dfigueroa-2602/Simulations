function [Ard,Brd,Kx,Kr,Kxx,Kerr,F] =  Final_Update_xi(LQR_Mode,F_mode,xi_Mode,R_mode,Best_Swarm,Ad_delay,Bd_delay,H,nx,nu,nr,w,Ts)
    if xi_Mode == 1
        xi = Best_Swarm(end);
        Ar = [-2*xi*w w;-w 0];
        Ar = blkdiag(Ar, Ar, Ar, Ar);
        Br = [1;0];
        Br = blkdiag(Br, Br, Br, Br);
        
        sysrd = c2d(ss(Ar,Br,[],[]),Ts,'zoh');
        Ard = sysrd.A;
        Brd = sysrd.B;
        
        nx_k_1 = size(Ad_delay,1);
        nu_k_1 = size(Bd_delay,2);
        nr = size(Ar,1);
        
        A_aug_delay = [ Ad_delay   zeros(nx_k_1, nr) ;
                       -Brd*H      Ard              ];
        
        B_aug_delay = [ Bd_delay                   ;
                       zeros(nr, size(Bd_delay,2))];
    end

    Qx = repelem(Best_Swarm(1:nx/2),2);
    Qd = repelem(Best_Swarm(nx/2 + 1:nx/2 + nu/2),2);
    Qr = repelem(Best_Swarm(nx/2 + nu/2 + 1:nx/2 + nu/2 + nr/2),2);
    Q = diag([(10.^Qx)' (10.^Qd)' (10.^Qr)']);
    if R_mode == 1
        Ru = repelem(Best_Swarm(nx/2 + nu/2 + nr/2 + 1:end - 1),2);
        R = diag((10.^Ru)');
    else
        R = blkdiag(1,1,1,1);
    end
    
    K = dlqr(A_aug_delay,B_aug_delay,Q,R);
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
        M = Cff * ((Iaug - A_aug_delay + B_aug_delay*K) \ B_aug_delay);
        F = pinv(M);
    else
        F = zeros(nu,nu);
    end
end