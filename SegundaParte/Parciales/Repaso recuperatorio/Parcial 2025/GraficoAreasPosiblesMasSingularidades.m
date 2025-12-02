function GraficoAreasPosiblesMasSingularidades(Ts, zeta_or_Mp,G)
    % GraficoAreasPosibles superpone sobre la figura actual:
    % Ts: tiempo de establecimiento deseado (segundos)
    % zeta_or_Mp: si <= 1 -> se interpreta como zeta; si > 1 -> se interpreta como Mp (%)
    %
    % Ejemplo:
    %   GraficoAreasPosibles(3,0.3)
    %   GraficoAreasPosibles(2,10)

    hold on;
    ax = gca;

    % ==============================
    % Obtener límites actuales
    % ==============================
    lims = axis(ax); % [xmin xmax ymin ymax]
    xmin = lims(1); xmax = lims(2);
    ymin = lims(3); ymax = lims(4);

    % ==============================
    % 1) Límite de tiempo de establecimiento
    % ==============================
    sigma_lim = -4 / Ts;

    % ==============================
    % 2) Calcular zeta
    % ==============================
    if zeta_or_Mp <= 1
        zeta = zeta_or_Mp;
        infoStr = sprintf('\\zeta = %.3g', zeta);
    else
        Mp = zeta_or_Mp;
        Mp_frac = Mp / 100;
        if Mp_frac <= 0 || Mp_frac >= 1
            error('Mp debe estar entre 0 y 100 (excluyendo extremos).');
        end
        L = log(Mp_frac);
        zeta = sqrt((L^2) / (pi^2 + L^2));
        infoStr = sprintf('Mp = %.2f%%  ->  \\zeta = %.3g', Mp, zeta);
    end

    % ==============================
    % 3) Calcular ángulo beta (líneas de amortiguamiento)
    % ==============================
    beta = acos(min(max(zeta, 0), 0.99999));

    % ==============================
    % 4) Ajustar límites de los ejes
    % ==============================
    % Queremos que se vea la línea vertical y las líneas rojas completas
    y_max_teorico = abs(tan(beta) * (-sigma_lim));

    % Expandimos ejes si es necesario
    margenX = abs(0.2 * sigma_lim);
    margenY = 0.2 * y_max_teorico;

    xmin_nuevo = min(xmin, sigma_lim - margenX);
    xmax_nuevo = max(xmax, 0.5); % dejamos margen hacia la derecha del eje imaginario
    ymax_nuevo = max(ymax, 1.2 * y_max_teorico);
    ymin_nuevo = -ymax_nuevo; % simetría vertical

    axis([xmin_nuevo xmax_nuevo ymin_nuevo ymax_nuevo]);

    % ==============================
    % 5) Dibujar líneas y zona
    % ==============================
    x_line = linspace(xmin_nuevo, 0, 300);
    y_up =  tan(beta) .* (-x_line);
    y_down = -y_up;

    plot([sigma_lim sigma_lim], [ymin_nuevo ymax_nuevo], 'g--', 'LineWidth', 1.4);
    plot(x_line, y_up, 'r--', 'LineWidth', 1.2);
    plot(x_line, y_down, 'r--', 'LineWidth', 1.2);

    % Región rellena (zona aceptable)
    y_at_sigma_up = tan(beta) * (-sigma_lim);
    y_at_sigma_down = -y_at_sigma_up;
    Xpoly = [sigma_lim, xmin_nuevo, xmin_nuevo, sigma_lim];
    Ypoly = [y_at_sigma_up, tan(beta)*(-xmin_nuevo), -tan(beta)*(-xmin_nuevo), y_at_sigma_down];

    fill(Xpoly, Ypoly, [0.8 0.9 1], 'FaceAlpha', 0.35, 'EdgeColor', 'none');

    % Etiquetas
    text(sigma_lim, ymax_nuevo*0.9, sprintf('T_s = %.2f s', Ts), 'Color', [0 0.5 0], ...
         'HorizontalAlignment', 'center');
    text(xmin_nuevo + 0.05*(xmax_nuevo-xmin_nuevo), ymax_nuevo*0.85, infoStr, 'Color', 'r');

    % ==============================
    % 6) Leyenda
    % ==============================
    lh = findobj(gcf,'Type','Legend');
    if isempty(lh)
        legend({'Lugar de singularidades', 'Límite T_s', 'Líneas \zeta', 'Zona aceptable'}, ...
               'Location','best');
    end

    % grid on;
    hold on;
    GraficarLugarDeSingularidades(G)
    hold off;
end
