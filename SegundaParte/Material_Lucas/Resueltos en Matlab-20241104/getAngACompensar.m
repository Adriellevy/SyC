function [ang_a_compensar] = getAngACompensar(P_LC_p, z, p)
%GETANGACOMPENSAR - Retorna el angulo a compensar en grados
%   P_LC_p es el Polo a Lazo Cerrado deseado (segundo cuadrante)
%   Por criterio de Fase:   
%       sum( angle(P_LC(1) - polos) ) - sum( angle(P_LC(1) - ceros) ) = pi
%   O lo que es lo mismo, escrito de una forma más sencilla
%       sum(a_polos)                  - sum(a_ceros)                  = pi
%   Si separamos el angulo a compensar que queremos (_q)
%   a_comp_q + sum(a_polos) - sum(a_ceros) = pi
%   Despejando el angulo total a compensar entonces:
%   a_comp_q = pi - sum(a_polos) + sum(a_ceros)
%

if nargin ~= 3
    error('Número de argumentos erróneo');
end

if isempty(z)
    % Si no hay Ceros
    ang_z = 0;
else
    % Todos los Ceros que ya tenía
    ang_z = sum( angle(P_LC_p - z) );
    % Paso a grados
    ang_z = (180/pi) * ang_z;
end

if isempty(p)
    % Si no hay Polos
    ang_p = 0;
else
    % Todos los Polos que ya tenía
    ang_p = sum( angle(P_LC_p - p) );
    % Paso a grados
    ang_p = (180/pi) * ang_p;
end

% Cálculo principal
ang_c = 180 - ang_p + ang_z;

% Paso a (-180, 180]
ang_eq = mod(ang_c + 180, 360);

if ang_eq == 0 && ang_c ~= 0
    ang_eq = 180;
else
    ang_eq = ang_eq - 180;
end

ang_a_compensar = ang_eq;

end


