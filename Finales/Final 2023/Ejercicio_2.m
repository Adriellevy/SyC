clc;        % Consola limpia
clear;      % Workspace limpio
close all;  % Cierra otras ventanas

Gden = [1 12 40 64]; 
Gnum = [0 0 0 1]; 
G=tf(Gnum,Gden); 
PLA=pole(G); 


s=tf('s');

%% Usando sisotool elijo un polo que cumpla

%   1) - Sobrepico M0 < 15%
%   2) - Tiempo de establecimiento Ts <= 1 seg
%   3) - Capaz de seguir a la rampa, para error nulo al escalon

% sisotool(Gs);

%% Calculo de Polo de Lazo Cerrado para la condicion limite

[polos] = polos_TS_MP(1.5,0.1)
disp(['Polo 1: ', num2str(polos(1))]);
disp(['Polo 2: ', num2str(polos(2))]);

%   Elijo usar el -2.5 +- 3i

%% Pasar de la funcion trasnferencia al modelo de estado
[A, B, C, D] = tf2ss(Gnum, Gden)  %   Tf a modelo de estados

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

PLC = [polos(1); polos(2) ; -30; -40]

%  Agrego un polo extra en -12 para que aumente el tipo del sistema

%% Formula de ackermann

Ahat = [ A zeros(size(A,1),1); -C 0 ]

Bhat = [B ; 0]

ctr = [Bhat Ahat*Bhat Ahat*Ahat*Bhat Ahat*Ahat*Ahat*Bhat];

K = acker(Ahat, Bhat ,PLC)

%% Resultado - ( dsp del simulink)

t = response.Time;
y = response.Data;       
info = stepinfo(y,t);
H1 = figure(1);
plot(t,y);grid;
disp(info); % Mostrar los resultados
