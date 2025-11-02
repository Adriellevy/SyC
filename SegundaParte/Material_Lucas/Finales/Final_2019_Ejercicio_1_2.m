%% Inicio Limpio

clc;        % Consola limpia
clear;      % Workspace limpio
close all;  % Cierra otras ventanas

s = tf('s');

Tm = 3 / ( s * ( 2 * s + 1 ))

Tc = 1 / ( 8 * s + 1 )

Gs = Tm * Tc

H = 1;

%% Usando sisotool elijo un polo que cumpla

%   1) - Sobrepico M0 < 7%
%   2) - Tiempo de establecimiento Ts <= 20 seg
%   3) - Seguimiento a la rampa

sisotool(Gs);

[pole1, pole2] = getPolosDominantes(7, 20);
disp(['Polo 1: ', num2str(pole1)]);
disp(['Polo 2: ', num2str(pole2)]);

%% Controlador ( PD ) ( solucion mas facil )

Kc = 0.623

Gc = ( s + 0.125 )


%%  Respuesta al escalon

Ms = feedback(Kc * Gc * Gs,H,-1)
H3 = figure(3);
tstep = linspace(0,20,100000);
step(Ms,tstep);grid;
stepinfo(Ms)

%%  Respuesta a la rampa

H4 = figure(4);
tstep = linspace(0,20,100000);
step(Ms/s,1/s,tstep);grid;

%%  Error a la rampa

tstep = linspace(0,30,100000);
[y_res] = step(Ms/s,tstep);
[y_ramp,tOut] = step(1/s,tstep);
H5 = figure(5);
plot(tOut, y_ramp -y_res);
grid;
