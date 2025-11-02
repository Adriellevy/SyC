%% Inicio Limpio

clc;        % Consola limpia
clear;      % Workspace limpio
close all;  % Cierra otras ventanas

s = tf('s');

Kmotor = 3 ;
Tmotor = 2;
TFmotor = Kmotor /( Tmotor * s + 1);

Kcinta = 1;
Tcinta = 8;
TFcinta = Kcinta / (Tcinta * s + 1);

Gs = TFmotor *( 1 / s ) *  TFcinta

H = 1;

%% Usando sisotool elijo un polo que cumpla

%   1) - Sobrepico M0 < 7%
%   2) - Tiempo de establecimiento Ts <= 20 seg
%   3) - Seguimiento a la rampa

% sisotool(Gs);

%% Calculo de Polo de Lazo Cerrado para la condicion limite

[pole1, pole2] = getPolosDominantes(7, 20);
disp(['Pooe 1: ', num2str(pole1)]);
disp(['Polo 2: ', num2str(pole2)]);

%% Pasar de la funcion trasnferencia al modelo de estado

num = 3;

den = [16 10 1 0]

Gs = tf(num, den)

[A, B, C, D] = tf2ss(num, den)  %   Tf a modelo de estados

[b, a] = ss2tf(A,B,C,D);

Gs1 = tf(b, a)

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

[b, a] = ss2tf(A,B,C,D);

PLC = [-0.5+0.25i; -0.5-0.25i ; -20]

%  Agrego un polo extra en -12 para que aumente el tipo del sistema

%% Formula de ackermann

K = acker(A, B ,PLC)

%   No entiendo porque no sigue a la rampa, si la planta ya es de tipo 1 al
%   tener un integrador en el medio ( CONSULTAR )
%   Tampoco tiene error nulo al escalon

%%  Subo el tipo del sistema (si subo el tipo de sistema si da)

PLC2 = [-0.6+0.5i; -0.6-0.5i ; -20 ; -60]

Ahat = [ A zeros(size(A,1),1); -C 0 ];

Bhat = [B ; 0];

ctr = [Bhat Ahat*Bhat Ahat*Ahat*Bhat Ahat*Ahat*Ahat*Bhat];

K = acker(Ahat, Bhat ,PLC2)
