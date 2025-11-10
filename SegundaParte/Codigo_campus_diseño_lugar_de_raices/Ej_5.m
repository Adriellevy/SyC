%% Inicio Limpio
clc;        % Consola limpia
clear;      % Workspace limpio
close all;  % Cierra otras ventanas

%% Constantes útiles
% Variable de Laplace
s = tf('s');

%% Transferencia de la planta
Gp = 10 / ( s * (s+2) * (s+5) );
Gc = 1;
H  = 1;

TLA = Gp * Gc * H;
M = feedback(Gp*Gc, H);

Kc_values = linspace(0, 200, 2000);
% rlocus(TLA, Kc_values);

%% Compensación 1 (de prueba) - RAF
PLC = [-2+1i*2*sqrt(3), -2-1i*2*sqrt(3)];
getAngACompensar(PLC(1), zero(TLA), pole(TLA))

Zc1 = -2;
Pc1 = -20;
Gc1 = (s - Zc1) / (s - Pc1);

TLA = Gc1 * Gp * H;
Kc_values = linspace(30, 40, 500);
rlocus(TLA, Kc_values);
Kc1 = 33.6;
Gc1 = Kc1 * Gc1;

%% Compensación 2 (de prueba) - RRF
Pc2 = -1 / 1000;
Zc2 = -2 / 1000;
Gc2 = (s - Zc2) / (s - Pc2);

TLA = Gc2 * Gc1 * Gp * H;

figure(1);
rlocus(TLA, Kc_values);

%% Compensación 3 (final)
Pc2 = -1 / 1000;
Zc2 = -5.97 / 1000;
Gc2 = (s - Zc2) / (s - Pc2);

Gc = Gc1 * Gc2;

TLA = Gc * Gp * H;

figure(1);
rlocus(TLA, Kc_values);

figure(2);
Kc = 1;
M2 = feedback(Kc * Gc * Gp, H);
pzmap(M2);

figure(3);
Kc = 1;
M2 = feedback(Kc * Gc * Gp, H);
step(1/s - M/s, 1/s-M2/s);
hold on
xlim([0 1000]);
legend('Error a la Rampa 1', 'Error a la Rampa 2');
hold off

figure(2);
figure(1);
