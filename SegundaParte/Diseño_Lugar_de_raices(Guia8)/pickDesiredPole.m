% -------------------------
% pickDesiredPole.m   (opcional si no usas ginput dentro UI)
% -------------------------
function P = pickDesiredPole(ax)
% Selecciona punto con ginput
axes(ax);
[x,y] = ginput(1);
P = x + 1i*y;
end
