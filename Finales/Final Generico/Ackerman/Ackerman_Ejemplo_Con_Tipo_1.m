%% Ackerman 
[A,B,C,D] = tf2ss([0 0 3],[8 6 1]);

Ahat = [ A zeros(size(A,1),1); -C 0 ];

Bhat = [B ; 0];

ctr = [Bhat Ahat*Bhat Ahat*Ahat*Bhat Ahat*Ahat*Ahat*Bhat];

PLC=[-50+i*59;-50-i*59; -100]
K = acker(Ahat, Bhat ,PLC);