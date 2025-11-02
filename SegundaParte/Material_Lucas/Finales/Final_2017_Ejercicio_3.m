%% Inicio Limpio

clc;        % Consola limpia
clear;      % Workspace limpio
close all;  % Cierra otras ventanas

s = tf('s');

Kmotor = 3 ;
Tmotor = 2;
TFmotor = Kmotor /( Tmotor * s + 1);

Kcinta = 1;
Tcinta = 4;
TFcinta = Kcinta / (Tcinta * s + 1);

Gs = TFmotor *( 1 / s ) *  TFcinta

H = 1;

%% Usando sisotool elijo un polo que cumpla

%   1) - Sobrepico M0 < 7%
%   2) - Tiempo de establecimiento Ts <= 30 seg
%   3) - Seguimiento a la rampa

% sisotool(Gs);

%% Calculo de Polo de Lazo Cerrado para la condicion limite

Mp = 7;
Ts = 20;

[pole1, pole2] = getPolosDominantes(Mp, Ts);
disp(['Pooe 1: ', num2str(pole1)]);
disp(['Polo 2: ', num2str(pole2)]);

%% Pasar de la funcion trasnferencia al modelo de estado

num = 3;

den = [8 6 1 0];

Gs = tf(num, den)

[A, B, C, D] = tf2ss(num, den)  %   Tf a modelo de estados

%% Matrices contolabilidad y observabilidad

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

%% Pasar de modelo de estado a funcion transferencia

PLC = [-0.5+0.2i; -0.5-0.2i ; -20]

%% Formula de ackermann

K = acker(A, B ,PLC)
