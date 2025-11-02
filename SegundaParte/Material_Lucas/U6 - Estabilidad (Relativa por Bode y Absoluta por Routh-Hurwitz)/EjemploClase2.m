%% Inicio Limpio

clc;        % Consola limpia
clear;      % Workspace limpio
close all;  % Cierra otras ventanas

s = tf('s');

G = 1 /(( s + 3 )*( s + 5 )*( s + 10 ));
H = 1;

% ts = 1
% m0 = 5%
  sisotool(G)

% Usando sisotool defino polo en Defino el polo en -5 + j 5, este polo
% cumple con las codiciones minimas pedidas

%% Calculo de Polo de Lazo Cerrado para la condicion limite

[pole1, pole2] = getPolosDominantes(5, 1);
disp(['Pole 1: ', num2str(pole1)]);
disp(['Pole 2: ', num2str(pole2)]);

%% Utilizo PID

Gc = 50*(s + 5)*( s + 3)/s

Ms = feedback(G * Gc,H,-1);

stepinfo(Ms)

H1 = figure(1);
step(Ms);grid;

H2 = figure(2);
set(H2,'NumberTitle','off','name','6)- Respuesta a la rampa');

% Definir el tiempo y la entrada de la rampa
t = 0:0.01:2; % Ajusta el tiempo según sea necesario
rampa = t; % La entrada es una función rampa (r(t) = t)

% Graficar la respuesta a la rampa
lsim(Ms, rampa, t);
grid on;
title('Respuesta a la Rampa');
xlabel('Tiempo (s)');
ylabel('Respuesta del Sistema');


