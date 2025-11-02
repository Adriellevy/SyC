function [outputArg1,outputArg2] = GraficarLugarDeSingularidades(GLA)
    figure(1);
    set(gcf, 'Name', 'LugarSingularidades', 'NumberTitle', 'off');
    pzmap(GLA)

    % Obtener límites actuales de los ejes
    lims = axis;
    
    % Calcular el rango actual
    xRange = lims(2) - lims(1);
    yRange = lims(4) - lims(3);
    
    % Calcular nuevos límites con un 50% más
    newLims = [lims(1) - 0.25*xRange, lims(2) + 0.25*xRange, lims(3) - 0.25*yRange, lims(4) + 0.25*yRange];
    
    % Aplicar nuevos límites
    axis(newLims);
end

