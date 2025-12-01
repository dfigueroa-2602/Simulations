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


K_str = mat2str(K);
K_str = extractBetween(K_str,'[',']');
K_str = split(K_str,';');

% for row = 1:size(K,1)
%     row_K_str = K_str{row};
%     row_K_str = strrep(row_K_str,' ',', ');
%     K_c = ['#define K_LQR = { {' row_K_str '}'];
%     if isempty(K_c) == 0
%         K_c = append(K_c,', {',row_K_str,'} };');
%     end
% end
rows = cell(size(K,1),1);

for row = 1:size(K,1)
    row_K_str = K_str{row};
    row_K_str = strrep(row_K_str, ' ', ', ');  % proper commas
    rows{row} = ['{ ' row_K_str ' }'];         % store row
end

% Write the C code K gain definition
aux_string = ['#define K_LQR_Values {' '                                                                                                     \\\\' '\n'];
K_c = sprintf(aux_string, size(K,1), size(K,2));

% Append every row of K in the K_c
for i = 1:size(K,1)
    if i < size(K,1)
        K_c = [K_c '    ' rows{i} ', ' '\\' '\n'];
    else
        K_c = [K_c '    ' rows{i} ' \\' '\n'];
    end
end

% Close the C code gain with its respective curly-bracket
K_c = [K_c '};'];

CurrentFolder = pwd;
C_Folder = extractBefore(CurrentFolder,'MATLAB');
C_folder = append(C_Folder,'C_code/src/');
C_file = fopen([C_folder 'Gain.h'], 'wt');
fprintf(C_file,'#pragma once\n#ifndef Gain_H_\n#define Gain_H_\n\n');
fprintf(C_file, [K_c '\n\n']);
fprintf(C_file,'#endif /* Gain_H_ */'); fclose(C_file);