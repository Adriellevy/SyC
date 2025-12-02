function [PLC, zeta, wn] = polos_TS_tau(Ts, tau)
% --------------------------------------------------------
% Calcula los polos de un sistema subamortiguado
% a partir del tiempo de establecimiento (Ts)
% y la constante de tiempo (tau)
%
% Entradas:
%   Ts  -> tiempo de establecimiento [s]
%   tau -> constante de tiempo [s]
%
% Salidas:
%   p1, p2 -> polos complejos conjugados
%   zeta   -> coeficiente de amortiguamiento
%   wn     -> frecuencia natural
% --------------------------------------------------------

    % --- Cálculos ---
    zeta = 4 * tau / Ts;
    wn = 1 / (zeta * tau);

    % --- Polos ---
    sigma = -zeta * wn;
    wd = wn * sqrt(1 - zeta^2);
    PLC(1) = sigma + 1j * wd;
    PLC(2) = sigma - 1j * wd;

    % --- Mostrar resultados ---
    fprintf('\n=== Resultados (Ts, tau) ===\n');
    fprintf('Coeficiente de amortiguamiento ? = %.4f\n', zeta);
    fprintf('Frecuencia natural ?n = %.4f rad/s\n', wn);
    fprintf('Polos del sistema: p1 = %.4f%+.4fj, p2 = %.4f%+.4fj\n', ...
            real(PLC(1)), imag(PLC(1)), real(PLC(2)), imag(PLC(2)));
end
