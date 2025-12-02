s =tf('s');

Gplanta=3/((s+10)*(s+1)*(s+5));
% GraficoAreasPosiblesMasSingularidades(2.5,0.1,Gplanta); 
Gplanta_con_polo_cancelado=3/((s+10)*(s+5));
Denplanata_con_polo_cancelado=[1 15 50];
Numplanata_con_polo_cancelado=[0 0 3];
%%
PLCObjetivos=(-7+j*5);
FaseACompensar=faseCompensador(Numplanata_con_polo_cancelado,Denplanata_con_polo_cancelado,PLCObjetivos,'polo')
FaseACompensarRad = deg2rad(FaseACompensar);
DistanciaAlPoloPLCObjetivo = imag(PLCObjetivos(1)) / tan(pi - FaseACompensarRad )
%La distancia de los PLC obejtivos es de 1.815 es distinta a la distancia
%obtenida por paula

% === Posición real donde ubicar los ceros ===
PosicionReal = real(PLCObjetivos(1)) + DistanciaAlPoloPLCObjetivo

Gcontrol=343*(s+1)/(s-PosicionReal); 
Gtot=minreal(Gcontrol*Gplanta);
rlocus(Gtot);
% step(feedback(Gtot,1))
% disenar_sistema(Gplanta,'Ts',2.5,'Mp',0.10,'Gc',Gcontrol); %chequeo el sistema y me dan la figura con todos los resultados
%% Ejercicio 2
Gcontrol=(s+1)/s;
disenar_sistema(Gplanta,'Ts',2,'Mp',0.10,'Gc',Gcontrol);