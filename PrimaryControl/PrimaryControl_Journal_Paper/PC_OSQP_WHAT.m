function u = PC_OSQP_WHAT(x)
    % Definition of model matrices and weights
    Ad = evalin('base','Ad');
    Bd = evalin('base','Bd');
    Q = evalin('base','Q');
    R = evalin('base','R');
    Qp = evalin('base','Qp');
    N = evalin('base','N');
    
    % Obtain the number of states and actuations
    [nx,nu] = size(Bd);
    
    res_x = 6; % Restricciones en estados
    res_u = 2; % Restricciones en entradas

    num_box_states = (N)* res_x;  % Restricciones en estados para cada paso del horizonte
    num_box_inputs = (N - 1)*res_u;  % Restricciones en entradas para cada paso del horizonte
    num_eq_res = nx + N*nx + nu; % Restricciones de igualdad

    % Tamaño total de lb y ub
    lb_size = num_box_states + num_box_inputs + num_eq_res; % Restricciones totales

    % Selección de lb y ub desde x
    lb = x(1:lb_size);
    ub = x(lb_size + 1:2*lb_size);
    
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
    xineq = kron(speye(N + 1),Hi*Mi);
    uineq = kron(speye(N),Hv);

    xineq(1:res_x,:) = [];

    Aineq = blkdiag(xineq,uineq);
    
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

    u0 = res.x((N + 1)*nx + 1:(N + 1)*nx + nu);
    u = [u0; res.info.iter;res.info.rho_estimate;res.info.status_val;res.info.solve_time];
end