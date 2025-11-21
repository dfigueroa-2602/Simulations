sys_HDT = ss(A,B,eye(nx),zeros(nx,size(B,2)));
sys_HDTd = c2d(sys_HDT,Ts,'zoh');
Ad = sys_HDTd.A; Bd = sys_HDTd.B;

Ad_delay = [Ad             Bd           ;
            zeros(nu,nx)   zeros(nu,nu)];
Bd_delay = [zeros(nx,nu);
            eye(nu)];

C_delay = [C zeros(nx,nu)];

H = C_delay([3 4 5 6], :);