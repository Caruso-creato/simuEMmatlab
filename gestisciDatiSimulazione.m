function gestisciDatiSimulazione()
    fprintf('🔄 Avvio gestione dati simulazione...\n');

    % --- 1. Ottenimento dei parametri iniziali ---
    params = inputParams();  
    num_settori = params.numSettori;

    % --- 2. Inizializzazione dei punti di misura con altezze assolute ---
    puntiMisuraSettori = repmat(struct(...
        'punto_misura_xyz', [0, 0, 0], ...
        'inEdificio', false, ...
        'altezzaEdificio', 0, ...
        'azimuth_relativo', 0, ...
        'elevazione_relativa', 0, ...
        'punto_misura_xyz_rel', [0, 0, 0]), 1, num_settori);

    % --- 3. Creazione del sistema di riferimento ---
    fprintf('🗺️ Creazione del sistema di riferimento...\n');
    [srb, datiEdifici, puntiMisuraSettori] = calcolaSistemaDiRiferimento(params, puntiMisuraSettori);

    % --- 4. Determinazione automatica del tipo di ambiente ---
    numero_edifici = height(datiEdifici);
    altezza_media_edifici = mean(datiEdifici.ALTEZZA);

    if numero_edifici > 100 && altezza_media_edifici > 20
        params.environment_type = 'Urbano (grande città)';
    elseif numero_edifici > 50 && altezza_media_edifici > 10
        params.environment_type = 'Urbano';
    elseif numero_edifici > 20
        params.environment_type = 'Suburbano';
    else
        params.environment_type = 'Rurale';
    end

    fprintf('DEBUG: Ambiente selezionato automaticamente: %s\n', params.environment_type);

    % --- 5. Calcolo per ciascun settore ---
    for settore = 1:num_settori
        fprintf('📡 Settore %d - Calcolo angoli relativi...\n', settore);

        % Determina altezza antenna
        altezza_antenna = params.altezzaAntenneSettori{settore, 1};  
        if ~isnan(params.altezzaAntenneSettori{settore, 2})
            altezza_antenna = params.altezzaAntenneSettori{settore, 2};  
        end

        % Coordinate punto misura
        x_punto = params.distanzaMisura * sind(params.azimuthMisura);
        y_punto = params.distanzaMisura * cosd(params.azimuthMisura);
        z_punto = params.elevazioneMisura;
        punto_misura_xyz = [x_punto, y_punto, z_punto];

        puntiMisuraSettori(settore).punto_misura_xyz = punto_misura_xyz;
        fprintf('DEBUG: Settore %d - Coordinate ASSOLUTE: X = %.2f, Y = %.2f, Z = %.2f\n', ...
                settore, x_punto, y_punto, z_punto);

        % --- 6. Verifica se il punto è dentro un edificio ---
        [punto_misura_in_edificio, altezzaEdificio, punto_misura_xyz] = verificaPuntoInEdificio(punto_misura_xyz, datiEdifici);
        puntiMisuraSettori(settore).altezzaEdificio = altezzaEdificio;  

        % Debug posizione punto
        if punto_misura_in_edificio
            fprintf('⚠️ Il punto di misura è dentro un edificio alto %.2f metri.\n', altezzaEdificio);
        else
            fprintf('✅ Il punto di misura è in un’area libera.\n');
        end

        % Se il punto è dentro un edificio e l’utente sceglie di simulare all’altezza dell’edificio:
        if punto_misura_in_edificio
            punto_misura_xyz(3) = altezzaEdificio;  
            fprintf('✔ Il punto è stato traslato all''altezza dell''edificio: %.2f metri.\n', altezzaEdificio);
        end

        puntiMisuraSettori(settore).inEdificio = punto_misura_in_edificio;

        % --- 7. Conta ostacoli ---
        num_ostacoli = contaEdificiBloccanti(params, settore, srb, punto_misura_xyz, datiEdifici);
        fprintf('🔍 [Settore %d] Totale ostacoli rilevati: %d\n', settore, num_ostacoli);

        disp('🔍 DEBUG: Contenuto di params.configurazioneSettori{settore}:');
        disp(params.configurazioneSettori{settore});


        fprintf('🔍 DEBUG: Settore %d - Azimuth Globale: %.2f°, Azimuth Punto Misura: %.2f°\n', ...
        settore, params.direzioniAzimutaliSettori(settore), params.azimuthMisura);


        % --- 8. Calcolo angoli relativi ---
        [azimuth_relativo, elevazione_relativa, punto_misura_xyz_rel] = ...
            calculateRelativeAngles(params, settore, punto_misura_xyz);

        % Salvataggio dei dati
        puntiMisuraSettori(settore).azimuth_relativo = azimuth_relativo;
        puntiMisuraSettori(settore).elevazione_relativa = elevazione_relativa;
        puntiMisuraSettori(settore).punto_misura_xyz_rel = punto_misura_xyz_rel;

        % --- 9. Scelta del modello di propagazione ---
        params.propagation_model = scegliModelloPropagazione(punto_misura_in_edificio, num_ostacoli, punto_misura_xyz, altezzaEdificio);
    end

    % --- 10. Salvataggio dati ---
    save('sistemaRiferimento.mat', 'srb', 'datiEdifici', 'puntiMisuraSettori', 'params');

    if exist('sistemaRiferimento.mat', 'file') ~= 2
        error('❌ Errore nel salvataggio del file sistemaRiferimento.mat.');
    else
        fprintf('✅ File sistemaRiferimento.mat salvato correttamente.\n');
    end

    fprintf('✅ Dati pronti per la simulazione!\n');
end

