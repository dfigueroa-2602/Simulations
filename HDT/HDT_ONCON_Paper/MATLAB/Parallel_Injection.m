rng('shuffle');
if isempty(gcp('nocreate')), parpool; end
spmd
    load_system('PSO_HDT_Discrete.slx');
    set_param(model,'FastRestart','on');
    ws = get_param(model,'modelworkspace');
    ws.assignin('PiL', PiL);
    ws.assignin('Pvg', Pvg);
    ws.assignin('Vg', Vg);
    ws.assignin('Ts', Ts);
    if xi_Mode == 0
        ws.assignin('Ard', Ard);
        ws.assignin('Brd', Brd);
    end
    ws.assignin('A',A);
    ws.assignin('B',B);
    ws.assignin('C',C);
    ws.assignin('w', w);
    ws.assignin('beta_c', beta_c);
end