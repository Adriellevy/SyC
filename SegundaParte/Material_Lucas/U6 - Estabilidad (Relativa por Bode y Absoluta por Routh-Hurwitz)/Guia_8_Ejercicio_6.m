%% Inicio Limpio
clc;        % Consola limpia
clear;      % Workspace limpio
close all;  % Cierra otras ventanas

s = tf('s');

G = 10 /(s*s + 2);
H = 1;

%% Calculo de Polo de Lazo Cerrado para la condicion limite

[pole1, pole2] = getPolosDominantes(40, 5);
disp(['Pole 1: ', num2str(pole1)]);
disp(['Pole 2: ', num2str(pole2)]);

%% Sisotool a elijo el polo de lazo cerrado

%sisotool(G)

%   Polo de lazo cerrado en = 2 +- 3.5i

%%   Calculo del angulo de compenzacion

PLC_real = -2.46;       %   Polo de Lazo Cerrado
PLC_imaginario = 3.7;   %   Polo de Lazo Cerrado

PoloLazoCerrado = PLC_real + PLC_imaginario *1i; %   Polo de Lazo Cerrado

PolosGs = pole(G);              %   Polos de Gs
ZerosGs = zero(G);              %   Zeros de Gs

[ang_a_compensar] = getAngACompensar(PoloLazoCerrado, ZerosGs, PolosGs)

%   Elijo poner un zero en -3

ZeroFijo = 3;
  
angzero =  atand(PLC_imaginario /  ( ZeroFijo + PLC_real ));
AngPolo = ang_a_compensar + angzero;
Pc = PLC_real - (PLC_imaginario / tand(AngPolo))

%% Busco el valor de K

Gc = (s + ZeroFijo) / ( s - Pc);

H4 = figure(4);
V_AUX = linspace(0,50,1000);
rlocus(G * Gc, V_AUX);grid;

K = 12.4

%% Respuesta al escalon Unitario y Sisotool

sisotool( G, K * Gc );

H5 = figure(5);
set(H5,'NumberTitle','off','name','5)- Respuesta al escalon');
Ms = feedback(K * Gc * G,H,-1);
step(Ms);grid;
title('Respuesta al escalon');
stepinfo(Ms)

