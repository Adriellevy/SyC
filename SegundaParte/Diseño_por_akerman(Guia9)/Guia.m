%% Ejercicio 1
num=[23.45 7.18];
den=[1 6.25 28.32 7.18];
Init_cond=0;
G=tf(num,den)

[A,B,C,D] = tf2ss(num,den);
A=flip(fliplr(A));
B=flip(B);
C=fliplr(C);

% Controlabilidad
Co = ctrb(A,B);
rank_Co = rank(Co);
% disp(Co);
disp(['Rango(Co) = ', num2str(rank_Co)]);

% Observabilidad
Ob = obsv(A,C);
rank_Ob = rank(Ob);
% disp(Ob);
disp(['Rango(Ob) = ', num2str(rank_Ob)]);


step(tf(1),G)

%% Ejercicio 2 sistema regulador

A= [0 1 0;0 0 1;-1 -5 -6];
B=[0 0 1]';
C=[1 1 1];
D=[0];
n = size(A,1); %Cantidad de variables de estado
% if rank(ctrb(A,B)~= n)
%     error('Sistema no controlable')
% end
% if rank(obsv(A,C)~= n)
%     error('Sistema no es observable')
% end
Plc=[-2+i*4 -2-i*4 -10];

k = acker(A,B,Plc);
Init_cond=zeros(1,size(A,1));
Init_cond=rand(1,size(A,1));

%% Ejercicio 4

syms s;
densimbolo = (s+0.5)*(s+0.1)*(s+2);
Den = sym2poly(expand(densimbolo))
Num = [0.1]; 

G =tf(Num,Den);
[A,B,C,D]=tf2ss(Num,Den);

A=flip(fliplr(A));
B=flip(B);
C=fliplr(C);
n = size(A,1); % Cantidad de variables de estado

Init_cond=zeros(1,size(A,1));
% step(tf(1),G)
Plc = [-0.8+1.1i;-0.8-1.1i; -5];
if rank(ctrb(A,B)) ~= n
    error('Sistema no controlable')
end

if rank(obsv(A,C)) ~= n
    error('Sistema no es observable')
end
k = acker(A,B,Plc);
kr=0.001;




