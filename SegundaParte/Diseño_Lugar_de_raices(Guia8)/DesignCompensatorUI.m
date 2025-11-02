% -------------------------
% DesignCompensatorUI.m
% -------------------------
function DesignCompensatorUI(Gplant)
% Interfaz interactiva orientada a diseño SUBAMORTIGUADO (pares complejos)
% Gplant: tf object de la planta (required)

if nargin < 1 || isempty(Gplant)
    errordlg('Pasa Gplant como tf al llamar DesignCompensatorUI(G).','Falta planta');
    return;
end

% --- Create UI ---
fig = uifigure('Name','Diseño de Compensador (Subamortiguado) - Lugar de Raíces','Position',[120 80 1100 720]);

ax = uiaxes(fig,'Position',[20 150 760 540]);
xlabel(ax,'Real'); ylabel(ax,'Im');
grid(ax,'on'); hold(ax,'on');

% dibujar lugar de raíces usando tu función existente (si falla, rlocus)
try
    axes(ax);
    GraficarLugarDeSingularidades(Gplant);
catch
    axes(ax);
    rlocus(Gplant);
    title(ax,'Lugar de raíces (fallback rlocus)');
end

% --- Controls (left panel) ---
lblTitle = uilabel(fig,'Position',[800 660 280 25],'Text','Especificaciones (subamortiguado)','FontWeight','bold');

lblTs = uilabel(fig,'Position',[800 620 120 22],'Text','Ts (s):');
editTs = uieditfield(fig,'numeric','Position',[920 620 120 22],'Value',3,'Limits',[0 Inf]);

lblZeta = uilabel(fig,'Position',[800 580 120 22],'Text','ζ (0 < ζ < 1):');
editZeta = uieditfield(fig,'numeric','Position',[920 580 120 22],'Value',0.3,'Limits',[0 0.999]);

lblMp = uilabel(fig,'Position',[800 540 120 22],'Text','(Opc) Mp %:');
editMp = uieditfield(fig,'numeric','Position',[920 540 120 22],'Value',30,'Limits',[0 100]);

btnPlotAreas = uibutton(fig,'push','Text','Superponer Áreas (subam.)','Position',[800 500 240 30],...
    'ButtonPushedFcn',@(btn,event) graficoAreasCallback());

btnCalcPoles = uibutton(fig,'push','Text','Calcular Polos Deseados','Position',[800 460 240 30],...
    'ButtonPushedFcn',@(btn,event) calcPolesCallback());

lblP = uilabel(fig,'Position',[800 420 300 22],'Text','P (polo dominante): (no seleccionado)');

btnPickP = uibutton(fig,'push','Text','Seleccionar Polo (clic en plano)','Position',[800 380 240 30],...
    'ButtonPushedFcn',@(btn,event) pickPCallback());

btnCompute = uibutton(fig,'push','Text','Calcular Compensador (Osaka mod.)','Position',[800 340 240 30],...
    'ButtonPushedFcn',@(btn,event) computeCallback());

btnAddCancel = uibutton(fig,'push','Text','Agregar lead (cancelar z/p)','Position',[800 300 240 30],...
    'ButtonPushedFcn',@(btn,event) addCancelCallback());

btnAddAnother = uibutton(fig,'push','Text','Agregar otro lead (encadenar)','Position',[800 260 240 30],...
    'ButtonPushedFcn',@(btn,event) addAnotherCallback());

btnCombine = uibutton(fig,'push','Text','Combinar compensadores','Position',[800 220 240 30],...
    'ButtonPushedFcn',@(btn,event) combineCallback());

btnSim = uibutton(fig,'push','Text','Simular Lazo Cerrado (comp.)','Position',[800 180 240 30],...
    'ButtonPushedFcn',@(btn,event) simulateCallback());

btnExport = uibutton(fig,'push','Text','Exportar Compensador','Position',[800 140 240 30],...
    'ButtonPushedFcn',@(btn,event) exportCallback());

