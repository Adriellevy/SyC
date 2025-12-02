s = tf('s'); 

den = [1 4 8]; 
num = [0 0 1]; 
Gplanta= tf(num,den);
roots(den)
%% Diseño por lugar de raices
PLC= polos_TS_MP(1,0.15);

% GraficoAreasPosiblesMasSingularidades(1,.15,Gplanta); 
Gc=(1/Gplanta)/(s*(s+10));
disenar_sistema(Gplanta,'Ts',1,'Mp',0.15,'Gc',Gc)
% Como simplificar; 
Gtot=minreal(Gc*Gplanta);
Glc=feedback(1,Gtot);

%% Margin

margin(Gc*Gplanta)