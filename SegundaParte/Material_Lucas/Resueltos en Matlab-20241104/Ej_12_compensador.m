%% Inicio Limpio
clc;        % Consola limpia
clear;      % Workspace limpio
close all;  % Cierra otras ventanas

%% Constantes útiles
% Variable de Laplace
s = tf('s');

%% Transferencias del sistema
Gp = 5 / ((s^2 - 2*s +2) * (s + 10));
Gc = 1;
H  = 1;

TLA = Gp * Gc * H;

figure(1)
Kc_values = linspace(0, 200, 2000);
rlocus(TLA, Kc_values);

%% Calculos auxiliares
fact_am = 0.5;
ang = acos(fact_am);
im_re = tan(ang);

plc_re = -2;
plc_im = (-plc_re) * im_re;

%% Compensador (RAF doble)
PLC = [plc_re + 1i * plc_im, plc_re - 1i * plc_im];

getAngACompensar(PLC(1), zero(TLA), pole(TLA))

Zc = -4;
Pc = -34.84;
Kc = 1;
Gc = Kc * (s-Zc)^2 / (s-Pc)^2;
% pzmap(Gc);

TLA = Gc * Gp;
figure(2)
Kc_values = linspace(0, 4000, 5000);
% Kc_values = linspace(2000, 4000, 5000);
rlocus(TLA, Kc_values);


%% Verificación
figure(3)
Kc = 2480;
M = feedback(Kc * Gc * Gp, H);
pzmap(M);

figure(4);
t = linspace(0, 5, 100);
step(tf(1), M, t);

figure(4);
figure(3);
figure(2);
figure(1);
