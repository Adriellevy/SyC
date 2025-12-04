%% 
sys_cl = feedback(1130*Gsimplificada, 1);   % sistema en lazo cerrado
sysss = ss(sys_cl); % A, B, C, D
sysss_comp = canon(sysss, 'companion'); %Lo paso a formato canonico
% [A2, B2, C2, D2] = ssdata(sysss_comp)
% A2=A2';
% B2=B2;
% C2=C2;
% D2=D2;
% Tiempo de simulación (ajusta duración y dt si quieres)
tfinal = 15;
dt = 0.01;
t = 0:dt:tfinal;

% Entrada escalón unitario
u = ones(size(t));

% ---- CONDICIONES INICIALES (ejemplo) ----
% Como Gs es de orden 3 (por tu planta), el ss tendrá 3 estados.
% Prueba varios sets; aquí pongo un ejemplo:
x0 = [1; 0; 0];    % condiciones iniciales en el espacio de estados
% Explica: usé un desplazamiento positivo en el 1er estado, negativo en el 2do y pequeño en el 3ro.
% Puedes cambiar a x0 = [1;0;0], x0 = [0;0;0] (para comparar), etc.

% Simular respuesta al escalón con condiciones iniciales:
[y, t_out, x] = lsim(sysss_comp, u, t, x0);

% Calcular error respecto al escalón unitario
% e = u - y;

% Graficar resultado (salida y error)
figure;
% subplot(2,1,1);
plot(t_out, y, 'LineWidth', 1.2);
grid on;
xlabel('t (s)');
ylabel('y(t)');
title('Respuesta al escalón del sistema en lazo cerrado (condiciones iniciales no nulas)');
legend(sprintf('x0 = [%g, %g, %g]', x0(1), x0(2), x0(3)), 'Location','best');