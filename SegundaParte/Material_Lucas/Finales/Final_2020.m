%% Inicio Limpio

clc;        % Consola limpia
clear;      % Workspace limpio
close all;  % Cierra otras ventanas

s = tf('s');

%   Transductor de Velocidad Angular

disp('Transductor de Velocidad Angular')

Gtva = 1 %  Es mi realimentacion es l H(s) ( es una constante )

%   Valvula de control de vapor

disp('Valvula de control de vapor')

Gvcv = 10^( 10 / 20 ) /( s + 0.1 )

%   Turbina de vapor

disp('Turbina de vapor')

Gtv = 10^( 3 / 20 ) /( s + 0.01 )

%   Actuador

disp('Actuador')

Gact = 10^( 15 / 20 ) /(( s + 0.5 )*( s + 2 ))

disp('Planta G(s)')

Gs = Gvcv * Gtv * Gact


%%  Ejercicio 3 diseño de controlador ( SISOTOOL )

%   Utilizo un controlador PID para cancelar los dos polos mas lentos de mi
%   sistema

Gc = ( s + 0.1 )*( s + 0.01 )/ s

%   Con rlocus determino mi ganancia Kc en 0.01

Kc = 0.01

%%  Ejercicio 4 respuesta al escalon y respuesta a la rampa

disp('Funcion transferencia del sistema realimentado con PID')
Ms = feedback(Kc * Gc * Gs,Gtva,-1)
H5 = figure(5);
tstep = linspace(0,30,100000);
step(Ms,tstep);grid;
disp('Respuesta del sistema utilizando un PID')
stepinfo(Ms)
H6 = figure(6);
tstep = linspace(0,30,100000);
step(Ms/s,1/s,tstep);grid;

%%  Ejercicio 5 metodo de asignacion de polos ( elimino la realimentacion )

disp('Metodo de asignacion de polos')

num = 25.12;

den = [1 2.61 1.276 0.1125 0.001];

[A,B,C,D] = tf2ss(num,den)

% Matrices contolabilidad y observabilidad

Co = ctrb(A,B);  %   Matriz Controlabilidad
Ob = obsv(A,C);  %   Matriz Observabilidad

n = size(A,1);

% Verifico Controlabilidad del sistema

if rank(ctrb(A,B)) == n
    disp('El sistema es Controlable.');
else
    error('El sistema NO es Controlable');
end

% Verifico Observabilidad del sistema

if rank(obsv(A,C)) == n
    disp('El sistema es Observable.');
else
    error('El sistema NO es Observable');
end

% Calculo de Polo de Lazo Cerrado para la condicion limite

fact_am = 0.6;

M0 = exp((-fact_am * pi())/(sqrt( 1 - fact_am ^ 2)))

[pole1, pole2] = getPolosDominantes(M0 * 100, 20);
disp(['Pooe 1: ', num2str(pole1)]);
disp(['Polo 2: ', num2str(pole2)]);

% Agrego un polo mas porque necesito error nulo al escalon, entoces le subo
% el tipo al sistema, entonces necesito calcular Ahat y Bhat

PLC = [-0.2+0.25i; -0.2-0.25i ; -40 ; -45 ; -50]

Ahat = [ A zeros(size(A,1),1); -C 0 ];

Bhat = [B ; 0];

ctr = [Bhat Ahat*Bhat Ahat*Ahat*Bhat Ahat*Ahat*Ahat*Bhat];

K = acker(Ahat, Bhat ,PLC)

%   Ejecutar dsp de obtener el resultado de simulink

t = response.Time;
y = response.Data;       
info = stepinfo(y,t);
H1 = figure(1);
plot(t,y);grid;
disp(info);

%   Step info de la respuesta de simulink obtenidos con un tiempo de
%   analisis de 40 segundos
%
%         RiseTime: 5.9880
%     SettlingTime: 18.7099
%      SettlingMin: 0.9015
%      SettlingMax: 1.0810
%        Overshoot: 8.0526
%       Undershoot: 0
%             Peak: 1.0810
%         PeakTime: 12.6611
%
%   Se cumple con el settingTime
%   Se cumple con el overshoot
%   Se cumple con error a la escalon nulo

