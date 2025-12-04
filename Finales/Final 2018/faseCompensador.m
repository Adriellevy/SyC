function fase_necesaria = faseCompensador(Gnum, Gden, polo_objetivo, tipo_compensador)
% faseCompensador usando coeficientes de polinomios
%
% ENTRADAS:
%   Gnum              → coeficientes del numerador (ej: 1 ó [1 3])
%   Gden              → coeficientes del denominador (ej: [1 4 8 0])
%   polo_objetivo     → punto s deseado
%   tipo_compensador  → 'cero' o 'polo'
%
% SALIDA:
%   fase_necesaria    → fase en grados requerida del compensador

    % --- Función ángulo ---
    ang = @(a,b) atan2d(imag(b - a), real(b - a));

    % --- Obtener ceros y polos ---
    ceros_existentes = roots(Gnum);
    polos_existentes = roots(Gden);

    % ---- Calcular fase total actual ----
    fase = 0;

    % Fase aportada por ceros
    for i = 1:length(ceros_existentes)
        fase = fase + ang(ceros_existentes(i), polo_objetivo);
    end

    % Fase aportada por polos
    for i = 1:length(polos_existentes)
        fase = fase - ang(polos_existentes(i), polo_objetivo);
    end

    % Normalizar
    fase_actual = mod(fase, 360);

    % --- Determinar fase necesaria según tipo ---
    switch lower(tipo_compensador)
        case 'cero'
            % El cero suma fase
            fase_necesaria = 180 - fase_actual;

        case 'polo'
            % El polo resta fase
            fase_necesaria = -(180 - fase_actual);

        otherwise
            error("tipo_compensador debe ser 'cero' o 'polo'");
    end
end
