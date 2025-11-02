%% Inicio Limpio

clc;        % Consola limpia
clear;      % Workspace limpio
close all;  % Cierra otras ventanas

s = tf('s');

Gs = 0.4 / ( s ^ 3 + 0.3 * s ^ 2 - 0.9 * s - 0.4)

H = 1;

sisotool(Gs);

p = [1 0.3 -0.9 -0.4];
r = roots(p)

%% Usando sisotool elijo un polo que cumpla

%   1) - Sobrepico M0 < 4% 
%   2) - Tiempo de establecimiento Ts <= 1 seg


% Gc = (( s + 0.8)*( s + 0.5 ))/(( s + 7)*( s + 4))
% 
% %sisotool(Gs,Gc);
% % 
% Kc = 100;
% 
% Ms = feedback(Kc * Gc * Gs, H , -1 );
% 
% sisotool(Gs , Gc);
% step(Ms);
% stepinfo(Ms)


%% Calculo de Polo de Lazo Cerrado para la condicion limite

[pole1, pole2] = getPolosDominantes(4, 1);
disp(['Pooe 1: ', num2str(pole1)]);
disp(['Polo 2: ', num2str(pole2)]);

%% Pasar de la funcion trasnferencia al modelo de estado

num = 0.4;

den = [1 0.3 -0.9 -0.4]

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

[b, a] = ss2tf(A,B,C,D);

PLC = [-3+4i; -3-4i ; -20]

%  Agrego un polo extra en -12 para que aumente el tipo del sistema

%% Formula de ackermann

K = acker(A, B ,PLC)
