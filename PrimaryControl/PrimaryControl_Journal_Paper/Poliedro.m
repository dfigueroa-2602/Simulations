function [Hi, Umax] = Poliedro(r, rectas)
    % Funcion que permite obtener un poligono circunscrito en la
    % circunferencia con cantidad de lados dados por 'rectas' (que interpreta
    % a la corriente nominal). Con esto se obtiene 2 parametros, Hi y Umax de 
    % forma tal que Hi*[x,y] = Inom*Umax
    % Definir el radio
    r = 8;
    
    % Cantidad de lados
   % rectas = 8;
    
    % Calculo del angulo
    angle = 2*pi/rectas;
    
    % Inicializar matrices para almacenar los coeficientes A y B, y el vector C
    A = zeros(rectas, 2);
    Umax = zeros(rectas, 1);
    
    % Inicializar matrices para almacenar las coordenadas
    coordenadas_x = zeros(1, rectas);
    coordenadas_y = zeros(1, rectas);
    
    % Calcular coordenadas de los puntos
    for i = 1:rectas
        theta = i * angle;
        coordenadas_x(i) = r * cos(theta);
        coordenadas_y(i) = r * sin(theta);
    end

    y1 = 0;
    y2 = 0;
    x1 = 0;
    x2 = 0;
    
    % Calcular coeficientes Hi, [x, y] y Umax para cada ecuación de la recta
    for i = 1 : (rectas)
        x1 = coordenadas_x(i);
        y1 = coordenadas_y(i);
        if i < rectas
            x2 = coordenadas_x(i + 1); % Circular: conecta el último con el primero
            y2 = coordenadas_y(i + 1);
        end
        if i == rectas
            x2 = coordenadas_x(1); % Circular: conecta el último con el primero
            y2 = coordenadas_y(1);
        end
        % Calcular la pendiente y el término independiente
        m = (y2 - y1) / (x2 - x1);
        n = y1 - m * x1;
        
        % Asignar los coeficientes A y B
        A(i, :) = [-m, 1];
        
        % Asignar el vector Umax
        Umax(i) = -n/r;
    end
    auxUmax = [];
    Hi = [];
    for i = 1:length(Umax)
        if Umax(i) > 0
            auxUmax = [auxUmax; Umax(i)];
            Hi = [Hi; A(i, :)];
        end
    end
    
    Umax = auxUmax;
end