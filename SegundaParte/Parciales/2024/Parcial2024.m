%% Parcial 2024
Gden = [1 4 8]; 
Gnum = [0 0 1]; 
%Controlado con un sistema PID (dos ceros y un polo para aumentar el tipo),
%debido a la division de la fase a compensar con dos 
G=tf(Gnum,Gden); 
PLA=pole(G);

%% Diseño por lugar de raices
PLC= polos_TS_MP(1,0.15); % Polos del sistema: p1 = -4.0000+6.6239j, p2 = -4.0000-6.6239j
PLCObjetivos=[PLC(1)-(1+1i*1.6239) PLC(2)-(1-1i*1.6239)]; %%%Los corrigo uno iz, uno derecha
%Este objeitvo es porque necesito hacer que el lugar de raices pase para
%cumplir las condiciones de diseño solicitadas.

FaseACompensar=faseCompensador(Gden,Gnum,PLCObjetivos(1)); %Condicion de fase da 220, la separo con dos ceros del PID


% === Fase a compensar (en grados) ===
FaseACompensar = faseCompensador(Gden, Gnum, PLCObjetivos(1));

% === Convertimos a radianes ===
FaseACompensarRad = deg2rad(FaseACompensar);

% === Distancia real que deben tener los ceros del PID ===
% Fórmula correcta usando tangente
DistanciaAlPoloPLC = imag(PLCObjetivos(1)) / tan( pi - FaseACompensarRad/2 );

% === Posición real donde ubicar los ceros ===
PosicionReal = real(PLCObjetivos(1)) + DistanciaAlPoloPLC;

s=tf('s');
Gc=(s-PosicionReal)^2/s;
GPlanta=simplify(G*Gc,'v'); 
% pzmap(GPlanta); 
rlocus(G*Gc); 
disenar_sistema(G,'Ts',1,'Mp',0.15,'Gc',Gc); %chequeo el sistema y me dan la figura con todos los resultados

% sisotool(G)
% zmap(G)
%TODO hacer funcion para calcularme fase necesaria
%ver de compensar con dos ceros en vez de cancelar singularidades por ahi. 
% Gc = k(s+3,97)^2/s; Raices de la clase
%% Diseño por raices 2da version

% GraficoAreasPosiblesMasSingularidades(1,0.15,G)
% Gc=(s-3)^2/s;
% disenar_sistema(G,'Ts',1,'Mp',0.15,'Gc',Gc);




%% Ejercicio 2
[num, den] = tfdata(G, 'v');  % 'v' devuelve vectores en lugar de celdas
% step(G)
[A,B,C,D] = tf2ss(num, den);
PLA =polos_TS_MP(1,0.15);
%Polos del sistema: p1 = -4.0000+6.6239j, p2 = -4.0000-6.6239j
PLC=[-5+1i*5; -5-1i*5]
Init_cond=0;


A=flip(fliplr(A));
B=flip(B);
C=fliplr(C);

k = acker(A,B,PLC);
kr = 1 / (C * inv(-A + B*k) * B);

Tiempo_Sim=10;
% === Ejecutar el modelo de Simulink ===
open_system('Control_Generico');  % opcional, para abrir la ventana
% simOut = sim('Generico_Retroalimentacion_Sin_Aumento_Tipo','ReturnWorkspaceOutputs','on');





