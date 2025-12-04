clear; 
clc; 
close all;  % Cierra otras ventanas

s = tf('s');

Gs = 3/(s*(2*s+1)*(4*s+1));

H = 1;

%%
GraficoAreasPosiblesMasSingularidades(30,7,Gs)
%% Propongo un compensador de adelanto de fase
Gc=(s+1/4)/(s+10); 
rlocus(minreal(Gs*Gc))
%%
G_simplificada = 2.79*minreal(Gc*Gs);
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
[A,B,C,D] = tf2ss([0 0 0 3/8],[1 0.75 1/8 0]);
[num,den]=ss2tf(A,B,C,D);
% Ahat = [ A zeros(size(A,1),1); -C 0 ];
 
% Bhat = [B ; 0];

% ctr = [Bhat Ahat*Bhat Ahat*Ahat*Bhat Ahat*Ahat*Ahat*Bhat];


PLC=[-0.24+i*0.27;-0.24-i*0.27; -30]
K = acker(A, B, PLC);
% calcula Nbar (para D = 0, SISO)
kfinal = -1 / ( C * inv(A - B*K) * B );   % escalar referencia

K=[K kfinal];
Init_cond=[0 0 0];


n = size(A,1);
Co = ctrb(A,B);
rankCo = rank(Co);
fprintf('Orden del sistema n = %d, rango de la matriz de controlabilidad = %d\n', n, rankCo);
if rankCo < n
    error('El sistema NO es completamente controlable. No puedes colocar todos los polos.');
end
