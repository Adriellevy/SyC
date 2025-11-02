%% Inicio Limpio
clc;        % Consola limpia
clear;      % Workspace limpio
close all;  % Cierra otras ventanas

%% Transferencia
s = tf('s');
G = 6 / (s*(s+2));
H = 5 / (s+2);

M = feedback(G, H);
 pzmap(M);
% return

%% Respuesta al Escalón
set(figure(1),'name','Respuesta al escalón','menubar','figure');
% Error de Actuación y Verdadero
G_act = G*H;
M_act = feedback(G_act, 1);

step(tf(1), M_act, M);
legend('EscalÃ³n', 'f(t): Realimentación', 'c(t): Salida');

grid;

stepinfo(M)

%% Respuesta a la Rampa
set(figure(2),'name','Respuesta a la Rampa','menubar','figure');
% Error de Actuación y Verdadero
G_act = G*H;
M_act = feedback(G_act, 1);

step(tf(1/s), (M_act/s), (M/s));
legend('Escalón', 'f(t): Realimentación', 'c(t): Salida');

grid;

%% Orden de ventanas - Back to Front
figure(2);
figure(1);

stepinfo(M)
