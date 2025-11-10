%% Inicio Limpio
clc;        % Consola limpia
clear;      % Workspace limpio
close all;  % Cierra otras ventanas

%% Constantes útiles
% Variable de Laplace
s = tf('s');

%% Transferencia de la planta original
Gp = 16 / ( s * (s+4) );
Gc = 1;
H  = 1;

TLA = Gc * Gp * H;
M = feedback(Gp, H);

figure(1);
Kc_values = [
    linspace(0, 0.01, 2e3), ...
    linspace(0.01, 2.45, 1e3), ...
    linspace(2.45, 2.55, 2e3), ...
    linspace(2.55, 10, 1e3) ...
];
rlocus(TLA, Kc_values);

figure(2);
step(1/s - M/s);
hold on
xlim([0 20]);
legend('Error a la Rampa 1');
hold off

figure(2);
figure(1);

%% Compensación 1 (de prueba) RRF
PLC = [-2+1i*2*sqrt(3), -2-1i*2*sqrt(3)];
angulo_a_compensar = getAngACompensar(PLC(1), zero(TLA), pole(TLA))

Pc = -1 / 1000;
Zc = -2 / 1000;
Gc = (s - Zc) / (s - Pc);

TLA = Gc * Gp * H;

rlocus(TLA, Kc_values);

%% Compensación 2 (final) RRF
Pc = -1 / 1000;
Zc = -5 / 1000;
Gc = (s - Zc) / (s - Pc);

TLA = Gc * Gp * H;

figure(1);
rlocus(TLA, Kc_values);

figure(2);
Kc = 1;
M2 = feedback(Kc * Gc * Gp, H);
pzmap(M2);

figure(3);
step(1/s - M/s, 1/s-M2/s);
hold on
xlim([0 1000]);
legend('Error a la Rampa 1', 'Error a la Rampa 2');
hold off

%% Orden de ventanas
figure(3);
figure(2);
figure(1);