% table for compensators
compTable = uitable(fig,'Position',[20 20 760 110],...
    'ColumnName',{'ID','Tipo','z_c','p_c','Kc','Desc'},...
    'ColumnEditable',[false false false false false false],...
    'Data',cell(0,6));

% Shared app state
app.G = Gplant;
app.P = [];           % selected desired pole (complex, one of conjugates)
app.sd = [];          % pair of desired poles (complex conjugates)
app.zeta = []; app.wn = []; app.wd = [];
app.zc = []; app.pc = []; app.Kc = []; app.Gc = [];
app.compensators = {}; app.nextCompId = 1;

% --- Callbacks / helper subfunctions ---

    function graficoAreasCallback()
        % Superpone solo regiones subamortiguadas (0<zeta<1)
        Ts = editTs.Value;
        zetaVal = editZeta.Value;
        if zetaVal <= 0 || zetaVal >= 1
            uialert(fig,'Introduce ζ en (0,1) para región subamortiguada.','ζ inválido');
            return;
        end
        axes(ax); hold(ax,'on');
        try
            % Si existe tu función GraficoAreasPosibles la usamos; si no, graficamos líneas de zeta
            GraficoAreasPosibles(Ts, zetaVal);
        catch
            % Local simple: dibujar línea que muestra el ángulo asociado a zeta (línea desde origen con ángulo acos(ζ))
            theta = acos(zetaVal); % rad
            % crear semirrecta que represente locus de polos con ese zeta
            r = linspace(0,5,200);
            x = -r * cos(theta);
            y = r * sin(theta);
            plot(ax, x, y, '--','DisplayName',sprintf('\\zeta=%.2f',zetaVal));
            plot(ax, x, -y, '--','HandleVisibility','off');
            legend(ax,'show');
            title(ax,'Áreas subamortiguadas (líneas de ζ)');
        end
    end

    function calcPolesCallback()
        % Calcular polos complejos deseados a partir de Ts y zeta.
        Ts = editTs.Value;
        zetaVal = editZeta.Value;
        if zetaVal <= 0 || zetaVal >= 1
            uialert(fig,'ζ debe estar en (0,1).','ζ inválido'); return;
        end
        % wn aproximado
        wn = 4 / (zetaVal * Ts);
        wd = wn * sqrt(1 - zetaVal^2);
        sd1 = -zetaVal*wn + 1i*wd;
        sd2 = conj(sd1);
        app.sd = [sd1 sd2];
        app.zeta = zetaVal; app.wn = wn; app.wd = wd;
        % plot markers and annotate
        axes(ax); hold(ax,'on');
        h1 = plot(ax, real(sd1), imag(sd1), 'rx', 'MarkerSize',12,'LineWidth',2,'DisplayName','P deseado');
        h2 = plot(ax, real(sd2), imag(sd2), 'rx','MarkerSize',12,'LineWidth',2,'HandleVisibility','off');
        txt = sprintf('\\zeta=%.3f, \\omega_n=%.3f, \\omega_d=%.3f', zetaVal, wn, wd);
        text(ax, real(sd1)+0.05, imag(sd1), txt, 'Color','r');
        title(ax,'Polos deseados (subamortiguado)');
        % set app.P to dominant pole (upper half)
        app.P = sd1;
        lblP.Text = sprintf('P = %.4f %+.4fi  (subamortiguado)', real(app.P), imag(app.P));
        hold(ax,'off');
    end

    function pickPCallback()
        % Allow user to pick a pole; if picks real point, prompt to create conjugate using current zeta/wn
        axes(ax); title(ax,'Click en el polo deseado (parte imaginaria diferente de 0 preferida)');
        [xp,yp] = ginput(1);
        Pclicked = xp + 1i*yp;
        if abs(imag(Pclicked)) < 1e-6
            % clicked on real axis: suggest constructing complex pair using ζ
            choice = questdlg('Seleccionaste punto real. ¿Deseas convertirlo en polo complejo conjugado usando ζ actual?','Punto real','Si','No','Si');
            if strcmp(choice,'Yes') || strcmp(choice,'Si')
                zetaVal = editZeta.Value;
                if zetaVal <= 0 || zetaVal >= 1
                    uialert(fig,'ζ inválido para crear conjugado. Ajusta ζ en (0,1).','ζ inválido'); return;
                end
                % interpret xp as -zeta*wn => compute wn = -xp/zeta
                wnGuess = -real(Pclicked)/zetaVal;
                if wnGuess <= 0
                    uialert(fig,'No se puede formar par complejo con ese xp y ζ. Escoge otro punto.','Error'); return;
                end
                wd = wnGuess * sqrt(1 - zetaVal^2);
                Pnew = -zetaVal*wnGuess + 1i*wd;
                app.P = Pnew;
                app.sd = [Pnew conj(Pnew)];
                app.zeta = zetaVal; app.wn = wnGuess; app.wd = wd;
                lblP.Text = sprintf('P construido = %.4f %+.4fi', real(Pnew), imag(Pnew));
                axes(ax); hold(ax,'on');
                plot(ax, real(Pnew), imag(Pnew), 'rx','MarkerSize',12,'LineWidth',2);
                plot(ax, real(conj(Pnew)), imag(conj(Pnew)), 'rx','MarkerSize',12,'LineWidth',2);
                hold(ax,'off');
                return;
            else
                uialert(fig,'Selecciona un punto con parte imaginaria o usa "Calcular Polos Deseados".','Info'); return;
            end
        else
            % clicked complex point; accept but ensure upper half (dominant)
            if imag(Pclicked) < 0
                Pclicked = conj(Pclicked);
            end
            app.P = Pclicked;
            app.sd = [Pclicked conj(Pclicked)];
            % estimate zeta/wn from location
            zeta_est = -real(Pclicked)/abs(Pclicked);
            wn_est = abs(Pclicked);
            app.zeta = zeta_est; app.wn = wn_est; app.wd = imag(Pclicked);
            lblP.Text = sprintf('P = %.4f %+.4fi (detected ζ=%.3f)', real(app.P), imag(app.P), app.zeta);
            axes(ax); hold(ax,'on');
            plot(ax, real(app.P), imag(app.P), 'rx','MarkerSize',12,'LineWidth',2);
            plot(ax, real(conj(app.P)), imag(conj(app.P)), 'rx','MarkerSize',12,'LineWidth',2,'HandleVisibility','off');
            hold(ax,'off');
        end
    end

    function computeCallback()
        % Main compensator calculation adapted to target complex pole (subamortiguado)
        if isempty(app.P)
            uialert(fig,'Selecciona o calcula un polo deseado (subamortiguado) primero.','Falta P'); return;
        end
        % compute angle deficit at P
        angleNeeded = angleDeficit(app.G, app.P); % degrees
        % compute lead compensator using modified Osaka for complex P
        [zc, pc, Kc, Gc] = computeLeadCompensator_Osaka_sub(app.G, app.P, angleNeeded, app.zeta);
        if isempty(Gc) || isnan(Kc)
            uialert(fig,'No se pudo calcular compensador (Kc NaN o Gc vacío). Revisa datos.','Error');
            return;
        end
        app.zc = zc; app.pc = pc; app.Kc = Kc; app.Gc = Gc;
        % plot markers
        axes(ax); hold(ax,'on');
        plot(ax, real(zc), imag(zc), 'go', 'MarkerFaceColor','g'); text(ax, real(zc), imag(zc),' z_c');
        plot(ax, real(pc), imag(pc), 'mo', 'MarkerFaceColor','m'); text(ax, real(pc), imag(pc),' p_c');
        hold(ax,'off');
        uialert(fig,sprintf('Compensador calculado:\\nz_c=%.4f, p_c=%.4f, Kc=%.4g',zc,pc,Kc),'Listo');
    end

    function simulateCallback()
        if isempty(app.Gc)
            uialert(fig,'Calcula el compensador primero.','Falta compensador'); return;
        end
        L = app.Gc * app.G; % note: Gc already includes Kc
        T = feedback(L,1);
        figSim = figure('Name','Simulación Lazo Cerrado');
        subplot(2,1,1); pzplot(T); title('Polos de lazo cerrado');
        subplot(2,1,2); step(T); title('Respuesta al escalón (lazo cerrado)');
        % compute ζ, wn of dominant poles and print
        pcls = pole(T);
        % find dominant complex conjugate pair (closest to imaginary axis but complex)
        complexPoles = pcls(abs(imag(pcls))>1e-6);
        if ~isempty(complexPoles)
            % choose with largest real part (least negative)
            [~, idx] = max(real(complexPoles));
            pd = complexPoles(idx);
            zeta_est = -real(pd)/abs(pd);
            wn_est = abs(pd);
            disp(['Dominant pair estimate: zeta=', num2str(zeta_est,3), ', wn=', num2str(wn_est,3)]);
        end
    end

    function fname = exportCallback()
        if isempty(app.Gc)
            uialert(fig,'Calcula el compensador antes de exportar.','Falta compensador'); fname = ''; return;
        end
        fname = exportCompensatorScript(app.Gc);
        uialert(fig, ['Exportado a: ' fname],'Exportado');
    end

    function addCancelCallback()
        % Add lead that cancels a plant zero/pole while preserving subamortiguado objective
        if isempty(app.P)
            answer = questdlg('No seleccionaste P. ¿Cancelar un cero/polo manualmente?','Cancelar?','Si','No','Si');
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
        sel = questdlg('¿Cancelar un cero (z) o polo (p) de la planta?','Tipo de cancelación','Cero','Polo','Cero');
        if isempty(sel), return; end
        cancelType = sel;
        try
            [zc, pc, Kc, Gc, desc] = computeLeadWithCancellation_sub(app.G, Puse, cancelPoint, cancelType, app.zeta);
        catch ME
            errordlg(['Error en cálculo: ' ME.message]);
            return;
        end
        id = app.nextCompId; app.nextCompId = id + 1;
        entry = struct('id',id,'type','lead_cancel','zc',zc,'pc',pc,'Kc',Kc,'Gc',Gc,'desc',desc);
        app.compensators{end+1} = entry;
        refreshTable();
        axes(ax); hold(ax,'on');
        plot(ax, real(zc), imag(zc),'ks','MarkerFaceColor','g'); text(ax, real(zc), imag(zc),' z_c');
        plot(ax, real(pc), imag(pc),'ks','MarkerFaceColor','m'); text(ax, real(pc), imag(pc),' p_c');
        hold(ax,'off');
    end

    function addAnotherCallback()
        if isempty(app.P)
            uialert(fig,'Selecciona P (polo deseado) primero.','Falta P'); return;
        end
        angleNeeded = angleDeficit(app.G, app.P);
        [zc, pc, Kc, Gc] = computeLeadCompensator_Osaka_sub(app.G, app.P, angleNeeded, app.zeta);
        id = app.nextCompId; app.nextCompId = id + 1;
        entry = struct('id',id,'type','lead','zc',zc,'pc',pc,'Kc',Kc,'Gc',Gc,'desc','lead Osaka sub');
        app.compensators{end+1} = entry;
        refreshTable();
        axes(ax); hold(ax,'on');
        plot(ax, real(zc), imag(zc),'bo','MarkerFaceColor','g'); text(ax, real(zc), imag(zc),' z_c');
        plot(ax, real(pc), imag(pc),'bo','MarkerFaceColor','m'); text(ax, real(pc), imag(pc),' p_c');
        hold(ax,'off');
    end

    function combineCallback()
        if isempty(app.compensators)
            uialert(fig,'No hay compensadores para combinar.','Vacío'); return;
        end
        Gc_comb = combineCompensators(app.compensators);
        id = app.nextCompId; app.nextCompId = id + 1;
        entry = struct('id',id,'type','combined','zc',NaN,'pc',NaN,'Kc',NaN,'Gc',Gc_comb,'desc','combined series');
        app.compensators{end+1} = entry;
        refreshTable();
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

