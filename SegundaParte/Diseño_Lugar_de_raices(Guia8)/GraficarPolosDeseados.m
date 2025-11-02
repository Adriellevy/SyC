function GraficarPolosDeseados(Ts, zeta_or_Mp)
    % GraficarPolosDeseados muestra los polos deseados según Ts y zeta o Mp
    %
    % Ejemplo:
    %   GraficarPolosDeseados(3, 0.3)   % zeta = 0.3
    %   GraficarPolosDeseados(2, 10)    % Mp = 10%

    hold on;

    % Determinar zeta según lo ingresado
    if zeta_or_Mp <= 1
        zeta = zeta_or_Mp;
    else
        Mp = zeta_or_Mp;
        Mp_frac = Mp/100;
        if Mp_frac <= 0 || Mp_frac >= 1
            error('Mp debe estar entre 0 y 100 (excluyendo extremos).');
        end
        L = log(Mp_frac);
        zeta = sqrt((L^2) / (pi^2 + L^2));
    end

    % Calcular parámetros dinámicos
    wn = 4 / (zeta * Ts);             % Frecuencia natural
    wd = wn * sqrt(1 - zeta^2);       % Parte imaginaria
    sigma = -zeta * wn;               % Parte real

    % Coordenadas de los polos deseados
    polos = [sigma + 1j*wd, sigma - 1j*wd];

    % Graficar polos
    plot(real(polos), imag(polos), 'rx', 'MarkerSize', 10, 'LineWidth', 2);
    text(real(polos(1)) + 0.2, imag(polos(1)) + 0.2, ...
         sprintf('P_{d1} = %.2f %+.2fj', real(polos(1)), imag(polos(1))), ...
         'Color', 'r', 'FontSize', 9);
    text(real(polos(2)) + 0.2, imag(polos(2)) - 0.6, ...
         sprintf('P_{d2} = %.2f %+.2fj', real(polos(2)), imag(polos(2))), ...
         'Color', 'r', 'FontSize', 9);

    % Mostrar información de cálculo
    fprintf('\n=== Polos deseados ===\n');
    fprintf('ζ = %.3f\n', zeta);
    fprintf('ω_n = %.3f rad/s\n', wn);
    fprintf('ω_d = %.3f rad/s\n', wd);
    fprintf('Polos: s = %.3f ± j%.3f\n', sigma, wd);

    legendEntries = findobj(gcf, 'Type', 'Legend');
    if isempty(legendEntries)
        legend({'Lugar de singularidades', 'Polos deseados'}, 'Location', 'best');
    else
        legend('show');
    end

    hold off;
end
