rng('shuffle');
if isempty(gcp('nocreate')), parpool; end
spmd
    load_system('VSI_ResonantController_C_Simulation_Blocks.slx');
    set_param(model,'FastRestart','on');
    ws = get_param(model,'modelworkspace');
    ws.assignin('P', P);
    ws.assignin('Ts', Ts);
    ws.assignin('A',A);
    ws.assignin('B',B);
    ws.assignin('C',C);
    ws.assignin('Ard',Ard);
    ws.assignin('Brd',Brd);
    ws.assignin('Ha',Ha);
    ws.assignin('w', w);
    ws.assignin('beta_c', beta_c);
end