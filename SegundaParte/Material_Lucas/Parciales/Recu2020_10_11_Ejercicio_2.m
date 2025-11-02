%% Inicio Limpio

clc;        % Consola limpia
clear;      % Workspace limpio
close all;  % Cierra otras ventanas

s = tf('s');

wn = 2;

psi = 0.4;

K = 1;

Gs = (K * wn ^ 2)/( s ^ 2 + s * 2 * psi* wn + wn ^ 2 )

H = 1;

%% Usando sisotool elijo un polo que cumpla

%   1) - Sobrepico M0 < 12%
%   2) - Tiempo de establecimiento Ts <= 2 seg
%   3) - Capaz de seguir a la rampa, para error nulo al escalon

% sisotool(Gs);

%% Calculo de Polo de Lazo Cerrado para la condicion limite

[pole1, pole2] = getPolosDominantes(12, 2);
disp(['Pooe 1: ', num2str(pole1)]);
disp(['Polo 2: ', num2str(pole2)]);

%   Elijo usar el -2.5 +- 3i

%% Pasar de la funcion trasnferencia al modelo de estado

num = 4;

den = conv([1 +0.8+1.833i],[1 +0.8-1.833i])

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

PLC = [-2.5+3i; -2.5-3i ; -12]

%  Agrego un polo extra en -12 para que aumente el tipo del sistema

%% Formula de ackermann

Ahat = [ A zeros(size(A,1),1); -C 0 ]

Bhat = [B ; 0]

ctr = [Bhat Ahat*Bhat Ahat*Ahat*Bhat Ahat*Ahat*Ahat*Bhat]

K = acker(Ahat, Bhat ,PLC)
