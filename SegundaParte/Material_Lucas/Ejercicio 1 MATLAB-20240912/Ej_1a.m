%% Inicio Limpio
clc;        % Consola limpia
clear;      % Workspace limpio
close all;  % Cierra otras ventanas

%% Transferencia
s = tf('s');
G = 6 / (s+1);
H = 1;

M = feedback(G, H);
% pzmap(M);
% return

%% Respuesta al Escalón
set(figure(1),'name','Respuesta al escalón','menubar','figure');
step(tf(1), M);
legend('Escalón', 'Respuesta al escalón');
grid;

%% Respuesta a la Rampa
set(figure(2),'name','Respuesta a la Rampa','menubar','figure');
step(tf(1/s), (M/s));
legend('Rampa', 'Respuesta a la Rampa');
grid;

%% Orden de ventanas - Back to Front
figure(2);
figure(1);

stepinfo(M)
