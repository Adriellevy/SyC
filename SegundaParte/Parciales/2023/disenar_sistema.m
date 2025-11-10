function [Gc, T_lazo_cerrado, Kc, Kv] = disenar_sistema(G, varargin)
    % ===============================================
    % Diseña un sistema controlado con Gc(s)
    % Cumpliendo Mp y Ts, graficando:
    %   - Área permitida
    %   - Singularidades planta/controlador
    %   - Respuesta al escalón y rampa
    %   - Constantes dinámicas (ζ, ωn, τ, Kv, etc.)
    % ===============================================

    % --- Lectura de parámetros ---
    p = inputParser;
    addParameter(p, 'Mp', 0.1);
    addParameter(p, 'Ts', 0.6);
    addParameter(p, 'Gc', []); % Controlador opcional
    parse(p, varargin{:});

    Mp = p.Results.Mp;
    Ts = p.Results.Ts;
    Gc_in = p.Results.Gc;

    s = tf('s');

    % --- Calcular zeta y wn ---
    zeta = -log(Mp) / sqrt(pi^2 + (log(Mp))^2);
    wn = 4 / (zeta * Ts);

    % --- Polos dominantes deseados ---
    sigma = zeta * wn;
    wd = wn * sqrt(1 - zeta^2);
    polos_deseados = [-sigma + 1j*wd, -sigma - 1j*wd];
    fprintf('ζ = %.3f, ωn = %.3f, polos deseados = %.2f ± j%.2f\n', zeta, wn, -sigma, wd);

    % --- Calcular o ajustar Gc ---
    if isempty(Gc_in)
        % Controlador proporcional
        s_p = polos_deseados(1);
        G_eval = evalfr(G, s_p);
        Kc = 1 / abs(G_eval);
        Gc = Kc;
        fprintf('Controlador proporcional calculado: Kc = %.3f\n', Kc);
    else
        % Controlador pasado por parámetro
        Gc = Gc_in;
        s_p = polos_deseados(1);
        L_eval = evalfr(Gc * G, s_p);
        if abs(L_eval) == 0
            warning('No se puede escalar el controlador (L(s_p)=0)');
            Kc = 1;
        else
            Kc = 1 / abs(L_eval);
        end
        Gc = Kc * Gc;
        fprintf('Controlador escalado: Kc = %.3f\n', Kc);
    end

    % --- Transferencia en lazo abierto y cerrado ---
    L = Gc * G;
    T_lazo_cerrado = feedback(L, 1);

    % --- Constante de velocidad (Kv) ---
    Kv = dcgain(s * L);
    e_rampa = 1 / Kv;
    fprintf('Kv = %.4f → Error en régimen para rampa e_rampa = %.4f\n', Kv, e_rampa);

    % --- Constantes dinámicas del sistema a lazo cerrado ---
    polos_cl = pole(T_lazo_cerrado);
    polos_dom = polos_cl(abs(imag(polos_cl)) == max(abs(imag(polos_cl))));

    if numel(polos_dom) >= 2
        pdom = polos_dom(1);
        sigma_cl = -real(pdom);
        wd_cl = imag(pdom);
        wn_cl = sqrt(sigma_cl^2 + wd_cl^2);
        zeta_cl = sigma_cl / wn_cl;
        tau_cl = 1 / sigma_cl;
    else
        pdom = polos_cl(1);
        wn_cl = abs(pdom);
        zeta_cl = 1;
        tau_cl = 1 / abs(pdom);
    end

    % --- Gráficos ---
    figure('Name', 'Análisis del Sistema Controlado', 'NumberTitle', 'off');

    % 1. Lugar de raíces y singularidades
    subplot(2,2,1);
    GraficarLugarDeSingularidades(Gc);
    GraficoAreasPosiblesMasSingularidades(Ts, Mp*100, G);
    legend('Área permitida','Polos deseados','Polos Gc','Ceros Gc');
    title('Lugar de raíces');
    grid on;

    % 2. Respuesta al escalón
    subplot(2,2,2);
    step(T_lazo_cerrado);
    title('Respuesta al Escalón');
    grid on;

    % 3. Respuesta a la rampa
    subplot(2,2,3);
    t = 0:0.01:5;
    [y, t_out] = lsim(T_lazo_cerrado, t, t);
    plot(t_out, y, 'b', 'LineWidth', 1.5);
    hold on;
    plot(t_out, t, '--r');
    legend('Salida', 'Referencia');
    title('Respuesta a la Rampa');
    grid on;

    % 4. Constantes del sistema
    subplot(2,2,4);
    axis off;
    text(0,0.9, sprintf('ζ = %.3f', zeta_cl));
    text(0,0.75, sprintf('ωn = %.3f', wn_cl));
    text(0,0.6, sprintf('τ = %.3f s', tau_cl));
    text(0,0.45, sprintf('Kc = %.3f', Kc));
    text(0,0.3, sprintf('Kv = %.3f', Kv));
    text(0,0.15, sprintf('e_{rampa} = %.3f', e_rampa));
    text(0,0.0, sprintf('Ganancia en DC = %.3f', dcgain(T_lazo_cerrado)));
    title('Constantes del Sistema');

    % --- Consola ---
    fprintf('\n==== Resultados ====\n');
    fprintf('ζ = %.4f\nωn = %.4f rad/s\nτ = %.4f s\n', zeta_cl, wn_cl, tau_cl);
    fprintf('Kc = %.4f\nKv = %.4f\nError rampa = %.4f\n', Kc, Kv, e_rampa);
    fprintf('Valor final escalón = %.4f\n', dcgain(T_lazo_cerrado));
    fprintf('Polos del lazo cerrado:\n');
    disp(polos_cl);
end
