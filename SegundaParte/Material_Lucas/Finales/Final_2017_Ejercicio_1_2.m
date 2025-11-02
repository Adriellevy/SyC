%% Inicio Limpio

clc;        % Consola limpia
clear;      % Workspace limpio
close all;  % Cierra otras ventanas

s = tf('s');

Kmotor = 3 ;
Tmotor = 2;
TFmotor = Kmotor /( Tmotor * s + 1 );

Kcinta = 1;
Tcinta = 4;
TFcinta = Kcinta / (Tcinta * s + 1) ;

Gs = TFmotor *( 1 / s ) *  TFcinta

H = 1;

%% Usando sisotool elijo un polo que cumpla

%   1) - Sobrepico M0 < 7%
%   2) - Tiempo de establecimiento Ts <= 30 seg
%   3) - Seguimiento a la rampa

% sisotool(Gs);

%% Calculo de Polo de Lazo Cerrado para la condicion limite

Mp = 7;
Ts = 30;

[pole1, pole2] = getPolosDominantes(Mp, Ts);
disp(['Pooe 1: ', num2str(pole1)]);
disp(['Polo 2: ', num2str(pole2)]);

%% Controlador ( PD )

Kc = 0.33;

Gc = ( s + 0.25 );

%%  Respuestas del sistema

Ms = feedback(Kc * Gc * Gs,1,-1)

opt = stepDataOptions('StepAmplitude',1);

tstep = linspace(0,30,100000);

% Respuesta al escalon

H5 = figure(5);
step(Ms,tstep,opt);grid;
title('Respuesta al escalon');
stepinfo(Ms)

% Respuesta a la rampa

H6 = figure(6);
step(Ms/s,1/s,tstep,opt);grid;
title('Respuesta a la rampa');

%% Errores

% Error al escalon

[y_res, tOut] = step(Ms,tstep);
y_esc = ones(size(tOut));
error_escalon = y_esc - y_res;
H8 = figure(8);
plot(tOut, error_escalon);
xlabel('Time (seconds)') 
ylabel('Amplitude') 
title('Error al escalon');
grid;

%  Error a la rampa

[y_res] = step(Ms/s,tstep);
[y_ramp,tOut] = step(1/s,tstep);
H9 = figure(9);
plot(tOut, y_ramp -y_res);
xlabel('Time (seconds)') 
ylabel('Amplitude') 
title('Error a la rampa')
grid;
