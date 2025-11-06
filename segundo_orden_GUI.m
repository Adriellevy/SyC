function segundo_orden_GUI_v2016
    % ==============================
    % GUI: Sistema de segundo orden (MATLAB 2016 compatible)
    % ==============================

    % Ventana principal
    fig = figure('Name','Sistema de Segundo Orden - Ogata U5',...
        'NumberTitle','off','Position',[100 100 800 600]);

    % Valores iniciales
    wn0 = 5;        % frecuencia natural
    zeta0 = 0.5;    % factor de amortiguamiento
    t = 0:0.01:10;  % tiempo más largo para ver si tarda en estabilizar

    % Axes para la gráfica
    ax = axes('Parent',fig,'Position',[0.1 0.35 0.8 0.6]);
    plot_system(ax, wn0, zeta0, t);

    % Slider para wn
    uicontrol('Parent',fig,'Style','text','String','wn',...
        'Position',[150 80 100 20],'FontSize',10);
    sliderWn = uicontrol('Parent',fig,'Style','slider',...
        'Min',0.5,'Max',20,'Value',wn0,'Position',[100 60 200 20],...
        'Callback',@(src,~) updatePlot());

    % Slider para zeta
    uicontrol('Parent',fig,'Style','text','String','zeta',...
        'Position',[550 80 100 20],'FontSize',10);
    sliderZeta = uicontrol('Parent',fig,'Style','slider',...
        'Min',0,'Max',2,'Value',zeta0,'Position',[500 60 200 20],...
        'Callback',@(src,~) updatePlot());

    % Etiquetas dinámicas
    lblWn = uicontrol('Style','text','Position',[100 40 200 20],...
        'String',sprintf('wn = %.2f',wn0),'FontSize',10);
    lblZeta = uicontrol('Style','text','Position',[500 40 200 20],...
        'String',sprintf('zeta = %.2f',zeta0),'FontSize',10);

    % Función de actualización
    function updatePlot()
        wn = get(sliderWn,'Value');
        zeta = get(sliderZeta,'Value');
        plot_system(ax, wn, zeta, t);
        set(lblWn,'String',sprintf('wn = %.2f',wn));
        set(lblZeta,'String',sprintf('zeta = %.2f',zeta));
    end
end

% ==============================
% Función para graficar sistema y cruces por equilibrio
% ==============================
function plot_system(ax, wn, zeta, t)
    num = [wn^2];
    den = [1 2*zeta*wn wn^2];
    sys = tf(num, den);
    [y,t] = step(sys, t);

    % Punto de equilibrio (valor final con escalón unitario ? DC gain)
    y_eq = dcgain(sys);

    % Detectar cruces por el punto de equilibrio
    crossings = find((y(1:end-1)-y_eq).*(y(2:end)-y_eq) < 0);

    cla(ax); % limpiar ejes
    plot(ax, t, y, 'b', 'LineWidth',2); hold(ax,'on');

    % Dibujar línea horizontal de equilibrio (reemplazo de yline)
    plot(ax, [t(1) t(end)], [y_eq y_eq], '--k');

    % Marcar cruces
    for k = 1:length(crossings)
        idx = crossings(k);
        % Interpolación lineal para el cruce exacto
        t_cross = interp1(y(idx:idx+1)-y_eq, t(idx:idx+1), 0);
        plot(ax, t_cross, y_eq, 'ro','MarkerFaceColor','r');
    end

    % Mostrar cuántos cruces hubo en el título
    title(ax, sprintf('Respuesta al Escalón (wn=%.2f, zeta=%.2f) - Cruces=%d', ...
        wn, zeta, length(crossings)));

%     % Adaptar eje X si converge al equilibrio
%     if abs(y(end)-y_eq) < 0.1   % criterio de convergencia
%         % buscar el tiempo de asentamiento aprox (2%)
%         ts_idx = find(abs(y-y_eq) < 0.002*abs(y_eq), 1);
%         if ~isempty(ts_idx)
%             xlim(ax, [0 11]); % recorto al 150% del tiempo de asentamiento
%         end
%     end

    grid(ax,'on');
    xlabel(ax,'Tiempo [s]');
    ylabel(ax,'Salida');
    ylim(ax, [min(y)-0.2 max(y)+0.2]); % dinámico
    hold(ax, 'off');
end
