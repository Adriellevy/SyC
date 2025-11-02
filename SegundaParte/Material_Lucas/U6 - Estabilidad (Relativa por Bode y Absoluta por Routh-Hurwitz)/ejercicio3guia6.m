%% Inicio Limpio
clc;        % Consola limpia
clear;      % Workspace limpio
close all;  % Cierra otras ventanas

s = tf('s');

G = (s + 2.5)/((s^2 + 2*s + 2).*(s^2 + 4*s + 5));
H = 1;

%% Analizo el lugar de raices de la "transferencia de Lazo Abierto"

H1 = figure(1);
set(H1,'NumberTitle','off','name','Lugar de Raices');
rlocus( G * H );
hold on;
% rlocus( -G * H ); % graficar el lugar de raices completo
grid;
hold off;

% no se puede encontrar un valor de k tal que el factor de amortiguamiento
% de 0.707 porque K = 0 para que esto se cumpla

% si elijo un k muy chico tampoco puedo hacerlo porque los polos quedan
% demasiado cerca y no se pueden despreciar ( el factor de amortiguamiento
% solo tiene sentido en sistemas con 2 polos )

%% Respuesta al escalon con k

H2 = figure(2);

set(H2,'NumberTitle','off','name','Respuesta al escalon con k = 1.42');
k = 1.42; % sistema 
sys = feedback(k*G,H,-1)
step(sys);grid;
title('Respuesta al escalon con k = 1');
