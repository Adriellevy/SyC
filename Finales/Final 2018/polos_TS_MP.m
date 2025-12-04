function [PLC, zeta, wn] = polos_TS_MP(Ts, Mp)
% --------------------------------------------------------
% Calcula los polos de un sistema subamortiguado
% a partir del tiempo de establecimiento (Ts)
% y el máximo sobreimpulso (Mp)
%
% Entradas:
%   Ts -> tiempo de establecimiento [s]
%   Mp -> sobreimpulso máximo (ej: 0.1 para 10%)
%
% Salidas:
%   p1, p2 -> polos complejos conjugados
%   zeta   -> coeficiente de amortiguamiento
%   wn     -> frecuencia natural
% --------------------------------------------------------

    % --- Cálculos ---
    zeta = -log(Mp) / sqrt(pi^2 + (log(Mp))^2);
    wn = 4 / (zeta * Ts);

    % --- Polos ---
    sigma = -zeta * wn;
    wd = wn * sqrt(1 - zeta^2);
    PLC(1) = sigma + 1j * wd;
    PLC(2) = sigma - 1j * wd;

    % --- Mostrar resultados ---
    fprintf('\n=== Resultados (Ts, Mp) ===\n');
    fprintf('Coeficiente de amortiguamiento ? = %.4f\n', zeta);
    fprintf('Frecuencia natural ?n = %.4f rad/s\n', wn);
    fprintf('Polos del sistema: p1 = %.4f%+.4fj, p2 = %.4f%+.4fj\n', ...
            real(PLC(1)), imag(PLC(1)), real(PLC(2)), imag(PLC(2)));
end
