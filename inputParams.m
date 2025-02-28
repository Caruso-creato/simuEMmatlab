function params = inputParams()
%INPUTPARAMS Funzione per l'input dei parametri di simulazione da command window. Restituisce una struttura 'params' contenente tutti i parametri.

    disp('Benvenuto nel simulatore di campi elettromagnetici per stazioni radio base!');
  
    % Usa una cartella diversa se necessario
     disp('Ti verranno richiesti i parametri necessari per la simulazione.');

     % Percorso della cartella dei file TXT dei modelli di antenna
    percorsoModelliAntenne = input('Inserisci il percorso completo della cartella contenente i file TXT dei modelli di antenna:\n', 's');
    while ~isfolder(percorsoModelliAntenne)
        disp('Errore: La cartella specificata non esiste.');
        percorsoModelliAntenne = input('Inserisci un percorso valido o premi Invio per la cartella corrente:\n', 's');
        if isempty(percorsoModelliAntenne)
            percorsoModelliAntenne = './'; % Cartella corrente
        end
    end

     % --- Percorso della cartella dei file SHP degli edifici ---
    % Usa una cartella diversa se necessario)
    defaultShapefileFolder = './'; % Cartella corrente come default

    shapefileFolder = input(sprintf('Inserisci il percorso della cartella contenente i file SHP degli edifici (o premi Invio per "%s"):\n', ...
        defaultShapefileFolder), 's');
    if isempty(shapefileFolder)
        shapefileFolder = defaultShapefileFolder;
    end
    while ~isfolder(shapefileFolder)
        disp('Errore: La cartella specificata non esiste.');
        shapefileFolder = input('Inserisci un percorso valido:\n', 's');
    end

    % --- Elenca i file SHP disponibili ---
    shapefiles = dir(fullfile(shapefileFolder, '*.shp'));
    if isempty(shapefiles)
        error('Nessun file SHP trovato nella cartella specificata.');
    end

    fprintf('File SHP disponibili:\n');
    for i = 1:length(shapefiles)
        fprintf('  %d) %s\n', i, shapefiles(i).name);
    end

    % --- Chiedi all'utente di scegliere un file ---
    while true
        fileIndex = input('Inserisci il numero del file SHP da utilizzare, oppure 0 per inserire un percorso manualmente: ');
        if isnumeric(fileIndex) && isscalar(fileIndex) && fileIndex >= 0 && fileIndex <= length(shapefiles)
            break;
        end
        disp('Selezione non valida.');
    end

    if fileIndex == 0
        % --- Input manuale del percorso ---
        percorsoShapefile = input('Inserisci il percorso completo del file shapefile (.shp) degli edifici:\n', 's');
        while ~isfile(percorsoShapefile) || ~endsWith(percorsoShapefile, '.shp', 'IgnoreCase', true)
            disp('Errore: Il file specificato non esiste o non è un file .shp.');
            percorsoShapefile = input('Inserisci un percorso valido per il file .shp:\n', 's');
        end
    else
        % --- Usa il file selezionato dalla lista ---
        percorsoShapefile = fullfile(shapefileFolder, shapefiles(fileIndex).name);
    end


    % ... Aggiungi il percorso ai parametri ...
    params.percorsoShapefile = percorsoShapefile;
    
   

    % 1. Numero di settori
    numSettori = input('Inserisci il numero di settori (es. 3): ');
    while ~isscalar(numSettori) || ~isnumeric(numSettori) || numSettori < 1 || floor(numSettori) ~= numSettori
        disp('Input non valido. Inserisci un numero intero positivo per il numero di settori.');
        numSettori = input('Inserisci il numero di settori (es. 3): ');
    end

    % 2. Antenne e Frequenze per settore (configurazione SEMPLIFICATA)
    configurazioneSettori = cell(numSettori, 1);

    frequenze_antenna_base = [700, 900, 1800, 2100, 2600];
    nomi_frequenze_antenna_base = {'700 MHz', '900 MHz', '1800 MHz', '2100 MHz', '2600 MHz'};
    frequenza_antenna_5G = 3700;
    nome_frequenza_5G = '3700 MHz (5G)';

    for settore = 1:numSettori
        configurazioneSettore = struct();
        configurazioneSettore.frequenze_base_MHz = frequenze_antenna_base;
        configurazioneSettore.include_antenna_5G = false;

        risposta_5G = input(sprintf('Settore %d: Antenna 5G (3700 MHz) presente? (s/n):\n', settore), 's');
        if lower(risposta_5G) == 's'
            configurazioneSettore.include_antenna_5G = true;
        end
        configurazioneSettori{settore} = configurazioneSettore;
    end

    % 3. Tilt Meccanico per antenna di ogni settore
    tiltMeccanicoSettori = cell(numSettori, 2);

    for settore = 1:numSettori
        promptTiltMeccanicoBase = sprintf('Settore %d, Antenna Base (multi-freq.): Inserisci tilt meccanico (gradi, positivo verso il basso):\n', settore);
        tiltMeccanicoBase = input(promptTiltMeccanicoBase);
        while ~isscalar(tiltMeccanicoBase) || ~isnumeric(tiltMeccanicoBase)
            disp('Input non valido. Inserisci un valore numerico per il tilt meccanico.');
            tiltMeccanicoBase = input(promptTiltMeccanicoBase);
        end
        tiltMeccanicoSettori{settore, 1} = tiltMeccanicoBase;

        if configurazioneSettori{settore}.include_antenna_5G
            promptTiltMeccanico5G = sprintf('Settore %d, Antenna 5G (3700 MHz): Inserisci tilt meccanico (gradi, positivo verso il basso):\n', settore);
            tiltMeccanico5G = input(promptTiltMeccanico5G);
            while ~isscalar(tiltMeccanico5G) || ~isnumeric(tiltMeccanico5G)
                disp('Input non valido. Inserisci un valore numerico per il tilt meccanico.');
                tiltMeccanico5G = input(promptTiltMeccanico5G);
            end
            tiltMeccanicoSettori{settore, 2} = tiltMeccanico5G;
        else
            tiltMeccanicoSettori{settore, 2} = NaN;
        end
    end

    % 4. Tilt Elettrico per frequenza e SETTORE!
    tiltElettricoSettori = cell(numSettori, 1);

    for settore = 1:numSettori
        tiltElettricoFrequenzeSettore = struct();
        for i = 1:length(frequenze_antenna_base)
            frequenza = frequenze_antenna_base(i);
            nome_frequenza = nomi_frequenze_antenna_base{i};
            promptTiltElettrico = sprintf('Settore %d, Tilt elettrico per frequenza %s (%d MHz) (gradi, positivo verso il basso):\n', settore, nome_frequenza, frequenza);
            tiltElettrico = input(promptTiltElettrico);
            while ~isscalar(tiltElettrico) || ~isnumeric(tiltElettrico)
                disp('Input non valido. Inserisci un valore numerico per il tilt elettrico.');
                tiltElettrico = input(promptTiltElettrico);
            end
            tiltElettricoFrequenzeSettore.(['tilt_elettrico_', num2str(frequenza), 'MHz']) = tiltElettrico;
        end

        if configurazioneSettori{settore}.include_antenna_5G
            promptTiltElettrico5G = sprintf('Settore %d, Tilt elettrico per frequenza %s (%d MHz) (gradi, positivo verso il basso):\n', settore, nome_frequenza_5G, frequenza_antenna_5G);
            tiltElettrico5G = input(promptTiltElettrico5G);
            while ~isscalar(tiltElettrico5G) || ~isnumeric(tiltElettrico5G)
                disp('Input non valido. Inserisci un valore numerico per il tilt elettrico.');
                tiltElettrico5G = input(promptTiltElettrico5G);
            end
            tiltElettricoFrequenzeSettore.(['tilt_elettrico_', num2str(frequenza_antenna_5G), 'MHz']) = tiltElettrico5G;
        end
        tiltElettricoSettori{settore} = tiltElettricoFrequenzeSettore;
    end

    % 5. Potenza Trasmessa per frequenza e per SETTORE!
    potenzaTrasmessaSettori = cell(numSettori, 1);
    configurazioneSettoriAggiornata = cell(numSettori, 1); % Nuova cell array per configurazione aggiornata

    for settore = 1:numSettori
        potenzaTrasmessaFrequenzeSettore = struct();
        configurazioneSettoreAggiornataStruct = configurazioneSettori{settore}; % Copia la configurazione esistente

        frequenze_attive_base = []; % Lista per tenere traccia delle frequenze attive
        for i = 1:length(frequenze_antenna_base)
            frequenza = frequenze_antenna_base(i);
            nome_frequenza = nomi_frequenze_antenna_base{i};
            promptPotenzaTrasmessa = sprintf('Settore %d, Potenza trasmessa per frequenza %s (%d MHz) (Watt):\n', settore, nome_frequenza, frequenza);
            potenzaTrasmessa = input(promptPotenzaTrasmessa);
            while ~isscalar(potenzaTrasmessa) || ~isnumeric(potenzaTrasmessa) || potenzaTrasmessa < 0 % Permetti potenza 0
                disp('Input non valido. Inserisci una potenza numerica positiva o zero (Watt).');
                potenzaTrasmessa = input(promptPotenzaTrasmessa);
            end
            potenzaTrasmessaFrequenzeSettore.(['potenza_trasmessa_', num2str(frequenza), 'MHz']) = potenzaTrasmessa;

            if potenzaTrasmessa > 0 % Se la potenza è maggiore di zero, considera la frequenza attiva
                frequenze_attive_base = [frequenze_attive_base, frequenza];
            end
        end
        configurazioneSettoreAggiornataStruct.frequenze_base_MHz = frequenze_attive_base; % Aggiorna le frequenze attive

        if configurazioneSettori{settore}.include_antenna_5G
            promptPotenzaTrasmessa5G = sprintf('Settore %d, Potenza trasmessa per frequenza %s (%d MHz) (Watt):\n', settore, nome_frequenza_5G, frequenza_antenna_5G);
            potenzaTrasmessa5G = input(promptPotenzaTrasmessa5G);
            while ~isscalar(potenzaTrasmessa5G) || ~isnumeric(potenzaTrasmessa5G) || potenzaTrasmessa5G < 0 % Permetti potenza 0
                disp('Input non valido. Inserisci una potenza numerica positiva o zero (Watt).');
                potenzaTrasmessa5G = input(promptPotenzaTrasmessa5G);
            end
            potenzaTrasmessaFrequenzeSettore.(['potenza_trasmessa_', num2str(frequenza_antenna_5G), 'MHz']) = potenzaTrasmessa5G;

            if potenzaTrasmessa5G == 0 % Se potenza 5G è zero, setta include_antenna_5G a false
                configurazioneSettoreAggiornataStruct.include_antenna_5G = false;
            end


            promptAlpha24_5G = sprintf('Settore %d, Fattore alpha 24 per frequenza %s (%d MHz) (es. 0.31, o Invio per default 0):\n', settore, nome_frequenza_5G, frequenza_antenna_5G);
            alpha24_5G_str = input(promptAlpha24_5G, 's');
            if isempty(alpha24_5G_str)
                alpha24_5G = 0;
            else
                alpha24_5G = str2double(alpha24_5G_str);
                if isnan(alpha24_5G) || alpha24_5G < 0 || alpha24_5G >= 1
                    disp('Input non valido per alpha 24. Usato valore di default 0.');
                    alpha24_5G = 0;
                end
            end
            potenzaTrasmessaFrequenzeSettore.alpha_24_3700MHz = alpha24_5G;

            potenzaTrasmessaFrequenzeSettore.potenza_post_alpha24_3700MHz = potenzaTrasmessa5G * (1-alpha24_5G);
        end
        potenzaTrasmessaSettori{settore} = potenzaTrasmessaFrequenzeSettore;
        configurazioneSettoriAggiornata{settore} = configurazioneSettoreAggiornataStruct; % Salva la configurazione aggiornata
    end
    params.potenzaTrasmessaSettori = potenzaTrasmessaSettori;
    params.configurazioneSettori = configurazioneSettoriAggiornata; % Sovrascrivi con la configurazione aggiornata nel params


    % 6. Altezza delle antenne da terra per settore
    altezzaAntenneSettori = cell(numSettori, 2);

    for settore = 1:numSettori
        % Altezza antenna base
        promptAltezzaBase = sprintf('Settore %d, Antenna Base (multi-freq.): Inserisci altezza dal piano di terra (metri):\n', settore);
        altezzaBase = input(promptAltezzaBase);
        while ~isscalar(altezzaBase) || ~isnumeric(altezzaBase) || altezzaBase <= 0
            disp('Input non valido. Inserisci un''altezza numerica positiva (metri).');
            altezzaBase = input(promptAltezzaBase);
        end
        altezzaAntenneSettori{settore, 1} = altezzaBase;

        % Altezza antenna 5G (se inclusa)
        if configurazioneSettori{settore}.include_antenna_5G
            promptAltezza5G = sprintf('Settore %d, Antenna 5G (3700 MHz): Inserisci altezza dal piano di terra (metri):\n', settore);
            altezza5G = input(promptAltezza5G);
            while ~isscalar(altezza5G) || ~isnumeric(altezza5G) || altezza5G <= 0
                disp('Input non valido. Inserisci un''altezza numerica positiva (metri).');
                altezza5G = input(promptAltezza5G);
            end
            altezzaAntenneSettori{settore, 2} = altezza5G;
        else
            altezzaAntenneSettori{settore, 2} = NaN;
        end
    end

    % 7. Direzione azimutale dei settori
    direzioniAzimutaliSettori = zeros(1, numSettori);
    for settore = 1:numSettori
        promptDirezione = sprintf('Inserisci la direzione azimutale (gradi, 0°=Nord) per il settore %d:\n', settore);
        direzioneAzimutale = input(promptDirezione);
        while ~isscalar(direzioneAzimutale) || ~isnumeric(direzioneAzimutale) || direzioneAzimutale < 0 || direzioneAzimutale >= 360
            disp('Input non valido. Inserisci una direzione azimutale numerica tra 0 e 360 gradi.');
            direzioneAzimutale = input(promptDirezione);
        end
        % Correzione azimuth all'input
        direzioneAzimutaleCorretta = direzioneAzimutale;
        direzioniAzimutaliSettori(settore) = mod(direzioneAzimutaleCorretta, 360);
    end

   

   


    % 9. Coordinate del punto di misura
    distanzaMisura = input('Inserisci la distanza del punto di misura dalla stazione radio base (metri):\n');
    while ~isscalar(distanzaMisura) || ~isnumeric(distanzaMisura) || distanzaMisura <= 0
        disp('Input non valido. Inserisci una distanza numerica positiva (metri).');
        distanzaMisura = input(promptDistanzaMisura);
    end

    azimuthMisura = input('Inserisci l''azimuth del punto di misura (gradi, 0°=Nord):\n');
    while ~isscalar(azimuthMisura) || ~isnumeric(azimuthMisura) || azimuthMisura < 0 || azimuthMisura >= 360
        disp('Input non valido. Inserisci un azimuth numerico tra 0 e 360 gradi.');
        azimuthMisura = input(promptAzimuthMisura);
    end
    % Correzione azimuth punto misura
    azimuthMisuraCorretto = azimuthMisura;
    azimuthMisura = mod(azimuthMisuraCorretto, 360);


    elevazioneMisura = input('Inserisci l''elevazione del punto di misura rispetto al piano di terra (metri):\n');
    while ~isscalar(elevazioneMisura) || ~isnumeric(elevazioneMisura)
        disp('Input non valido. Inserisci un valore numerico per l''elevazione (metri).');
        elevazioneMisura = input(promptElevazioneMisura);
    end

    % Organizza i parametri in una struttura
    params.numSettori = numSettori;
    params.configurazioneSettori = configurazioneSettoriAggiornata; % Usa la configurazione aggiornata!
    params.tiltMeccanicoSettori = tiltMeccanicoSettori;
    params.tiltElettricoSettori = tiltElettricoSettori;
    params.potenzaTrasmessaSettori = potenzaTrasmessaSettori;
    params.altezzaAntenneSettori = altezzaAntenneSettori;
    params.direzioniAzimutaliSettori = direzioniAzimutaliSettori;
    params.percorsoModelliAntenne = percorsoModelliAntenne;
    params.distanzaMisura = distanzaMisura;
    params.azimuthMisura = azimuthMisura;
    params.elevazioneMisura = elevazioneMisura;
  


    % Visualizzazione dei parametri inseriti (per verifica)
    disp('----------------------------------------');
    disp('Parametri di simulazione inseriti:');
    disp(['Numero di settori: ', num2str(numSettori)]);

    disp('Configurazione antenne per settore:');
    for settore = 1:numSettori
        disp(['  Settore ', num2str(settore), ':']);
        frequenze_base_attive = params.configurazioneSettori{settore}.frequenze_base_MHz; % Prendi le frequenze attive dalla configurazione aggiornata
        if ~isempty(frequenze_base_attive)
            disp(['    Antenna Base (multi-freq.): Frequenze ATTIVE: ', sprintf('%g MHz, ', frequenze_base_attive)]);
        else
            disp('    Antenna Base (multi-freq.): NESSUNA frequenza attiva (potenza zero).');
        end
        disp(['    Tilt Meccanico Antenna Base: ', num2str(tiltMeccanicoSettori{settore, 1}), ' gradi']);
        if params.configurazioneSettori{settore}.include_antenna_5G
            disp(['    Antenna 5G (3700 MHz): PRESENTE']);
            disp(['    Tilt Meccanico Antenna 5G: ', num2str(tiltMeccanicoSettori{settore, 2}), ' gradi']);
        else
            disp(['    Antenna 5G (3700 MHz): NON presente (potenza zero o non inclusa).']);
        end
        disp('    Tilt Elettrico per Frequenza:');
        frequenze_settore_tilt_elettrico = fieldnames(tiltElettricoSettori{settore});
        for i = 1:length(frequenze_settore_tilt_elettrico)
            nome_campo_frequenza = frequenze_settore_tilt_elettrico{i};
            tilt_value = tiltElettricoSettori{settore}.(nome_campo_frequenza);
            frequenza_MHz_str = strrep(nome_campo_frequenza, 'tilt_elettrico_', '');
            frequenza_MHz_str = strrep(frequenza_MHz_str, 'MHz', '');
            disp(['      ', frequenza_MHz_str, ' MHz: ', num2str(tilt_value), ' gradi']);
        end
    end

    disp('Potenza Trasmessa per Frequenza e Settore (Watt):');
    for settore = 1:numSettori
        disp(['  Settore ', num2str(settore), ':']);
        frequenze_potenza_trasmessa_settore = fieldnames(potenzaTrasmessaSettori{settore});
        for i = 1:length(frequenze_potenza_trasmessa_settore)
            nome_campo_potenza = frequenze_potenza_trasmessa_settore{i};
            if startsWith(nome_campo_potenza, 'potenza_trasmessa_')
                potenza_value = potenzaTrasmessaSettori{settore}.(nome_campo_potenza);
                frequenza_MHz_str = strrep(nome_campo_potenza, 'potenza_trasmessa_', '');
                frequenza_MHz_str = strrep(frequenza_MHz_str, 'MHz', '');
                disp(['    ', frequenza_MHz_str, ' MHz: ', num2str(potenza_value), ' Watt']);
            elseif strcmp(nome_campo_potenza, 'alpha_24_3700MHz')
                alpha24_value = potenzaTrasmessaSettori{settore}.(nome_campo_potenza);
                disp(['    3700 MHz - Fattore Alpha 24: ', num2str(alpha24_value)]);
            elseif strcmp(nome_campo_potenza, 'potenza_post_alpha24_3700MHz')
                potenza_post_alpha24 = potenzaTrasmessaSettori{settore}.(nome_campo_potenza);
                disp(['    3700 MHz - Potenza post Alpha 24: ', num2str(potenza_post_alpha24), ' Watt']);
            end
        end
    end


    disp('Altezza delle Antenne dal Piano di Terra (metri):');
    for settore = 1:numSettori
        disp(['  Settore ', num2str(settore), ':']);
        disp(['    Antenna Base (multi-freq.): Altezza: ', num2str(altezzaAntenneSettori{settore, 1}), ' metri']);
        if params.configurazioneSettori{settore}.include_antenna_5G
            disp(['    Antenna 5G (3700 MHz): Altezza: ', num2str(altezzaAntenneSettori{settore, 2}), ' metri']);
        else
            disp(['    Antenna 5G (3700 MHz): NON inclusa']);
        end
    end


    disp(['Direzioni azimutali dei settori (gradi): ', num2str(direzioniAzimutaliSettori)]);
    disp(['Percorso cartella modelli antenne: ', percorsoModelliAntenne]);
    disp(['Distanza punto di misura (metri): ', num2str(distanzaMisura)]);
    disp(['Azimuth punto di misura (gradi): ', num2str(azimuthMisura)]);
    disp(['Elevazione punto di misura (metri): ', num2str(elevazioneMisura)]);
    disp('----------------------------------------');

    disp('Parametri acquisiti con successo.  Possiamo procedere con la simulazione!');

end