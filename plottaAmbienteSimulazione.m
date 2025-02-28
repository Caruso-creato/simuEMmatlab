function plottaAmbienteSimulazione(srb, datiEdifici, puntiMisuraSettori, params)
    % PLOTTAAMBIENTESIMULAZIONE - Plotta SRB, edifici, punti di misura, settori e ostacoli
    figure;
    hold on;
    grid on;
    axis equal;
    title('📡 Simulazione: SRB, Edifici, Settori, Misure e Ostacoli');
    xlabel('X (m)');
    ylabel('Y (m)');

    % 1. Plotta la SRB
    plot(srb.x, srb.y, 'ro', 'MarkerSize', 10, 'LineWidth', 2);
    text(srb.x, srb.y, '  SRB', 'FontSize', 12, 'Color', 'r');

    % 2. Plotta gli edifici
    building_ids = unique(datiEdifici.Id);
    for j = 1:length(building_ids)
        current_building_id = building_ids(j);
        building_data = datiEdifici(datiEdifici.Id == current_building_id, :);

        % Disegna il poligono dell'edificio
        fill(building_data.x, building_data.y, [0.6 0.6 0.6], 'EdgeColor', 'k', 'FaceAlpha', 0.5);

        % Posiziona l'ID al centro
        centro_x = mean(building_data.x);
        centro_y = mean(building_data.y);
        text(centro_x, centro_y, sprintf('%d', current_building_id), ...
            'FontSize', 10, 'FontWeight', 'bold', 'Color', 'k', ...
            'HorizontalAlignment', 'center', 'BackgroundColor', 'w');
    end

% Plotta il punto di misura UNA SOLA VOLTA
distanza = params.distanzaMisura;
azimuth = params.azimuthMisura;
punto_misura = [distanza * sind(azimuth), distanza * cosd(azimuth), params.elevazioneMisura];

plot(punto_misura(1), punto_misura(2), 'bo', 'MarkerSize', 10, 'LineWidth', 2);
text(punto_misura(1), punto_misura(2), ' Punto di Misura', 'FontSize', 12, 'Color', 'b', ...
    'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom');


    % 3. Punti di misura e direzioni
    colori = lines(length(puntiMisuraSettori));
    lunghezza_freccia = 22;

    for settore = 1:length(puntiMisuraSettori)
        % Dati di input diretti
        distanza = params.distanzaMisura;
        azimuth = params.azimuthMisura;

        % Coordinate del punto di misura
        punto_misura = [
            distanza * sind(azimuth),
            distanza * cosd(azimuth),
            params.elevazioneMisura
        ];

       

        % Direzione dei settori (freccia)
        azimuth_settore = params.direzioniAzimutaliSettori(settore);
        x_freccia = srb.x + lunghezza_freccia * cosd(azimuth_settore);
        y_freccia = srb.y + lunghezza_freccia * sind(azimuth_settore);

        quiver(srb.x, srb.y, y_freccia - srb.y, x_freccia - srb.x, 0, 'r', 'LineWidth', 4, 'MaxHeadSize', 6);
        % Offset per posizionare il testo più vicino alla punta della freccia
    
        % Offset per posizionare il testo vicino alla punta della freccia
        offset_testo = 10; % Modifica se necessario
        
        % Posizione del testo calcolata nello stesso modo della freccia
        x_text = srb.x + (lunghezza_freccia + offset_testo) * cosd(azimuth_settore);
        y_text = srb.y + (lunghezza_freccia + offset_testo) * sind(azimuth_settore);
        
        % Disegna il testo nella stessa direzione della freccia
        text(x_text, y_text, sprintf('Settore %d', settore), ...
            'FontSize', 12, 'FontWeight', 'bold', 'Color', 'r', ...
            'HorizontalAlignment', 'left', 'VerticalAlignment', 'middle');

        

        % Linea di vista
        plot([srb.x, punto_misura(1)], [srb.y, punto_misura(2)], 'k--', 'LineWidth', 1.5);

        % Verifica ostacoli e altezza
        for j = 1:length(building_ids)
            current_building_id = building_ids(j);
            building_data = datiEdifici(datiEdifici.Id == current_building_id, :);

            % Verifica intersezione
            [x_intersect, y_intersect] = polyxpoly([srb.x, punto_misura(1)], [srb.y, punto_misura(2)], ...
                building_data.x, building_data.y);

            if ~isempty(x_intersect)
                % Calcolo della distanza dall'origine (SRB) alla prima intersezione
                distanza_intersezione = sqrt((x_intersect(1) - srb.x)^2 + (y_intersect(1) - srb.y)^2);

                % Altezza della SRB
                altezza_srb = params.altezzaAntenneSettori{settore, 1};

                % Altezza della linea di vista nel punto di intersezione
                altezza_linea_di_vista = altezza_srb + (distanza_intersezione / distanza) * (punto_misura(3) - altezza_srb);

                % Altezza media dell'edificio
                altezza_edificio = mean(building_data.ALTEZZA);

                % Verifica se l'edificio blocca la linea di vista
                if altezza_edificio > altezza_linea_di_vista
                    fill(building_data.x, building_data.y, 'r', 'EdgeColor', 'k', 'FaceAlpha', 0.5);
                end
            end
        end
    end

    legend({'SRB', 'Edifici', 'Punti di Misura', 'Direzioni Settori', 'Ostacoli'}, 'Location', 'best');
    hold off;
end
