sys_HDT = ss(A,B,eye(nx),zeros(nx,size(B,2)));
sys_HDTd = c2d(sys_HDT,Ts,'zoh');
Ad = sys_HDTd.A; Bd = sys_HDTd.B;

Ad_delay = [Ad             Bd           ;
            zeros(nu,nx)   zeros(nu,nu)];
Bd_delay = [zeros(nx,nu);
            eye(nu)];

C_delay = [C zeros(nx,nu)];

H = C_delay([3 4 5 6], :);

%Ar = [-2*xi*w w;-w -0*xi*w];
Ar = [-xi*w w;-w -xi*w];
%Ar = [0 1; -w^2 0];
Ar = blkdiag(Ar, Ar, Ar, Ar);
Br = [0;1];
%Br = [1;0];
Br = blkdiag(Br, Br, Br, Br);

sysrd = c2d(ss(Ar,Br,[],[]),Ts,'tustin');
Ard = sysrd.A;
Brd = sysrd.B;

nx_k_1 = size(Ad_delay,1);
nu_k_1 = size(Bd_delay,2);
nr = size(Ar,1);

A_aug_delay = [ Ad_delay   zeros(nx_k_1, nr) ;
               -Brd*H      Ard              ];

B_aug_delay = [ Bd_delay                   ;
               zeros(nr, size(Bd_delay,2))];

save('C:\Users\Dave\Documents\git\Simulations\PLECS\HDT\MAT_Resonant','Ar','Br','Ard','Brd','Ad_delay','Bd_delay');

