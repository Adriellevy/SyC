function [wn, tau, polos_deseados] = analizar_sistema(G, varargin)
    % ===============================================
    % FUNCION: [wn, tau, polos] = analizar_sistema(G, 'Mp', valor, 'Ts', valor)
    %           o [wn, tau, polos] = analizar_sistema(G, 'tau', valor, 'Ts', valor)
    %
    % Ejemplo:
    % syms s;
    % densimbolo = (s+2)*(s+5);
    % Den = sym2poly(expand(densimbolo));
    % Num = [2];
    % G = tf(Num, Den);
    % [wn, tau, polos] = analizar_sistema(G, 'Mp', 0.08, 'Ts', 2);
    % ===============================================

    % --- Lectura de parámetros ---
    p = inputParser;
    addParameter(p, 'Mp', []);
    addParameter(p, 'tau', []);
    addParameter(p, 'Ts', []);
    parse(p, varargin{:});
    Mp = p.Results.Mp;
    tau_in = p.Results.tau;
    Ts = p.Results.Ts;

    % --- Validación de entrada ---
    if ~xor(isempty(Mp), isempty(tau_in))
        error('Debe ingresar solo uno: "Mp" o "tau", no ambos.');
    end
    if isempty(Ts)
        error('Debe especificar el tiempo de establecimiento Ts.');
    end

    % --- Cálculo del factor de amortiguamiento ζ ---
    if ~isempty(Mp)
        % Mp -> ζ
        zeta = -log(Mp) / sqrt(pi^2 + (log(Mp))^2);
        fprintf('Factor de amortiguamiento ζ calculado a partir de Mp = %.3f -> ζ = %.3f\n', Mp, zeta);
    end

    % --- Cálculo de ωn a partir del Ts dado ---
    % Ts ≈ 4 / (ζ*ωn)
    wn = 4 / (zeta * Ts);
    tau = 1 / (zeta * wn);

    fprintf('Frecuencia natural ωn = %.3f rad/s\n', wn);
    fprintf('Constante de tiempo τ = %.3f s\n', tau);

    % --- Polos deseados ---
    sigma = zeta * wn;
    wd = wn * sqrt(1 - zeta^2);
    polos_deseados = [-sigma + 1j*wd, -sigma - 1j*wd];

    fprintf('\nPolos dominantes requeridos:\n');
    disp(polos_deseados);

    % --- Polos y ceros del sistema original ---
    polos_originales = pole(G);
    ceros_originales = zero(G);

    % --- Crear figura con subplots ---
    figure('Name', 'Análisis del sistema', 'NumberTitle', 'off', 'Position', [100 100 1000 600]);

    % ===== SUBPLOT 1: Polos y ceros =====
    subplot(2,2,1);
    hold on;
    plot(real(polos_originales), imag(polos_originales), 'bx', 'MarkerSize', 10, 'LineWidth', 2);
    if ~isempty(ceros_originales)
        plot(real(ceros_originales), imag(ceros_originales), 'go', 'MarkerSize', 8, 'LineWidth', 1.5);
    end
    plot(real(polos_deseados), imag(polos_deseados), 'rx', 'MarkerSize', 10, 'LineWidth', 2);
    grid on;
    xlabel('Parte Real'); ylabel('Parte Imaginaria');
    title('Polos y ceros: Originales vs Deseados');
    legend('Polos originales', 'Ceros', 'Polos deseados', 'Location', 'best');
    axis equal;

    % ===== SUBPLOT 2: Respuesta al Escalón =====
    subplot(2,2,2);
    step(G);
    grid on;
    title('Respuesta al Escalón');
    xlabel('Tiempo [s]');
    ylabel('Amplitud');

    % ===== SUBPLOT 3: Respuesta a la Rampa =====
    subplot(2,2,3);
    t = 0:0.01:10;
    [y, t_out] = lsim(G, t, t);
    plot(t_out, y, 'b', 'LineWidth', 1.5);
    hold on;
    plot(t_out, t, '--r', 'LineWidth', 1);
    grid on;
    title('Respuesta a la Rampa');
    xlabel('Tiempo [s]');
    ylabel('Salida');
    legend('Salida', 'Entrada Rampa', 'Location', 'best');

    % ===== SUBPLOT 4: Info del sistema =====
    subplot(2,2,4);
    text(0,0.8, sprintf('ζ = %.3f', zeta), 'FontSize', 12);
    text(0,0.6, sprintf('ωn = %.3f rad/s', wn), 'FontSize', 12);
    text(0,0.4, sprintf('τ = %.3f s', tau), 'FontSize', 12);
    text(0,0.2, sprintf('Polos: %.2f ± j%.2f', -sigma, wd), 'FontSize', 12);
    text(0,0.05, sprintf('Ts = %.2f s', Ts), 'FontSize', 12);
    axis off;
    title('Datos del Diseño');

    % --- Devolver resultados ---
    if nargout == 0
        fprintf('\nSalida:\n  wn = %.3f\n  tau = %.3f\n  Polos = [%.3f ± j%.3f]\n', wn, tau, -sigma, wd);
    end
end
