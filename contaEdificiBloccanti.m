function numOstacoli = contaEdificiBloccanti(params, settore, srb, punto, datiEdifici)
%CONTAEDIFICIBLOCCANTI Conta il numero di edifici che bloccano la LOS.
%   numOstacoli = CONTAEDIFICIBLOCCANTI(params, settore, srb, punto, datiEdifici)
%   Conta gli edifici che bloccano la Line of Sight (LOS) tra la SRB e il
%   punto di misura per il settore specificato.

    numOstacoli = 0;
    edifici_bloccanti_ids = []; % Lista per tenere traccia degli ID degli edifici bloccanti (per evitare conteggi multipli)

    % === GESTIONE TABELLA DATI EDIFICI VUOTA ===
    % Verifica se datiEdifici è vuota (nessun edificio)
    if isempty(datiEdifici) || isempty(datiEdifici.Properties.VariableNames)
        fprintf('⚠️  contaEdificiBloccanti: Nessun edificio presente (tabella datiEdifici vuota).\n');
        return; % Restituisci numOstacoli = 0 immediatamente
    end
    % ==========================================

    % Coordinate 2D della SRB
    x_srb = srb.x;
    y_srb = srb.y;

    % Altezza dell'antenna per il settore specifico
    altezza_antenna = params.altezzaAntenneSettori{settore, 1}; % Base multifrequenza
    if ~isnan(params.altezzaAntenneSettori{settore, 2}) % Se presente la 5G
        altezza_antenna = params.altezzaAntenneSettori{settore, 2};
    end

    % Coordinate 3D del punto di misura
    x_punto = punto(1);
    y_punto = punto(2);
    z_punto = punto(3);


    building_ids = unique(datiEdifici.Id); % Ottieni gli ID unici degli edifici (ITERAZIONE CORRETTA SUGLI EDIFICI)

    for j = 1:length(building_ids) % Itera su ogni ID di edificio (ITERAZIONE CORRETTA SUGLI EDIFICI)
        current_building_id = building_ids(j);
        building_data = datiEdifici(datiEdifici.Id == current_building_id, :); % Estrai TUTTI i dati per l'edificio corrente

        polygon_x = building_data.x; % Vettore coordinate X vertici poligono
        polygon_y = building_data.y; % Vettore coordinate Y vertici poligono
        altezza_edificio = building_data.ALTEZZA(1); % Altezza edificio

        intersezione_trovata = false; % Flag per indicare se c'è intersezione con QUALSIASI lato di questo edificio

        % === ITERA SUI LATI DEL POLIGONO (VERIFICA INTERSEZIONE CON OGNI LATO) ===
        for k = 1:length(polygon_x)-1 % Itera sui vertici TRANNE l'ultimo (per creare segmenti consecutivi)
            x1_building = polygon_x(k);
            y1_building = polygon_y(k);
            x2_building = polygon_x(k+1);
            y2_building = polygon_y(k+1);

            % Verifica intersezione tra segmento LOS (SRB -> Punto) e lato edificio (vertice k -> vertice k+1)
            blocco = polyxpoly([x_srb, x_punto], [y_srb, y_punto], [x1_building, x2_building], [y1_building, y2_building]);

            if ~isempty(blocco)
                intersezione_trovata = true; % Imposta il flag a true se c'è intersezione
                % RIMOSSO IL BREAK!!!
            end
        end
        % ========================================================================


        if intersezione_trovata % Se c'è stata ALMENO UN'intersezione

            % Calcola la quota della linea di vista all'altezza del centroide dell'edificio (APPROSSIMAZIONE)
            distanza_edificio = norm([mean(polygon_x) - x_srb, mean(polygon_y) - y_srb]); % Usa centroidi del POLIGONO INTERO
            distanza_totale = norm([x_punto - x_srb, y_punto - y_srb]);

            altezza_linea = altezza_antenna + (z_punto - altezza_antenna) * (distanza_edificio / distanza_totale);

            % Controlla se l'edificio blocca effettivamente il segnale (confronto altezze)
            if altezza_edificio >= altezza_linea
                % Verifica se l'ID dell'edificio è già stato contato come ostacolo
                if ~ismember(current_building_id, edifici_bloccanti_ids)
                    numOstacoli = numOstacoli + 1;
                    edifici_bloccanti_ids = [edifici_bloccanti_ids, current_building_id]; % Aggiungi ID alla lista degli edifici bloccanti
                    fprintf('🚧 Ostacolo rilevato:\n');
                    fprintf('    Edificio ID: %d\n', current_building_id);
                    fprintf('    Altezza edificio: %.2f m\n', altezza_edificio);
                    fprintf('    Altezza linea di vista al punto: %.2f m\n', altezza_linea);
                else
                    fprintf('⚠️  Edificio ID %d già contato come ostacolo, ignorato.\n', current_building_id);
                end
            else
                fprintf('✅ Edificio ID: %d - NON blocca il segnale (altezza edificio: %.2f m, altezza linea: %.2f m)\n', ...
                    current_building_id, altezza_edificio, altezza_linea);
            end
        end
    end

    % Riassunto
    fprintf('🔍 Totale ostacoli rilevati per il settore %d: %d\n', settore, numOstacoli);
end