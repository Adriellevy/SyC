% -------------------------
% DesignCompensatorUI.m
% -------------------------
function DesignCompensatorUI(Gplant)
% Gplant: tf object de la planta (si no se pasa, pide al usuario que lo cree)
if nargin < 1
    errordlg('Pasa Gplant como tf al llamar DesignCompensatorUI(G).','Falta planta');
    return;
end

% Crear UI
fig = uifigure('Name','Diseño de Compensador por Lugar de Raíces','Position',[100 100 1000 650]);

ax = uiaxes(fig,'Position',[25 120 700 500]);
% dibujar lugar de raíces usando tu función existente:
try
    % Asumimos GraficarLugarDeSingularidades dibuja sobre el axes actual
    axes(ax);
    GraficarLugarDeSingularidades(Gplant);
catch
    % fallback: usar rlocus si la tuya no acepta axes
    axes(ax);
    rlocus(Gplant);
    title('Lugar de raíces (fallback rlocus)');
end

% Controles
lblTs = uilabel(fig,'Position',[750 540 200 22],'Text','Ts (s):');
editTs = uieditfield(fig,'numeric','Position',[900 540 70 22],'Value',3);

lblZeta = uilabel(fig,'Position',[750 500 200 22],'Text','zeta (% o decimal):');
editZeta = uieditfield(fig,'numeric','Position',[900 500 70 22],'Value',0.3);

btnAreas = uibutton(fig,'push','Text','Superponer Áreas','Position',[750 460 220 30],...
    'ButtonPushedFcn',@(btn,event) graficoAreasCallback());

btnPickP = uibutton(fig,'push','Text','Seleccionar Polo Deseado (clic)','Position',[750 420 220 30],...
    'ButtonPushedFcn',@(btn,event) pickPCallback());

lblP = uilabel(fig,'Position',[750 380 400 22],'Text','P: (no seleccionado)');

btnCompute = uibutton(fig,'push','Text','Calcular Compensador (Osaka)','Position',[750 340 220 30],...
    'ButtonPushedFcn',@(btn,event) computeCallback());

btnSim = uibutton(fig,'push','Text','Simular Lazo Cerrado','Position',[750 300 220 30],...
    'ButtonPushedFcn',@(btn,event) simulateCallback());

btnExport = uibutton(fig,'push','Text','Exportar Compensador','Position',[750 260 220 30],...
    'ButtonPushedFcn',@(btn,event) exportCallback());
% Tabla de compensadores (ID | tipo | zc | pc | Kc | descripción)
compTable = uitable(fig,'Position',[25 10 700 90],...
    'ColumnName',{'ID','Tipo','z_c','p_c','Kc','Descripción'},...
    'ColumnEditable',[false false false false false false],...
    'Data',cell(0,6));

% Botones extra para múltiples compensadores
btnAddCancel = uibutton(fig,'push','Text','Agregar lead (cancelar z/p)','Position',[750 200 220 30],...
    'ButtonPushedFcn',@(btn,event) addCancelCallback());
btnAddAnother = uibutton(fig,'push','Text','Agregar otro lead (encadenar)','Position',[750 160 220 30],...
    'ButtonPushedFcn',@(btn,event) addAnotherCallback());
btnRemove = uibutton(fig,'push','Text','Eliminar seleccionado','Position',[750 120 220 30],...
    'ButtonPushedFcn',@(btn,event) removeCallback());
btnCombine = uibutton(fig,'push','Text','Combinar compensadores','Position',[750 80 220 30],...
    'ButtonPushedFcn',@(btn,event) combineCallback());
