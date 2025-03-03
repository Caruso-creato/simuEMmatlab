function plottaAmbienteSimulazione(srb, datiEdifici, puntiMisuraSettori, params)
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
        fill(building_data.x, building_data.y, [0.6 0.6 0.6], 'EdgeColor', 'k', 'FaceAlpha', 0.5);
        centro_x = mean(building_data.x);
        centro_y = mean(building_data.y);
        text(centro_x, centro_y, sprintf('%d', current_building_id), ...
            'FontSize', 10, 'FontWeight', 'bold', 'Color', 'k', ...
            'HorizontalAlignment', 'center', 'BackgroundColor', 'w');
    end

    % **FIX: Calcolo corretto del punto di misura**
    distanza = params.distanzaMisura;
    azimuth = params.azimuthMisura;
    punto_misura = [
        srb.x + distanza * sind(azimuth),  % Azimuth usa il seno per Y
        srb.y + distanza * cosd(azimuth),  % Azimuth usa il coseno per X
        params.elevazioneMisura
    ];

    % **Plotta il punto di misura corretto**
    plot(punto_misura(1), punto_misura(2), 'bo', 'MarkerSize', 10, 'LineWidth', 2);
    text(punto_misura(1), punto_misura(2), ' Punto di Misura', 'FontSize', 12, 'Color', 'b', ...
        'HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom');

    % 3. Direzioni settori
    lunghezza_freccia = 20;

    for settore = 1:length(puntiMisuraSettori)
        % **FIX: Correzione della freccia del settore**
        azimuth_settore = params.direzioniAzimutaliSettori(settore);
        x_freccia = srb.x + lunghezza_freccia * sind(azimuth_settore);
        y_freccia = srb.y + lunghezza_freccia * cosd(azimuth_settore);

        quiver(srb.x, srb.y, x_freccia - srb.x, y_freccia - srb.y, 0, 'r', 'LineWidth', 3, 'MaxHeadSize', 3);
        
        % **Testo della direzione settore**
        text(x_freccia, y_freccia, sprintf('Settore %d', settore), ...
            'FontSize', 12, 'FontWeight', 'bold', 'Color', 'r', ...
            'HorizontalAlignment', 'left', 'VerticalAlignment', 'middle');

        % **Linea di vista (LOS)**
        plot([srb.x, punto_misura(1)], [srb.y, punto_misura(2)], 'k--', 'LineWidth', 1.5);
    end

    legend({'SRB', 'Edifici', 'Punti di Misura', 'Direzioni Settori'}, 'Location', 'best');
    hold off;
end

