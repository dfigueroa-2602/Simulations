function ctrl = PC_OSQP(input)
    % Definition of model matrices and weights
    Ad = evalin('base','Ad');
    Bd = evalin('base','Bd');
    Q = evalin('base','Q');
    R = evalin('base','R');
    Qp = evalin('base','Qp');
    
    % Obtain the number of states and actuations
    [nx,nu] = size(Bd);

    % MPC Controller Horizon
    N = 2;
    
    % Number of sides of the polyhedra limits
    r = 12;
    
    % Obtain the low and upper bounds from the steady state input
    lb = input(1:37);
    ub = input(38:74);
    
    % Define constraints for the filter current states
    %     ifd ifq igd igq vcd vcq delta
    Mi = [ 1   0   0   0   0   0    0;
           0   1   0   0   0   0    0];

    a1 = tan(deg2rad(15));
    a2 = tan(deg2rad(45));
    a3 = tan(deg2rad(75));
    
    Hi = [a1    1;
          a2    1;
          a3    1;
          a3    -1;
          a2    -1;
          a1    -1];
 
    % Construct the actuations matrix for box constraints for vs and ws
    Hv = [1 0;
          0 1];
    
    % Cast MPC to a QP one
    % P and q matrices from QP solver
    P = blkdiag(kron(speye(N), Q), Qp, kron(speye(N), R));

    % Linear objetive
    q = zeros(length(P), 1);
    
    % Equality restrictions asociated with the dynamic model
    Ax = kron(speye(N + 1), -speye(nx)) + kron(sparse(diag(ones(N, 1), -1)), Ad);
    Bu = kron([sparse(1, N)  ; ...
               speye(N)], Bd);
    
    % The equality restrictions are written as inequality ones
    % leq <= Aeq * x_QP <= ueq
    Aeq = [Ax, Bu];
    
    % Inequality restrictions asociated with inputs and states of the
    % system
    Aineq = blkdiag(kron(eye(N + 1),Hi*Mi), kron(eye(N),Hv));

    % The initial states restrictions are deleted
    Aineq(1:r/2,:) = [];
    
    As = [Aeq     ;
          Aineq]  ;
    
    persistent prob

    alpha   = evalin('base','alpha');
    rho     = evalin('base','rho');
    max_iter = evalin('base','max_iter');

    if isempty(prob)
        % This way the init and setup happens ONCE
        prob = osqp;

        % Setup workspace
        prob.setup(P, q, As, lb, ub, 'verbose', false, 'warm_start', true, 'alpha', alpha, 'rho', rho, 'scaling', 1000, 'adaptive_rho', false, 'check_termination', 5, 'max_iter', max_iter);
    end

    % The measument is encoded in the upper and lower limits, we just update those
    prob.update('l', lb, 'u', ub);

    res = prob.solve();

    ctrl = res.x((N + 1)*nx + 1:(N + 1)*nx + nu);
    x1_ifd = res.x(8);
    ctrl = [x1_ifd;ctrl;res.info.iter;res.info.rho_estimate;res.info.status_val;res.info.solve_time];
end