%% Inicio Limpio
clc;        % Consola limpia
clear;      % Workspace limpio
close all;  % Cierra otras ventanas

%% Transferencia
s = tf('s');
G = (s+1) / (s^2 + 2*s + 1);
H = 4 / (s+4);

M = feedback(G, H);
pzmap(M);
grid;
% return

%% Respuesta al Escalón
set(figure(1),'name','Respuesta al escalón','menubar','figure');
% Error de Actuación y Verdadero
G_act = G*H;
M_act = feedback(G_act, 1);

step(tf(1), M_act, M);
legend('Escalón', 'f(t): Realimentación', 'c(t): Salida');

grid;

stepinfo(M);

%% Orden de ventanas - Back to Front
figure(1);

stepinfo(M)
