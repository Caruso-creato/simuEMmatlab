function [srb, datiEdifici, puntiMisuraSettori] = calcolaSistemaDiRiferimento(params, puntiMisuraSettori)
    fprintf('🔧 Inizializzazione del sistema di riferimento...\n');

    % --- 1. Posizionamento della SRB al centro ---
    srb.x = 27;
    srb.y = 5;

    % --- 2. Caricamento dello shapefile ---
    fprintf('📂 Caricamento dello shapefile...\n');
    datiEdifici = leggiDatiShapefile(params.percorsoShapefile);

    fprintf('🌍 Trasformazione delle coordinate degli edifici...\n');
    datiEdifici = trasformaCoordinateEdifici(datiEdifici, srb);

% Trasforma le coordinate rispetto al centro della SRB
for settore = 1:length(puntiMisuraSettori)
    punto = puntiMisuraSettori(settore).punto_misura_xyz;

    % Correggi le coordinate relative rispetto alla SRB
    puntiMisuraSettori(settore).punto_misura_xyz_rel = [puntiMisuraSettori(settore).punto_misura_xyz(1) - srb.x, ...
                                                     puntiMisuraSettori(settore).punto_misura_xyz(2) - srb.y, ...
                                                     puntiMisuraSettori(settore).punto_misura_xyz(3)];

fprintf('DEBUG: SRB posizionata a X = %.2f, Y = %.2f\n', srb.x, srb.y);
fprintf('DEBUG: Settore %d - Coordinate RELATIVE finali rispetto alla SRB: X = %.2f, Y = %.2f, Z = %.2f\n', ...
        settore, puntiMisuraSettori(settore).punto_misura_xyz_rel(1), ...
        puntiMisuraSettori(settore).punto_misura_xyz_rel(2), ...
        puntiMisuraSettori(settore).punto_misura_xyz_rel(3));

    % Debug per confermare le coordinate relative
    fprintf('DEBUG: Settore %d - Coordinate relative rispetto alla SRB (corrette): X = %.2f, Y = %.2f, Z = %.2f\n', ...
            settore, puntiMisuraSettori(settore).punto_misura_xyz_rel(1), ...
            puntiMisuraSettori(settore).punto_misura_xyz_rel(2), ...
            puntiMisuraSettori(settore).punto_misura_xyz_rel(3));
end
% --- Plot completo usando la funzione esterna ---
plottaAmbienteSimulazione(srb, datiEdifici, puntiMisuraSettori, params);


    fprintf('✅ Sistema di riferimento creato e plottato correttamente!\n');
end
