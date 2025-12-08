function [Kx, Kr, Ku] = Final_Value(b_swarm,Ad_aug,Bd_aug,nx,nu,nxr,R_mode)
    sw_best = squeeze(b_swarm);
    Qx = repelem(sw_best(1:nx/2),2); Qu = repelem(sw_best(nx/2 + 1:nx/2 + nu/2),2);
    if isscalar(sw_best(nx/2 + 1:nx/2 + nu/2))
        Qu = Qu';
    end
    Qr = repelem(sw_best(nx/2 + nu/2 + 1:nx/2 + nu/2 + nxr/2),2);
    Q = diag([(10.^Qx)' (10.^Qu)' (10.^Qr)']);
    if R_mode == 1
        Ru = repelem(sw_best(nx/2 + nu/2 + nr/2 + 1:end),2);
        R = diag((10.^Ru)');
    else
        R = blkdiag(1,1);
    end
    
   [K,~,~] = dlqr(Ad_aug, Bd_aug, Q, R);

    Kx = K(:,1:nx);
    Ku = K(:,(nx + 1):(nx + nu));
    Kr = K(:,(nx + nu + 1):end);
end