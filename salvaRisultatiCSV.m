function salvaRisultatiCSV(results, nome_file)
    % Apri il file CSV in scrittura
    fid = fopen(nome_file, 'w');

    % Intestazione del CSV con la nuova colonna
    fprintf(fid, 'Settore,Frequenza (MHz),Potenza TX (W),Tilt Elettrico (°),Tilt Meccanico (°),Azimuth Settore (°),Distanza Punto Misura (m),Azimuth Punto Misura (°),Altezza Punto Misura (m),Modello Propagazione,Path Loss (dB),Guadagno Antenna (dBi),Campo Elettrico (V/m),Campo Elettrico (dB),Num Ostacoli,Ambiente,Campo Elettrico Totale (V/m)\n');

    % Calcolo del campo elettrico totale per ogni settore
    settori = unique(cell2mat(results(:,1))); % Trova i settori unici
    campo_totale_settore = containers.Map('KeyType', 'double', 'ValueType', 'double');

    for i = 1:length(settori)
        settore = settori(i);
        campi_settore = cell2mat(results(cell2mat(results(:,1)) == settore, 13)); % Estrai i campi elettrici di quel settore
        campo_totale_settore(settore) = sqrt(sum(campi_settore.^2)); % Somma quadratica
    end

    % Scrittura dati nel file CSV
    for i = 1:size(results, 1)
        settore = results{i, 1};
        campo_totale = campo_totale_settore(settore);

        fprintf(fid, '%d,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%s,%.2f,%.2f,%.10f,%.2f,%d,%s,%.10f\n', ...
            results{i, :}, campo_totale);
    end

    % Chiudi il file
    fclose(fid);
    fprintf('📁 Risultati esportati in %s con il campo elettrico totale per settore\n', nome_file);
end
