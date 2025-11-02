%% Inicio Limpio

clc;        % Consola limpia
clear;      % Workspace limpio
close all;  % Cierra otras ventanas

s = tf('s');

Gs = 1 / (( s - 1 )*( s + 4 ))

H = 1;

%% Usando sisotool elijo un polo que cumpla

%   1) - Sobrepico M0 < 30%
%   2) - Tiempo de establecimiento Ts <= 2 seg
%   3) - 

% sisotool(Gs);

%% Calculo de Polo de Lazo Cerrado para la condicion limite

[pole1, pole2] = getPolosDominantes(30, 2);
disp(['Pooe 1: ', num2str(pole1)]);
disp(['Polo 2: ', num2str(pole2)]);

%% Pasar de la funcion trasnferencia al modelo de estado

num = 1;

aux = conv([1 -1],[1 4])

den = conv([1 0 ],aux) % Agrego un polo en cero para obetenr las posicion

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

PLC = [-3+5i; -3-5i; -30]

%% Formula de ackermann

K = acker(A, B ,PLC)

%% Ejecutar dsp de obtener el resultado de simulink

t = response.Time;
y = response.Data;       
info = stepinfo(y,t)

%         RiseTime: 0.2979
%     SettlingTime: 1.3774
%      SettlingMin: 0.9690
%      SettlingMax: 1.1480
%        Overshoot: 14.8037
%       Undershoot: 0
%             Peak: 1.1480
%         PeakTime: 0.6806


