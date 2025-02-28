% SIMULATORE SRB - Calcolo campo elettromagnetico con contributi in V/m e visualizzazione in Command Window

clear; close all; clc;

if exist('sistemaRiferimento.mat', 'file')
    delete('sistemaRiferimento.mat');
    fprintf('🗑️  File sistemaRiferimento.mat eliminato per forzare la rigenerazione.\n');
end

% --- 1. Generazione o caricamento dati ---
if ~exist('sistemaRiferimento.mat', 'file')
    fprintf('⚠️  File sistemaRiferimento.mat non trovato. Generazione in corso...\n');
    gestisciDatiSimulazione();
end

fprintf('🔧 Caricamento del sistema di riferimento...\n');
load('sistemaRiferimento.mat', 'srb', 'datiEdifici', 'puntiMisuraSettori', 'params');
fprintf('✅ Sistema di riferimento caricato con successo!\n');

% Inizializza il campo totale
campo_totale_Vm = 0;
campo_totale_punto_misura_Vm = 0; % Campo elettrico totale per il punto di misura

% Inizializza la tabella dei risultati
results = [];

% --- 2. Calcolo del campo per ogni settore e frequenza ---
for settore = 1:params.numSettori
    fprintf('📡 Calcolo per il settore %d...\n', settore);
    
    punto_misura_xyz = puntiMisuraSettori(settore).punto_misura_xyz;
    azimuth_relativo = puntiMisuraSettori(settore).azimuth_relativo;
    altezza_antenna = params.altezzaAntenneSettori{settore, 1};
    
    % Elevazione relativa
    z_diff_relativa = punto_misura_xyz(3) - altezza_antenna;
    d_orizzontale = sqrt((punto_misura_xyz(1))^2 + (punto_misura_xyz(2))^2);
    elevazione_relativa = atan2d(z_diff_relativa, d_orizzontale);
    
    % Frequenze attive
    frequenze_attive = params.configurazioneSettori{settore}.frequenze_base_MHz;
    
    campo_totale_settore_Vm = 0; % Campo elettrico totale per il settore

    % Loop sulle frequenze
    for freq_index = 1:length(frequenze_attive)
        frequenza = frequenze_attive(freq_index);
        fprintf('  🔬 Calcolo per la frequenza %d MHz...\n', frequenza);

        distanza_3d = sqrt((punto_misura_xyz(1))^2 + (punto_misura_xyz(2))^2 + (punto_misura_xyz(3) - altezza_antenna)^2);

        antennaPatternFunction = getAntennaPattern(params, frequenza, params.tiltElettricoSettori{settore}.(['tilt_elettrico_', num2str(frequenza), 'MHz']));
        guadagno_antenna_dBi = antennaPatternFunction(azimuth_relativo, elevazione_relativa);

        path_loss_dB = calcolaPathLoss(params, frequenza, distanza_3d, altezza_antenna, punto_misura_xyz(3));

        params.current_settore = settore;
        params.current_frequenza = frequenza;
        params.distanza_3d = distanza_3d;
        [campo_parziale_Vm, campo_parziale_dB] = calcolaCampoElettrico(params, guadagno_antenna_dBi, path_loss_dB);
        campo_totale_settore_Vm = sqrt(campo_totale_settore_Vm^2 + campo_parziale_Vm^2);
        campo_totale_Vm = sqrt(campo_totale_Vm^2 + campo_parziale_Vm^2);
        
        campo_totale_punto_misura_Vm = sqrt(campo_totale_punto_misura_Vm^2 + campo_totale_settore_Vm^2);

        azimuth_assoluto = params.direzioniAzimutaliSettori(settore); % Azimuth assoluto del settore
        
        results = [results; settore, frequenza, params.tiltElettricoSettori{settore}.(['tilt_elettrico_', num2str(frequenza), 'MHz']), ...
                   params.tiltMeccanicoSettori{settore}, azimuth_assoluto, campo_parziale_Vm, campo_totale_settore_Vm];
    end
end

% --- 3. Risultati finali ---
fprintf('\n⚡ Campo elettrico totale nel punto di misura: %.6f V/m (%.2f dB)\n', ...
    campo_totale_punto_misura_Vm, 20*log10(campo_totale_punto_misura_Vm));

fprintf('\n📊 Tabella dei Risultati:\n');
fprintf('------------------------------------------------------------------------------------------------------------\n');
fprintf('| Settore | Frequenza (MHz) | Tilt Elettrico | Tilt Meccanico | Azimuth | Campo Parziale (V/m) | Campo Totale Settore (V/m) |\n');
fprintf('------------------------------------------------------------------------------------------------------------\n');

for i = 1:size(results, 1)
    fprintf('| %7d | %15d | %13d | %13d | %7d | %20.6f | %20.6f |\n', results(i, :));
end

fprintf('------------------------------------------------------------------------------------------------------------\n');
fprintf('| TOTALE  | -               | -             | -             | -      | -                     | %20.6f |\n', campo_totale_punto_misura_Vm);
fprintf('------------------------------------------------------------------------------------------------------------\n');

% --- 4. Salvataggio tabella in CSV ---
tabella_risultati = array2table(results, ...
    'VariableNames', {'Settore', 'Frequenza_MHz', 'Tilt_Elettrico', 'Tilt_Meccanico', 'Azimuth', 'Campo_Parziale_Vm', 'Campo_Totale_Settore_Vm'});

totale_riga = {NaN, NaN, NaN, NaN, NaN, NaN, campo_totale_punto_misura_Vm};
tabella_risultati = [tabella_risultati; totale_riga];

writetable(tabella_risultati, 'risultati_simulazione.csv');
fprintf('📁 Risultati salvati in "risultati_simulazione.csv"\n');

% --- 5. Cleanup ---
if exist('sistemaRiferimento.mat', 'file')
    delete('sistemaRiferimento.mat');
    fprintf('🗑️  File sistemaRiferimento.mat eliminato dopo la simulazione.\n');
end