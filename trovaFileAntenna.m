function [nomi_file, tilt_elettrici] = trovaFileAntenna(percorso, frequenza, tilt_utente)
    % TROVAFILEANTENNA - Trova il file di antenna più vicino alla frequenza e tilt richiesto.
    % Se il tilt esatto esiste, restituisce solo quel file.
    % Se il tilt è molto diverso (>3°), restituisce solo il file più vicino.
    % Se il tilt è tra due valori vicini, restituisce due file per interpolazione.

    nomi_file = {};
    tilt_elettrici = [];

    % **1. Carica tutti i file disponibili nella cartella**
    files = dir(fullfile(percorso, '*.txt'));  

    % **2. Filtra i file per la frequenza richiesta**
    files_frequenza_corretta = {};
    tilt_disponibili = [];

    for i = 1:length(files)
        nome_file = files(i).name;
        [freq_file, tilt_file] = estraiFrequenzaETilt(nome_file);

        if freq_file == frequenza
            files_frequenza_corretta{end+1} = nome_file;
            tilt_disponibili = [tilt_disponibili, tilt_file];
        end
    end

    % **3. Se non ci sono file con la frequenza richiesta, restituisci NaN**
    if isempty(files_frequenza_corretta)
        warning('trovaFileAntenna: Nessun file trovato per la frequenza %d MHz.', frequenza);
        nomi_file = {''};
        tilt_elettrici = NaN;
        return;
    end

    % **4. Ordina i file per distanza dal tilt richiesto**
    [~, idx] = sort(abs(tilt_disponibili - tilt_utente));
    nomi_file = files_frequenza_corretta(idx);
    tilt_elettrici = tilt_disponibili(idx);

    % **Debug: Stampiamo i tilt disponibili per verificare i dati**
    disp(['DEBUG: Tilt disponibili per ', num2str(frequenza), ' MHz -> ', num2str(tilt_elettrici)]);

    % **5. Se esiste un tilt esatto, restituiamo solo quel file**
    if tilt_elettrici(1) == tilt_utente
        nomi_file = {nomi_file{1}};
        tilt_elettrici = tilt_elettrici(1);

    % **6. Se il tilt richiesto è molto diverso (>3°), restituiamo solo il file più vicino**
    elseif abs(tilt_elettrici(1) - tilt_utente) > 3 || length(tilt_elettrici) == 1
        nomi_file = {nomi_file{1}};
        tilt_elettrici = tilt_elettrici(1);
        warning('trovaFileAntenna: Tilt utente %f molto diverso dai tilt disponibili. Usando file con tilt più vicino: %f gradi.', tilt_utente, tilt_elettrici(1));

    % **7. Se il tilt richiesto è vicino a due valori, restituiamo i due più vicini**
    else
        nomi_file = nomi_file(1:2);
        tilt_elettrici = tilt_elettrici(1:2);
    end

    % **Debug: Mostriamo il file selezionato**
    disp(['DEBUG: File selezionato per ', num2str(frequenza), ' MHz -> ', strjoin(nomi_file, ', '), ', Tilt: ', num2str(tilt_elettrici)]);
end
