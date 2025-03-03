function gain_dBi = interpolateGain(antennaData, azimuth, elevation)

    fprintf('DEBUG: interpolateGain - Input:\n');
    fprintf('  antennaData.gain_dBi: %.2f\n', antennaData.gain_dBi);
    fprintf('  antennaData.horizontal (primi 5 elementi):\n');
    disp(antennaData.horizontal(1:min(5,end), :)); % Stampa le prime 5 righe (o meno, se ci sono meno di 5 righe)
    fprintf('  antennaData.vertical (primi 5 elementi):\n');
    disp(antennaData.vertical(1:min(5,end), :)); % Stampa le prime 5 righe (o meno)
    fprintf(' interpolateGain: Input azimuth: %.2f gradi\n', azimuth);
fprintf(' interpolateGain: Input elevation: %.2f gradi\n', elevation);

    % Interpola il guadagno dell'antenna e lo RESTITUISCE IN dBi.
    % Input:
    %   antennaData: Dati dell'antenna (struttura, da loadAntennaData).
    %   azimuth: Angolo azimutale (gradi).
    %   elevation: Angolo di elevazione (gradi).
    % Output:
    %   gain_dBi: Guadagno interpolato (in dBi).

    % APPLICA OPERAZIONE MODULO PER "WRAPP" GLI ANGOLI ALL'INTERVALLO 0-360
    azimuth_wrapped = mod(azimuth, 360);
   elevation_wrapped = abs(elevation); % Trasforma angoli negativi in positivi

% Interpolazione orizzontale (attenuazione)
    attenuation_h_dB = interp1(antennaData.horizontal(:,1), antennaData.horizontal(:,2), azimuth_wrapped, 'linear', 'extrap'); % Usa angoli "wrapped"
    fprintf('      interpolateGain: Attenuazione orizzontale: %.2f dB\n', attenuation_h_dB); % DEBUG

   % Interpolazione verticale (attenuazione)
    attenuation_v_dB = interp1(antennaData.vertical(:,1), antennaData.vertical(:,2), elevation_wrapped, 'linear', 'extrap');  % Usa angoli "wrapped"
    fprintf('      interpolateGain: Attenuazione verticale: %.2f dB\n', attenuation_v_dB); % DEBUG
    
    
    % Calcola il guadagno totale (sottrai attenuazioni dal guadagno massimo *in dBi*)
    gain_dBi = antennaData.gain_dBi - attenuation_h_dB - attenuation_v_dB; % ORA USA DIRETTAMENTE gain_dBi!
end