%% Inicio Limpio

clc;        % Consola limpia
clear;      % Workspace limpio
close all;  % Cierra otras ventanas

s = tf('s');

Gs = 1 / ( s ^ 2+ s * 8);
H = 1;

%% Usando sisotool elijo un polo que cumpla

%   1) - Sobrepico M0 < 10%
%   2) - Tiempo de establecimiento Ts <= 0.5 seg
%   3) - Capaz de seguir a la rampa

%sisotool(Gs);

%% Calculo de Polo de Lazo Cerrado para la condicion limite

[pole1, pole2] = getPolosDominantes(10, 0.5);
disp(['Polo 1: ', num2str(pole1)]);
disp(['Polo 2: ', num2str(pole2)]);

%% Pasar de la funcion trasnferencia al modelo de estado

num = 1;

den = conv([1 0],[1 8])

Gs = tf(num, den)

[A, B, C, D] = tf2ss(num, den)  %   Tf a modelo de estados

[b, a] = ss2tf(A,B,C,D);

Gs1 = tf(b, a)

%% Matrices contolabilidad y observabilidad

Co = ctrb(A,B)  %   Matriz Controlabilidad
Ob = obsv(A,C)  %   Matriz Observabilidad

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

[b, a] = ss2tf(A,B,C,D);

PLC = [-8.5+10i; -8.5-10i];

%  Agrego un polo extra en -12 para que aumente el tipo del sistema

%% Formula de ackermann

K = acker(A, B ,PLC)

%   De simulink error a la rampa de 0.26 = 26%
