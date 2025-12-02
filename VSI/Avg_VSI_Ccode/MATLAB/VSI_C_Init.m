clc;
Lf = 3e-3; Cf = 12e-6; Rf = 35e-3; RL = 47;
fsw = 5e3; Ts = 1/fsw;

VDC = 300; f = 50; w = 2*pi*f;

A = [-Rf/Lf  w     -1/Lf   0    ;
     -w     -Rf/Lf  0     -1/Lf ;
      1/Cf   0      0      w    ;
      0      1/Cf  -w      0   ];

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

ss_VSI = ss(A,B,C,D); [Ad,Bd,~,~] = ssdata(c2d(ss_VSI,Ts));

Hx = [0 0 1 0 ;
      0 0 0 1];

Ad_delay = [Ad Bd; zeros(nu,nx) zeros(nu)]; Bd_delay = [zeros(nx,nu); eye(nu)];

Ad_aug = [ Ad_delay             zeros(nx+nu,nu);
          [-Hx*Ts*C zeros(nu)]     eye(nu)    ];
Bd_aug = [ Bd_delay; zeros(nu)];

Qx = blkdiag((1e2)*blkdiag(1,1),(0.5)*blkdiag(1,1));
Qr = eye(2);
Q = blkdiag(Qx,Qr,(1e4)*eye(nu));
R = eye(nu);
K = dlqr(Ad_aug,Bd_aug,Q,R);

sim('VSI_C_Simulation_Blocks.slx');

Kgain2Ccode(K)