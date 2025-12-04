% Pero primero tengo que pasarlo a Modelo de estados. 

[num, den] = tfdata(feedback(minreal(1130*Gs*Gc1*Gc2),1), 'v');  % 'v' devuelve vectores en lugar de celdas
% step(G)
[A,B,C,D] = tf2ss(num, den);
% 
% A=flip(fliplr(A));
% B=flip(B);
% C=fliplr(C);

% K = acker(A,B,[PLCObjetivos' -15]);
% K = [K 1] %Le agrego al final un valor para que no se rompa
K=[1 1 1 1];
% kr = 1 / (C * inv(-A + B*k) * B);
% n = size(A,1);
% Co = ctrb(A,B);
% rankCo = rank(Co);
% fprintf('Orden del sistema n = %d, rango de la matriz de controlabilidad = %d\n', n, rankCo);
% if rankCo < n
%     error('El sistema NO es completamente controlable. No puedes colocar todos los polos.');
% end
Init_cond=[0 0 0];
Tiempo_Sim=1;

% === Ejecutar el modelo de Simulink ===
open_system('Sistema_Seguimiento_Con_Planta_Tipo_0');  % opcional, para abrir la ventana
% simOut = sim('Generico_Retroalimentacion_Sin_Aumento_Tipo','ReturnWorkspaceOutputs','on');