% Variables compartidas
app.P = [];
app.G = Gplant;
app.zc = [];
app.pc = [];
app.Kc = [];
app.Gc = [];
app.compensators = {}; % cada elemento: struct with fields id, type, zc, pc, Kc, Gc, desc
app.nextCompId = 1;
% Callback definitions
    function graficoAreasCallback()
        Ts = editTs.Value;
        zetaVal = editZeta.Value;
        % suponemos GraficoAreasPosibles(Ts, zeta_percent_or_value)
        try
            % si la función grafica sobre el axes actual:
            axes(ax);
            GraficoAreasPosibles(Ts, zetaVal);
        catch
            warndlg('No se pudo correr GraficoAreasPosibles. Comprueba la función.');
        end
    end

    function pickPCallback()
        axes(ax);
        title(ax,'Click en el punto deseado P (clic izquierdo)');
        [xp, yp] = ginput(1);
        P = xp + 1i*yp;
        app.P = P;
        lblP.Text = sprintf('P = %.4f %+.4fi', real(P), imag(P));
        % mostrar cruz en P
        hold(ax,'on');
        h = plot(ax, real(P), imag(P), 'rx', 'MarkerSize',10, 'LineWidth',2);
        text(ax, real(P), imag(P), '  P','Color','r');
        hold(ax,'off');
    end

    function computeCallback()
        if isempty(app.P)
            uialert(fig,'Selecciona un polo deseado antes de calcular.','Falta P');
            return;
        end
        % calcular deficit de ángulo
        angleNeeded = angleDeficit(app.G, app.P); % en grados
        % llamar al método Osaka
        [zc, pc, Kc, Gc] = computeLeadCompensator_Osaka(app.G, app.P, angleNeeded);
        app.zc = zc; app.pc = pc; app.Kc = Kc; app.Gc = Gc;
        % Dibujar sobre el axes:
        axes(ax); hold(ax,'on');
        plot(ax, real(zc), imag(zc), 'go', 'MarkerFaceColor','g'); text(ax, real(zc), imag(zc),'  z_c');
        plot(ax, real(pc), imag(pc), 'mo', 'MarkerFaceColor','m'); text(ax, real(pc), imag(pc),'  p_c');
        legend(ax,'Location','best');
        hold(ax,'off');
        uialert(fig,sprintf('Compensador calculado:\\nz_c=%.4f, p_c=%.4f, Kc=%.4g',zc,pc,Kc),'Listo');
    end

    function simulateCallback()
        if isempty(app.Gc)
            uialert(fig,'Calcula el compensador primero.','Falta compensador');
            return;
        end
        % L(s) = Kc * Gc * G
        L = app.Kc * app.Gc * app.G;
        T = feedback(L,1);
        % mostrar polos y respuesta al escalón
        figure('Name','Polos y respuesta al escalón');
        subplot(2,1,1); pzplot(T); title('Polos de lazo cerrado');
        subplot(2,1,2); step(T); title('Respuesta al escalón (lazo cerrado)');
    end

    function exportCallback()
        if isempty(app.Gc)
            uialert(fig,'Calcula el compensador antes de exportar.','Falta compensador');
            return;
        end
        fname = exportCompensatorScript(app.Gc, app.Kc);
        uialert(fig, ['Exportado a: ' fname],'Exportado');
    end
    function addCancelCallback()
    % Requiere que haya seleccionado P o que el usuario introduzca el par a cancelar
    if isempty(app.P)
        answer = questdlg('No seleccionaste P. ¿Deseas cancelar un cero/polo existente de la planta manualmente?','Cancelar?','Si','No','Si');
        if strcmp(answer,'No'), return; end
        prompt = {'Ingresa (real) la ubicación del cero/polo a cancelar (ej: -1.5):'};
        dlgtitle = 'Cancelar polo/cero (manual)';
        dims = [1 50];
        definput = {'-1'};
        resp = inputdlg(prompt,dlgtitle,dims,definput);
        if isempty(resp), return; end
        cancelPoint = str2double(resp{1});
        Puse = [];
    else
        cancelPoint = []; Puse = app.P;
    end
    % Preguntar si cancelar cero o polo: intentaremos encontrar el más cercano
    sel = questdlg('¿Cancelar un cero (z) o polo (p) de la planta?','Tipo de cancelación','Cero','Polo','Cero');
    if isempty(sel), return; end
    cancelType = sel; % 'Cero' o 'Polo'
    % Llamar a la función que calcula el lead y hace la cancelación
    try
        [zc, pc, Kc, Gc, desc] = computeLeadWithCancellation(app.G, Puse, cancelPoint, cancelType);
    catch ME
        errordlg(['Error en cálculo: ' ME.message]);
        return;
    end
    % Guardar en lista
    id = app.nextCompId; app.nextCompId = id + 1;
    entry = struct('id',id,'type','lead_cancel','zc',zc,'pc',pc,'Kc',Kc,'Gc',Gc,'desc',desc);
    app.compensators{end+1} = entry;
    refreshTable();
    % Dibujar en axes
    axes(ax); hold(ax,'on');
    plot(ax, real(zc), imag(zc),'ks','MarkerFaceColor','g'); text(ax, real(zc), imag(zc),' z_c');
    plot(ax, real(pc), imag(pc),'ks','MarkerFaceColor','m'); text(ax, real(pc), imag(pc),' p_c');
    hold(ax,'off');
