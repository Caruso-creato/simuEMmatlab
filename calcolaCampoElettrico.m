function [campo_parziale_Vm, campo_parziale_dB] = calcolaCampoElettrico(params, guadagno_antenna_dBi, path_loss_totale_dB)
    % Potenza trasmessa
    settore = params.current_settore;
    frequenza = params.current_frequenza;

    if frequenza == 3700
        Ptx = params.potenzaTrasmessaSettori{settore}.potenza_post_alpha24_3700MHz;
    else
        Ptx = params.potenzaTrasmessaSettori{settore}.(['potenza_trasmessa_', num2str(frequenza), 'MHz']);
    end

    % Guadagno antenna (convertito in lineare)
    Gtx = 10^(guadagno_antenna_dBi / 10);

    % Distanza 3D
    d = params.distanza_3d;

    % DEBUG: Stampiamo i valori
    fprintf('🔎 DEBUG Campo Elettrico:\n  - Ptx: %.6f W\n', Ptx);
    fprintf('  - Gtx (lineare): %.6f\n', Gtx);
    fprintf('  - La distanza finale usata nela calcolo è quella 3D che tiene conto anche dell''altezza d: %.6f m\n', d);
    fprintf('  - Path Loss dB: %.6f dB\n', path_loss_totale_dB);
    fprintf('  - Attenuazione Lineare: %.10f\n', 10^(-path_loss_totale_dB/20));

    % Calcolo del Campo Elettrico (E)
    E = sqrt((Ptx * Gtx * 30) / (d^2)) * 10^(-path_loss_totale_dB/20);
    campo_parziale_Vm = E;
    campo_parziale_dB = 20 * log10(E);

    % Visualizzazione
    fprintf('  - Campo calcolato: %.10f V/m (%.2f dB)\n', E, campo_parziale_dB);
end
