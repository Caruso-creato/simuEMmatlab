function antennaPatternFunction = getAntennaPattern(params, frequenza, tilt_elettrico_richiesto)
%GETANTENNAPATTERN Funzione per caricare e gestire i pattern di antenna.
%   Gestisce sia l'antenna multifrequenza (con interpolazione del tilt, se necessario)
%   sia l'antenna 5G (caricando sempre il file dedicato).

    antennaPatternFunction = @(azimuth_relativo, elevazione_relativa) NaN;

    % --- Caso Antenna 5G (3700 MHz) ---
    if frequenza == 3700
        nome_file_5g = 'AEQE-V3-H90.txt';
        percorso_completo_5g = fullfile(params.percorsoModelliAntenne, nome_file_5g);

        try
            antennaData_5g = loadAntennaData(percorso_completo_5g); 
            antennaPatternFunction = @(azimuth_relativo, elevazione_relativa) interpolateGain(antennaData_5g, azimuth_relativo, elevazione_relativa);
        catch ME
            warning('getAntennaPattern: Impossibile caricare il file antenna 5G (%s): %s', nome_file_5g, ME.message);
        end
        return;
    end

    % --- Caso Antenna Multifrequenza ---
    nomi_file_antenna = trovaFileAntenna(params.percorsoModelliAntenne, frequenza, tilt_elettrico_richiesto);

    if isempty(nomi_file_antenna)
        warning('getAntennaPattern: Nessun file pattern antenna trovato per %d MHz.', frequenza);
        return;
    elseif length(nomi_file_antenna) == 1
        nome_file = nomi_file_antenna{1};
        percorso_completo_file = fullfile(params.percorsoModelliAntenne, nome_file);
        antennaData = loadAntennaData(percorso_completo_file);
        antennaPatternFunction = @(azimuth_relativo, elevazione_relativa) interpolateGain(antennaData, azimuth_relativo, elevazione_relativa);
    else
        nome_file1 = nomi_file_antenna{1};
        nome_file2 = nomi_file_antenna{2};
        percorso_completo_file1 = fullfile(params.percororsoModelliAntenne, nome_file1);
        percorso_completo_file2 = fullfile(params.percororsoModelliAntenne, nome_file2);

        antennaData1 = loadAntennaData(percorso_completo_file1);
        antennaData2 = loadAntennaData(percorso_completo_file2);

        tilt1 = antennaData1.tilt;
        tilt2 = antennaData2.tilt;

        % Se i tilt sono uguali, usa direttamente uno dei due
        if tilt1 == tilt2
            antennaPatternFunction = @(azimuth_relativo, elevazione_relativa) interpolateGain(antennaData1, azimuth_relativo, elevazione_relativa);
            return;
        end

        % Interpolazione tra due file antenna
        antennaData_interp = antennaData1;
        antennaData_interp.tilt = tilt_elettrico_richiesto;

        % Interpolazione Orizzontale
        for i = 1:size(antennaData1.horizontal, 1)
            angolo = antennaData1.horizontal(i, 1);
            gain1_dB = antennaData1.horizontal(i, 2);
            gain2_dB = interp1(antennaData2.horizontal(:,1), antennaData2.horizontal(:,2), angolo, 'linear', 'extrap');
            gain_interp_dB = gain1_dB + (gain2_dB - gain1_dB) * (tilt_elettrico_richiesto - tilt1) / (tilt2 - tilt1);
            antennaData_interp.horizontal = [antennaData_interp.horizontal; angolo, gain_interp_dB];
        end

        % Interpolazione Verticale
        for i = 1:size(antennaData1.vertical, 1)
            angolo = antennaData1.vertical(i, 1);
            gain1_dB = antennaData1.vertical(i, 2);
            gain2_dB = interp1(antennaData2.vertical(:,1), antennaData2.vertical(:,2), angolo, 'linear', 'extrap');
            gain_interp_dB = gain1_dB + (gain2_dB - gain1_dB) * (tilt_elettrico_richiesto - tilt1) / (tilt2 - tilt1);
            antennaData_interp.vertical = [antennaData_interp.vertical; angolo, gain_interp_dB];
        end

        antennaPatternFunction = @(azimuth_relativo, elevazione_relativa) interpolateGain(antennaData_interp, azimuth_relativo, elevazione_relativa);
    end

    fprintf('DEBUG: Funzione di pattern caricata con tilt elettrico %.2f°\n', tilt_elettrico_richiesto);
end