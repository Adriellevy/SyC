%% Ejemplo N°1
[num, den] = tfdata(feedback(minreal(1130*Gs*Gc1*Gc2),1), 'v');  % 'v' devuelve vectores en lugar de celdas
% step(G)
[A,B,C,D] = tf2ss(num, den);
% 
A=flip(fliplr(A));
B=flip(B);
C=fliplr(C);

K = acker(A,B,[PLCObjetivos' -15]);
K = [K 1] %Le agrego al final un valor para que no se rompa
% kr = 1 / (C * inv(-A + B*k) * B);
% n = size(A,1);
% Co = ctrb(A,B);
% rankCo = rank(Co);
% fprintf('Orden del sistema n = %d, rango de la matriz de controlabilidad = %d\n', n, rankCo);
% if rankCo < n
%     error('El sistema NO es completamente controlable. No puedes colocar todos los polos.');
% end
Init_cond=0.05;
Tiempo_Sim=1;

% === Ejecutar el modelo de Simulink ===
open_system('Sistema_Seguimiento_Con_Planta_Tipo_0');  % opcional, para abrir la ventana
%% Ejemplo N°2
[A,B,C,D] = tf2ss([0 0 0 3/8],[1 0.75 1/8 0]);
[num,den]=ss2tf(A,B,C,D);
% Ahat = [ A zeros(size(A,1),1); -C 0 ];
 
% Bhat = [B ; 0];

% ctr = [Bhat Ahat*Bhat Ahat*Ahat*Bhat Ahat*Ahat*Ahat*Bhat];


PLC=[-0.24+i*0.27;-0.24-i*0.27; -30]
K = acker(A, B, PLC);
% calcula Nbar (para D = 0, SISO)
% kfinal = -1 / ( C * inv(A - B*K) * B );   % escalar referencia evuar si es necesaria
kfinal=1;
K=[K kfinal];
Init_cond=[0 0 0];


n = size(A,1);
Co = ctrb(A,B);
rankCo = rank(Co);
fprintf('Orden del sistema n = %d, rango de la matriz de controlabilidad = %d\n', n, rankCo);
if rankCo < n
    error('El sistema NO es completamente controlable. No puedes colocar todos los polos.');
end
% Matriz de observabilidad
Ob = obsv(A,C);

% Rango
rankOb = rank(Ob);

fprintf('Orden del sistema n = %d, rango de la matriz de observabilidad = %d\n', n, rankOb);

if rankOb < n
    error('El sistema NO es completamente observable.');
else
    disp('El sistema SI es completamente observable.');
end