clear; 
clc; 
close all;  % Cierra otras ventanas

s = tf('s');

Gs = 3/((2*s+1)*(4*s+1));

H = 1;

%%
GraficoAreasPosiblesMasSingularidades(30,7,Gs)
%% Propongo un compensador de adelanto de fase
Gc=(s+1/4)/s; 
rlocus(Gc*Gs)
%%
G_simplificada = minreal(Gc*Gs);
Ms=feedback(G_simplificada,1);
figure(1)
step(feedback(G_simplificada,1))

% --- RESPUESTA A LA RAMPA ---
t = 0:0.01:30;   % vector de tiempo
r = t;           % señal rampa

% calcular respuesta
y = lsim(Ms, r, t);

% graficar
figure(2);
plot(t, y, 'LineWidth', 2);
hold on;
plot(t, r, '--', 'LineWidth', 1.2);
legend('Salida y(t)', 'Entrada r(t)=t');  
%% Ackerman 
[A,B,C,D] = tf2ss([0 0 3],[8 6 1]);

Ahat = [ A zeros(size(A,1),1); -C 0 ];

Bhat = [B ; 0];

ctr = [Bhat Ahat*Bhat Ahat*Ahat*Bhat Ahat*Ahat*Ahat*Bhat];

PLC=[-0.25+i*0.24;-0.25-i*0.24; -2]
K = acker(Ahat, Bhat ,PLC);