% --- End of UI callbacks ---

% ------------------------
% Helper functions below
% ------------------------

    function angleNeededDeg = angleDeficit(G, P)
        % compute angle deficiency for point P (deg)
        % use evalfr for complex s evaluation
        try
            Gp = evalfr(G, P);
        catch
            Gp = freqresp(G, P);
            Gp = squeeze(Gp);
        end
        angG = angle(Gp); % rad
        angGdeg = rad2deg(angG);
        raw = 180 - angGdeg;
        angleNeededDeg = mod(raw + 180, 360) - 180; % map to [-180,180]
        % We prefer a positive lead contribution for lead compensator => return positive equivalent
        if angleNeededDeg < 0
            % map to positive by adding 360 (designer may still accept negative small angles)
            angleNeededDeg = angleNeededDeg + 360;
            if angleNeededDeg > 180
                angleNeededDeg = angleNeededDeg - 360;
            end
        end
    end

    function [zc, pc, Kc, Gc] = computeLeadCompensator_Osaka_sub(G, P, angleNeededDeg, zeta_target)
        % Modified Osaka for complex P (subamortiguado). Ensures zeta_target<1 and produces stable real zc>pc<0.
        % Returns NaNs if impossible.
        zc = NaN; pc = NaN; Kc = NaN; Gc = [];
        if isempty(P) || imag(P)==0
            warning('P debe ser complejo (subamortiguado).');
            return;
        end
        if zeta_target <= 0 || zeta_target >= 1
            warning('zeta_target debe estar en (0,1).');
            return;
        end

        % Geometry: construct bisector between PA (horizontal left) and PO (vector to origin)
        theta_PO = atan2(-imag(P), -real(P));
        theta_PA = pi; % leftwards
        % bisector robust
        vx = [cos(theta_PA)+cos(theta_PO), sin(theta_PA)+sin(theta_PO)];
        theta_bisector = atan2(vx(2), vx(1));
        halfAlphaRad = deg2rad(angleNeededDeg/2);

        % two lines from P with angles +/- halfAlpha about bisector
        theta1 = theta_bisector + halfAlphaRad;
        theta2 = theta_bisector - halfAlphaRad;

        % intersection with real axis
        try
            x1 = lineRealAxisIntersection(P, theta1);
            x2 = lineRealAxisIntersection(P, theta2);
        catch
            % fallback: choose symmetric points around projection of P
            proj = real(P);
            x1 = proj - 0.5; x2 = proj - 1.0;
        end

        % Decide which should be zero and which pole to ensure zc > pc (lead)
        zc_candidate = max([x1 x2]);
        pc_candidate = min([x1 x2]);

        % Force them to be in LHP: if any > 0, shift left by safe margin
        if zc_candidate >= 0
            zc_candidate = -abs(zc_candidate) - 0.1;
        end
        if pc_candidate >= 0
            pc_candidate = -abs(pc_candidate) - 0.2;
        end

        % Ensure zc > pc
        if ~(zc_candidate > pc_candidate)
            % adjust small delta
            pc_candidate = zc_candidate - 0.1;
        end

        % Build uncompensated lead (K=1)
        s = tf('s');
        Gc_noK = (s - zc_candidate) / (s - pc_candidate);

        % Compute K such that |G(P)*Gc(P)*K| = 1
        try
            Gp = evalfr(G, P);
            Gcn = evalfr(Gc_noK, P);
            magProd = abs(Gp * Gcn);
            if magProd <= 0
                Kc = NaN;
                Gc = [];
                return;
            else
                Kc = 1 / magProd;
            end
            Gc = Kc * Gc_noK;
            % small safety: if poles/zeros are too close to imaginary axis, push them left
            if real(pc_candidate) > -0.01
                pc_candidate = -0.05 - abs(pc_candidate);
            end
            % assign outputs
            zc = zc_candidate; pc = pc_candidate;
            % final check: ensure design still produces subamortiguado dominant
            L = Gc * G;
            T = feedback(L,1);
            ps = pole(T);
            % require there is at least one complex pole pair
            if ~any(abs(imag(ps))>1e-6)
                warning('Diseño resultante no presenta pares complejos dominantes. Ajusta ζ o P.');
            end
        catch ex
            warning(['Error en cálculo de Kc: ' ex.message]);
            Kc = NaN; Gc = [];
        end
    end

    function x = lineRealAxisIntersection(P, theta)
        % intersection with real axis (Im=0)
        xp = real(P); yp = imag(P);
        if abs(sin(theta)) < 1e-9
            error('Línea casi paralela al eje real.');
        end
        t = -yp / sin(theta);
        x = xp + t * cos(theta);
    end

    function [zc, pc, Kc, Gc, desc] = computeLeadWithCancellation_sub(G, P, cancelPoint, cancelType, zeta_target)
        % Try to place compensator pole/zero to cancel specified plant zero/pole, keep subamortiguado
        zc = NaN; pc = NaN; Kc = NaN; Gc = []; desc = '';
        % find plant zeros/poles
        try
            plantZeros = tzero(G);
        catch
            plantZeros = [];
        end
        plantPoles = pole(G);
        % determine target location in plant to cancel
        if isempty(cancelPoint) && ~isempty(P)
            targetReal = real(P);
        elseif ~isempty(cancelPoint)
            targetReal = cancelPoint;
        else
            error('Falta punto para cancelar.');
        end

        if strcmpi(cancelType,'Cero')
            candidates = plantZeros;
        else
            candidates = plantPoles;
        end
        if isempty(candidates)
            error('No hay %s en la planta para cancelar.', cancelType);
        end
        [~, idx] = min(abs(real(candidates) - targetReal));
        plantPoint = candidates(idx);

        % Strategy: set one of the compensator terms exactly at plantPoint to cancel,
        % and place the other term to the left to form a lead (zc>pc)
        delta = max(0.05, abs(real(plantPoint))*0.05 + 0.05);
        if strcmpi(cancelType,'Cero')
            % cancel plant zero with compensator pole at same location
            pc = real(plantPoint);
            zc = pc + delta;
        else
            % cancel plant pole with compensator zero at same location
            zc = real(plantPoint);
            pc = zc - delta;
        end

        % enforce LHP and lead orientation
        if zc >= 0, zc = -abs(zc)-0.05; end
        if pc >= 0, pc = -abs(pc)-0.1; end
        if ~(zc > pc)
            pc = zc - 0.1;
        end

        s = tf('s');
        Gc_noK = (s - zc) / (s - pc);

        % if P given, compute K to satisfy magnitude condition at P
        if ~isempty(P)
            try
                Gp = evalfr(G,P); Gcn = evalfr(Gc_noK, P);
                magProd = abs(Gp * Gcn);
                if magProd <= 0, Kc = NaN; Gc = []; return; end
                Kc = 1/magProd;
            catch
                Kc = 1;
            end
        else
            Kc = 1;
        end
        Gc = Kc * Gc_noK;
        desc = sprintf('Lead cancel %s at %.4f (delta=%.3f)', cancelType, real(plantPoint), abs(zc-pc));
    end

    function Gc_comb = combineCompensators(listComp)
        Gc_comb = 1;
        for k=1:numel(listComp)
            c = listComp{k};
            if isfield(c,'Gc') && ~isempty(c.Gc)
                Gc_comb = series(Gc_comb, c.Gc);
            end
        end
    end

    function fname = exportCompensatorScript(Gc)
        % Exporta Gc tf object a script
        [num,den] = tfdata(Gc,'v');
        fname = ['Compensador_sub_', datestr(now,'yyyymmdd_HHMMSS'), '.m'];
        fid = fopen(fullfile(pwd,fname),'w');
        fprintf(fid, '%% Script exportado por DesignCompensatorUI (subamortiguado)\n');
        fprintf(fid, 's = tf(''s'');\n');
        fprintf(fid, 'Gc = tf(%s, %s);\n', mat2str(num), mat2str(den));
        fprintf(fid, 'disp(''Gc = ''); Gc\n');
        fclose(fid);
    end

end
