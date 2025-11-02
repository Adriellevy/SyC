% lugar de racies

%% Ejercicio 7a
p = [1 -1 0]; 
z = [1]; 

G = tf(z,p); 

rlocus(G)
axis([-5 5 -5 5])   % [xmin xmax ymin ymax]
%% Ejercicio 7b
p = [1 19 -20 0]; 
z = [1 2]; 

G = tf(z,p); 

rlocus(G)
% axis([-5 5 -5 5])   % [xmin xmax ymin ymax]

%% Ejercicio 10

p = [1 10 -2 -20]; 
z = [1 1 20 20]; 

G = tf(z,p); 

rlocus(G)
% axis([-5 5 -5 5])   % [xmin xmax ymin ymax]
