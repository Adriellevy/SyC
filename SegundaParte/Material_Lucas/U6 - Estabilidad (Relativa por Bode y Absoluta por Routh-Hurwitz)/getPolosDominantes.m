function [pole1,pole2] = getPolosDominantes(Mp, ts)
%GETPOLOSDOMINANTES Devuelve la posición de los polos dominantes según el
%overshoot y el tiempo de asentamiento deseado de 2% de tolerancia.
%   Si quiero un Mp = 4.32 (%) y un tiempo de asentamiento al 2% de ts = 4
%   (s), entonces los polos dominantes deberían ser ubicados en [1+i, 1-i].
%   Usando la función sería:
%   DomPoles = PolosDominantes(4.32, 4);
%   donde DomPoles = [1+i, 1-i]
%
%   Basado en la teoría de Ogata, Capítulo 5-3.

% Factor de Amortiguamiento
fact_am = 1 / sqrt(1+( pi/(log(100/Mp)) )^2);

% Frecuencia angular natural
wn = 4 / (fact_am*ts);

% Ubicación de los polos aproximada
pole1 = -fact_am*wn + i * wn*sqrt(1-fact_am^2);
pole2 = -fact_am*wn - i * wn*sqrt(1-fact_am^2);

%disp('Chequear que no haya ceros/polos cercanos ' + ...
%    '(parte real < 5 * sigma_pdom).');

end

