%% Inicio Limpio

clc;        % Consola limpia
clear;      % Workspace limpio
close all;  % Cierra otras ventanas

s = tf('s');

Gs = 1 / ( s ^ 2+ s * 4 + 8);
H = 1;

%% Calculo de Polo de Lazo Cerrado para la condicion limite

[pole1, pole2] = getPolosDominantes(5, 0.3);
disp(['Polo 1: ', num2str(pole1)]);
disp(['Polo 2: ', num2str(pole2)]);

%% Pasar de la funcion trasnferencia al modelo de estado

num = 1;

den = conv([1 2+2i],[1 2-2i])

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

PLC = [-14.5+14i; -14.5-14i]

%% Formula de ackermann

K = acker(A, B ,PLC)

%% Resultado - ( dsp del simulink)

t = response.Time ;
y = response.Data;       
info = stepinfo(y,t);
plot(t,y);
disp(info); % Mostrar los resultados

% Error al escalon de simulink con los cursores da : 1.96e-02
