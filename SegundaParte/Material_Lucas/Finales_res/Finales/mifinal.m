%% ejercicio 1
num=12.64;
den= [1 1.6 4];
g=tf(num, den); 
sisotool(g)
%% respuesta al escalon de la transferencia 
num=[-5.74 -5.74];
den=[0 -0.8-1.83*1i -0.8+1.83*1i];
k=12.17;
Gt=zpk(num, den, k);
sisotool(Gt)
M=feedback(Gt,1)

%% ejercicio 2
num=[];
den=[0 -1.83-3.14*1i -1.83+3.14*1i];
k=13,25;
G=zpk(num, den, k);
sisotool(G)

%% nueva tf
num=[-53.89];
den=[0 0 -1.83-3.14*1i -1.83+3.14*1i];
k=0.314;
G=zpk(num, den, k);
sisotool(G)

