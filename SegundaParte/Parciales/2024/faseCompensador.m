function fase_necesaria = faseCompensador(polos_existentes, ceros_existentes, polo_objetivo)
% faseCompensador
% Calcula la fase que debe aportar un compensador (cero o polo)
% para cumplir la condición de fase del Lugar Geométrico de las Raíces.
%
%  fase_necesaria = 180° - (fase_total_actual mod 360°)
%
% ENTRADAS:
%   polos_existentes   ? vector fila/columna con los polos existentes
%   ceros_existentes   ? vector fila/columna con los ceros existentes
%   polo_objetivo      ? punto complejo s = sigma + j*w donde queremos ubicar el polo
%
% SALIDA:
%   fase_necesaria     ? fase (en grados) que debe aportar el compensador
%
% Ejemplo de uso:
%   p = [-2 -5];
%   z = [];
%   s_obj = -4 + 6j;
%   fase = faseCompensador(p, z, s_obj)

    % --- función interna de cálculo de ángulo ---
    ang = @(a, b) atan2d(imag(b - a), real(b - a)); 
    % ángulo desde a ? b en grados

    fase = 0;

    % suma de ángulos de ceros
    for i = 1:length(ceros_existentes)
        fase = fase + ang(ceros_existentes(i), polo_objetivo);
    end

    % resta de ángulos de polos
    for i = 1:length(polos_existentes)
        fase = fase - ang(polos_existentes(i), polo_objetivo);
    end

    % fase que debe aportar el compensador
    fase_necesaria = 180 - fase;
end
