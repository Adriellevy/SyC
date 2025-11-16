%% Anotaciones importantes
% RAF Gc = kc * (s+zc)/(s+sp) siendo |Zc| < |zp|; (queda el polo por delante de iz a derecha)
% RRF Gc = kc * (s+zc)/(s+sp) siendo |Zc| > |zp|; (queda el cero por delante de iz a derecha) 
% PID Gc = kd * (s^2 + S*kp/kd + ki/kd)/(s) === Generalmente Gc = Kc * (s-Zc)^2 / (s-Pc);

%% Parcial 2023
syms s;
densimbolo = (s+2)*(s+5);
Den = sym2poly(expand(densimbolo))
Num = [2]; 

G=tf(Num,Den); 


% 
% Mp = 0.08;     % sobrepico (8%)
% Ts = 0.6;      % tiempo de establecimiento 0,6 s
% 
% [wn,tau,Polos]=analizar_sistema(G, 'Mp', Mp, 'Ts', Ts);

% sisotool(G);
%Se consideran los polos deseados como RAF doble
%
g

%%
syms s;
Den = sym2poly(expand((s+2)*(s+5)));
Num = [2];
Gplanta = tf(Num, Den);
% GraficoAreasPosiblesMasSingularidades(0.6,10,G); 
s=tf('s'); 
% Gc=(s+2)/(s+15); % Quiero utilizar un solo sistema de RAF (no funciona,hay err)
% Gc=((s+2)/(s)); %Aplicando un PI por necesidad de aumentar el tipo
Gc=(s+2)*(s+5)/((s)*(s+10)); %Aplicando dos redes de adelanto de fase (es legal? o es un transformer?)
[Gc, T_lazo_cerrado, K, K1_real]=disenar_sistema(Gplanta, 'Mp', 0.1, 'Ts', 0.6, 'Gc', Gc);
pole(T_lazo_cerrado)
zero(T_lazo_cerrado)

%% 
% --- Datos planta (ejemplo) ---
s = tf('s');
Gp = 2/((s+2)*(s+5));

% --- Especificaciones ---
Mp = 0.10;
Ts_spec = 0.6;

% --- Cálculos objetivo ---
zeta = -log(Mp)/sqrt(pi^2 + (log(Mp))^2);
wn = 4/(zeta * Ts_spec);
sd = -zeta*wn + 1i*wn*sqrt(1-zeta^2);

fprintf('Objetivo: zeta=%.4f, wn=%.4f\n', zeta, wn);
fprintf('Polos deseados ~ %.4f %+.4fi\n', real(sd), imag(sd));

% --- Empezar diseño: proponemos un PI C(s) = K*(s+z)/s ---
% Elegí un z inicial (por ejemplo z=5 para que K no tenga que ser enorme)
z0 = 2;
C0 = tf([1 z0],[1 0]);   % controlador con K=1: (s+z0)/s

% --- Mirar rlocus del sistema en lazo abierto (con el cero del PI) ---
figure; rlocus(C0*Gp);
title('Lugar de raíces de L(s)=C(s)G_p(s) con z inicial');

% --- Interactivo: usar rlocfind para escoger K que coloque el polo cerca de sd ---
% (en la práctica movés el cursor sobre el lugar de raíces hasta acercarte a sd)
% [K, poles] = rlocfind(C0*Gp); % uncomment para usar interactivo

% --- Supongamos que elegimos un K obtenido por rlocfind (ejemplo) ---
% K = <valor que obtuviste con rlocfind>;
% C = K * C0;

% --- Si preferís una búsqueda programática: (búsqueda de K que minimice distancia al sd) ---
Ks = linspace(0.1,200,2000);
bestK = NaN; bestDist = Inf; bestPoles = [];
for Ki = Ks
    Ctemp = Ki * C0;
    L = Ctemp * Gp;
    CL = feedback(L,1);
    ps = pole(CL);
    % escoger el polo "dominante" más cercano a eje imaginario:
    % elegimos el que esté más cercano a sd en módulo
    [d,idx] = min(abs(ps - sd));
    if d < bestDist
        bestDist = d; bestK = Ki; bestPoles = ps;
    end
end
fprintf('K encontrado (búsqueda): %.4f, distancia a sd = %.4f\n', bestK, bestDist);

% --- Definir controlador final y lazo cerrado ---
C = bestK * C0;
L = C * Gp;
T = feedback(L,1);

% --- Comprobaciones ---
% Kv (constante de velocidad)
Kv = dcgain(s * L);    % alternativa: Kv = limit_{s->0} s*L(s)
fprintf('Kv = %.4f  (se requiere > 10)\n', Kv);

% Respuestas
t = 0:0.001:2; % ventana temporal (ajustar)
figure;
subplot(2,1,1); step(T, t); title('Respuesta al escalón (sistema controlado)');
grid on;
subplot(2,1,2);
r = t; % entrada rampa r(t)=t
[y, tt] = lsim(T, r, t);
plot(tt, y, 'b', tt, r, '--r'); title('Respuesta a la rampa: salida vs entrada');
legend('Salida', 'Entrada (rampa)');
grid on;

% Error a la rampa (valor teórico): e_ramp = 1/Kv
e_ramp = 1 / Kv;
fprintf('Error en régimen (rampa): e_ramp = %.4f (teórico)\n', e_ramp);
