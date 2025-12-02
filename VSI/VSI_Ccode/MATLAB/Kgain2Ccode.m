function Kgain2Ccode(K)
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
    disp(['K gain ready in the ' C_folder ' folder'])
end