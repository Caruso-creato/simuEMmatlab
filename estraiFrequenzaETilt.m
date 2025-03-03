function [freq, tilt] = estraiFrequenzaETilt(nome_file)
%ESTRAIFREQUENZAETILT Estrae frequenza e tilt elettrico dal nome del file antenna.
%   [freq, tilt] = estraiFrequenzaETilt(nome_file) estrae la frequenza (MHz)
%   e il tilt elettrico (gradi) dal nome del file dell'antenna.

    freq = NaN;
    tilt = NaN;

    % Utilizza espressioni regolari per estrarre frequenza e tilt
    match = regexp(nome_file, '(\d+)MHz_tilt_(-?\d+)', 'tokens'); % Formato con _tilt_
    if ~isempty(match)
         freq = str2double(match{1}{1});
         tilt_str = match{1}{2}; % Ottieni la stringa del tilt
         tilt_temp = str2double(tilt_str); % Prova a convertirla in numero
         if ~isnan(tilt_temp) % VALIDAZIONE ESPLICITA: Verifica se la conversione ha avuto successo
             tilt = tilt_temp; % Se conversione OK, usa il valore numerico
         else
             tilt = NaN; % Altrimenti, imposta tilt a NaN (input non valido)
             warning(['estraiFrequenzaETilt: Tilt non valido nel nome file: ', nome_file, '. Impostato tilt a NaN.']); % Warning opzionale
         end


    else
        match = regexp(nome_file, '_(\d+)_(-?\d+)', 'tokens'); % Formato _frequenza_tilt (senza MHz)
        if ~isempty(match)
            freq = str2double(match{1}{1});
            tilt_str = match{1}{2}; % Ottieni la stringa del tilt
            tilt_temp = str2double(tilt_str); % Prova a convertirla in numero
            if ~isnan(tilt_temp) % VALIDAZIONE ESPLICITA: Verifica se la conversione ha avuto successo
                tilt = tilt_temp; % Se conversione OK, usa il valore numerico
            else
                tilt = NaN; % Altrimenti, imposta tilt a NaN (input non valido)
                warning(['estraiFrequenzaETilt: Tilt non valido nel nome file: ', nome_file, '. Impostato tilt a NaN.']); % Warning opzionale
            end
        else
             match = regexp(nome_file, '(\d+)MHz', 'tokens'); % Formato solo con frequenza (MHz)
             if ~isempty(match)
                freq = str2double(match{1}{1});
                tilt = 0;  % Tilt di default se non specificato
             end
        end
    end
end 