end

function addAnotherCallback()
    % Diseñar un lead adicional por el método Osaka estándar (sin cancelación)
    if isempty(app.P)
        uialert(fig,'Selecciona P (polo deseado) o clic en el plano primero.','Falta P');
        return;
    end
    angleNeeded = angleDeficit(app.G, app.P);
    [zc, pc, Kc, Gc] = computeLeadCompensator_Osaka(app.G, app.P, angleNeeded);
    id = app.nextCompId; app.nextCompId = id + 1;
    entry = struct('id',id,'type','lead','zc',zc,'pc',pc,'Kc',Kc,'Gc',Gc,'desc','lead Osaka');
    app.compensators{end+1} = entry;
    refreshTable();
    axes(ax); hold(ax,'on');
    plot(ax, real(zc), imag(zc),'bo','MarkerFaceColor','g'); text(ax, real(zc), imag(zc),' z_c');
    plot(ax, real(pc), imag(pc),'bo','MarkerFaceColor','m'); text(ax, real(pc), imag(pc),' p_c');
    hold(ax,'off');
end

function removeCallback()
    % Eliminar fila seleccionada de la tabla
    idx = compTable.Selection;
    if isempty(idx), uialert(fig,'Selecciona una fila en la tabla.','Nada seleccionado'); return; end
    row = idx(1);
    app.compensators(row) = [];
    refreshTable();
    % redibujar lugar para limpiar marcadores (simple: replot completo)
    axes(ax); cla(ax); GraficarLugarDeSingularidades(app.G); GraficoAreasPosibles(editTs.Value, editZeta.Value);
    % volver a dibujar compensadores actuales
    for k=1:numel(app.compensators)
        c = app.compensators{k};
        axes(ax); hold(ax,'on');
        plot(ax, real(c.zc), imag(c.zc),'kx','MarkerFaceColor','g');
        plot(ax, real(c.pc), imag(c.pc),'kx','MarkerFaceColor','m');
        hold(ax,'off');
    end
end

function combineCallback()
    if isempty(app.compensators)
        uialert(fig,'No hay compensadores para combinar.','Vacío');
        return;
    end
    % unir series de Gc
    Gc_comb = combineCompensators(app.compensators);
    % calcular K total: normalmente cada Gc contiene su Kc ya; Gc_comb incluye todo.
    % Guardar como único compensador combinado
    id = app.nextCompId; app.nextCompId = id + 1;
    entry = struct('id',id,'type','combined','zc',NaN,'pc',NaN,'Kc',NaN,'Gc',Gc_comb,'desc','combined series');
    app.compensators{end+1} = entry;
    refreshTable();
    % Simular lazo con Gc_comb
    L = Gc_comb * app.G;
    T = feedback(L,1);
    figure('Name','Lazo con compensador combinado');
    subplot(2,1,1); pzplot(T); title('Polos de lazo cerrado (combinado)');
    subplot(2,1,2); step(T); title('Respuesta al escalón (combinado)');
end

function refreshTable()
    data = cell(numel(app.compensators),6);
    for i=1:numel(app.compensators)
        c = app.compensators{i};
        data{i,1} = c.id;
        data{i,2} = c.type;
        data{i,3} = num2str(c.zc);
        data{i,4} = num2str(c.pc);
        data{i,5} = num2str(c.Kc);
        data{i,6} = c.desc;
    end
    compTable.Data = data;
end


end
