function d = distanciaPorFaseTangente(polo_objetivo, fase_requerida)
% distanciaPorFaseTangente
% Calcula la distancia horizontal (sobre el eje real)
% entre el polo objetivo y el cero/polo compensador, usando la relación:
%
%       d = imag(s_d) / tan(fase)
%
% ENTRADAS:
%   polo_objetivo  ? punto complejo s_d = sigma + j*omega
%   fase_requerida ? fase (en grados) que debe aportar el compensador
%
% SALIDA:
%   d ? distancia horizontal (positiva o negativa)
%
% Ejemplo:
%   s_obj = -4 + 5j;
%   fase  = 40;
%   d = distanciaPorFaseTangente(s_obj, fase)
%

    % Separar componentes
    sigma = real(polo_objetivo);
    omega = imag(polo_objetivo);

    % Convertir fase a radianes
    phi = deg2rad(fase_requerida);

    % Distancia usando tangente
    d = omega / tan(phi);
end
