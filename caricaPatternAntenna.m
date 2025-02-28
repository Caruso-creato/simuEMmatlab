function antennaData_temp = caricaPatternAntenna(filename)
    % Apri il file
    fid = fopen(filename, 'r');
    if fid == -1
        error('Errore nell''apertura del file.');
    end
    
    % Inizializza la struttura dati
    antennaData_temp = struct();
    antennaData_temp.horizontal = [];
    antennaData_temp.vertical = [];
    antennaData_temp.beamwidth = NaN; 

    try
        % Legge le intestazioni
        while ~feof(fid)
            line = strtrim(fgetl(fid));
            if startsWith(line, 'HORIZONTAL')
                break;
            elseif startsWith(line, 'NAME ')
                antennaData_temp.name = extractAfter(line, 'NAME ');
            elseif startsWith(line, 'MAKE ')
                antennaData_temp.make = extractAfter(line, 'MAKE ');
            elseif startsWith(line, 'FREQUENCY ')
                antennaData_temp.frequency = str2double(extractAfter(line, 'FREQUENCY '));
            elseif startsWith(line, 'GAIN ') && contains(line, 'dBd')
                antennaData_temp.gain_dBd = str2double(extractBefore(extractAfter(line, 'GAIN '), ' dBd'));
            elseif startsWith(line, 'GAIN ') && contains(line, 'dBi')
                antennaData_temp.gain_dBi = str2double(extractBefore(extractAfter(line, 'GAIN '), ' dBi'));
            elseif startsWith(line, 'TILT ELECTRICAL')
                antennaData_temp.tilt = str2double(extractAfter(line, 'TILT ELECTRICAL '));
            elseif startsWith(line, 'ELECTRICAL_TILT ')
                if ~isfield(antennaData_temp, 'tilt') || isnan(antennaData_temp.tilt) % Evita la sovrascrittura
                    antennaData_temp.tilt = str2double(extractAfter(line, 'ELECTRICAL_TILT '));
                end
            elseif startsWith(line, 'POLARIZATION ')
                antennaData_temp.polarization = extractAfter(line, 'POLARIZATION ');
            elseif startsWith(line, 'COMMENT ')
                antennaData_temp.comment = extractAfter(line, 'COMMENT ');
            elseif startsWith(line, 'BEAM_WIDTH ') % Aggiunta lettura BEAM_WIDTH
                antennaData_temp.beamwidth = str2double(extractAfter(line, 'BEAM_WIDTH '));
            end
        end

        % Legge i dati del lobo orizzontale
        while ~feof(fid)
            line = strtrim(fgetl(fid));
            if startsWith(line, 'VERTICAL')
                break;
            end
            data_cell = textscan(line, '%f%f');
            if numel(data_cell) == 2 && ~isempty(data_cell{1}) && ~isempty(data_cell{2})
                antennaData_temp.horizontal = [antennaData_temp.horizontal; data_cell{1}(1), data_cell{2}(1)];
            end
        end

       % Legge i dati del lobo verticale
while ~feof(fid)
    line = strtrim(fgetl(fid));
    data_cell = textscan(line, '%f%f');
    if numel(data_cell) == 2 && ~isempty(data_cell{1}) && ~isempty(data_cell{2})
        antennaData_temp.vertical = [antennaData_temp.vertical; data_cell{1}(1), data_cell{2}(1)]; % Inverti solo il segno dell'angolo
    end
end
        
    catch ME
        fclose(fid);
        rethrow(ME); % Riporta l'errore originale
    end

    % Chiude il file
    fclose(fid);
end
