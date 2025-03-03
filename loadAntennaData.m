function antennaData = loadAntennaData(filePath)
%LOADANTENNADATA Carica i dati dell'antenna usando caricaPatternAntenna e gestisce gain.

    try
        % Chiama la funzione caricaPatternAntenna per caricare i dati dal file
        antennaData_temp = caricaPatternAntenna(filePath); % NOME FUNZIONE CAMBIATO!

        % Estrai frequenza e tilt dal nome del file
        [~, filename, ext] = fileparts(filePath);
        [antennaData.frequency, antennaData.tilt] = estraiFrequenzaETilt([filename, ext]);

        % Copia/trasferisci i dati da antennaData_temp a antennaData
        antennaData.name = antennaData_temp.name;
         if isfield(antennaData_temp, 'gain_dBi')
            antennaData.gain_dBi = antennaData_temp.gain_dBi; 
        elseif isfield(antennaData_temp, 'gain_dBd')
            antennaData.gain_dBi = antennaData_temp.gain_dBd + 2.15; 
        else
            antennaData.gain_dBi = NaN; 
            warning('loadAntennaData: File antenna senza GAIN in dBd o dBi.');
         end
        antennaData.beamwidth = antennaData_temp.beamwidth;
        antennaData.horizontal = antennaData_temp.horizontal;
        antennaData.vertical = antennaData_temp.vertical;


    catch ME
        error('Errore nel caricamento del file antenna (usando caricaPatternAntenna): %s\n%s', filePath, ME.message); % NOME FUNZIONE CAMBIATO nel messaggio di errore
    end
end