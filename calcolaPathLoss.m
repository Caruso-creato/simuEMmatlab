function path_loss_dB = calcolaPathLoss(params, frequenza, distanza, altezza_antenna, altezza_punto_misura)
%CALCOLAPATHLOSS Calcola il path loss (attenuazione del segnale) utilizzando diversi modelli.
%   path_loss_dB = CALCOLAPATHLOSS(params, frequenza, distanza, altezza_antenna, altezza_punto_misura)
%   calcola il path loss in dB tra SRB e punto di misura, scegliendo il modello
%   di propagazione in base a params.propagation_model.
%
%   Input:
%     params - Struttura dei parametri di simulazione.
%     frequenza - Frequenza di trasmissione in MHz.
%     distanza - Distanza tra SRB e punto di misura in metri.
%     altezza_antenna - Altezza dell'antenna trasmittente in metri.
%     altezza_punto_misura - Altezza del punto di misura (ricevente) in metri.  <-- NUOVO INPUT ESPLICITO
%
%   Output:
%     path_loss_dB - Path loss calcolato in dB.

% Controllo se il campo 'environment_type' è definito
if ~isfield(params, 'environment_type')
    error('Il tipo di ambiente non è stato definito automaticamente.');
end


    modello = params.propagation_model;

    switch modello
        case 'COST 231-Hata'
            path_loss_dB = calcolaCOST231Hata(params, frequenza, distanza, altezza_antenna, altezza_punto_misura); % Passa altezza_punto_misura

        case 'COST 231-Hata + Attenuazione Ostacoli'
            path_loss_dB = calcolaCOST231Hata(params, frequenza, distanza, altezza_antenna, altezza_punto_misura); % Passa altezza_punto_misura

            % Attenuazione per ostacoli
            if isfield(params, 'numOstacoli')
                attenuazione_ostacoli = params.numOstacoli * 10; % 10 dB per ostacolo
                if isfield(params, 'altezzaEdificio') && params.altezzaEdificio > altezza_punto_misura % Usa altezza_punto_misura
                    attenuazione_ostacoli = attenuazione_ostacoli + calcolaDiffrazioneKnifeEdge(params.altezzaEdificio, altezza_punto_misura, distanza); % Usa altezza_punto_misura
                end
                path_loss_dB = path_loss_dB + attenuazione_ostacoli;
            end

        case 'ITU-R P.1238'
            path_loss_dB = calcolaITU1238(params, frequenza, distanza, altezza_antenna); % Altezza punto misura non rilevante per ITU-R P.1238

        otherwise
            error('Modello di propagazione non valido: %s', modello);
    end
end


% --- Modello COST 231-Hata ---
function path_loss_dB = calcolaCOST231Hata(params, f_MHz, distanza, hb_m, hm_m)
%CALCOLACOST231HATA Calcola il path loss con il modello COST 231-Hata.
%   path_loss_dB = CALCOLACOST231HATA(params, f_MHz, distanza, hb_m, hm_m)
%   Implementazione del modello COST 231-Hata per il calcolo del path loss.
%
%   Input:
%     params - Struttura dei parametri di simulazione.
%     f_MHz - Frequenza in MHz.
%     distanza - Distanza in metri.
%     hb_m - Altezza antenna trasmittente in metri.
%     hm_m - Altezza antenna ricevente (punto di misura) in metri.  <-- NUOVO INPUT ESPLICITO
%
%   Output:
%     path_loss_dB - Path loss calcolato in dB.

    % Converti la distanza in chilometri
    d_km = distanza / 1000;

    % 🔍 Fattore di correzione per l'altezza del ricevitore (ORA USA hm_m INPUT)
    a_hm = (1.1 * log10(f_MHz) - 0.7) * hm_m - (1.56 * log10(f_MHz) - 0.8);

    % 🔍 Caso speciale per ambiente urbano grande città
    if strcmp(params.environment_type, 'Urbano (grande città)')
        if f_MHz >= 1500 && f_MHz <= 2000
            a_hm = 8.29 * (log10(1.54 * hm_m))^2 - 1.1;
        elseif f_MHz > 2000 && f_MHz <= 3000
            a_hm = 3.2 * (log10(11.75 * hm_m))^2 - 4.97;
        end
    end

    % 🔧 Selezione della costante C in base al tipo di ambiente
if strcmp(params.environment_type, 'Urbano (grande città)')
    C = 3;
elseif strcmp(params.environment_type, 'Urbano')
    C = 0;
elseif strcmp(params.environment_type, 'Suburbano')
    C = -2;
elseif strcmp(params.environment_type, 'Rurale')
    C = -4;
else
    error('Tipo di ambiente non riconosciuto.');
end

% 🔧 Calcolo del path loss di base in ambiente urbano
L_urbano = 46.3 + 33.9 * log10(f_MHz) - 13.82 * log10(hb_m) - a_hm + ...
           (44.9 - 6.55 * log10(hb_m)) * log10(d_km) + C; % Correzione per l'ambiente

    % 🔍 Correzioni in base al tipo di ambiente
    switch lower(params.environment_type)
        case 'suburbano'
            path_loss_dB = L_urbano - 2 * (log10(f_MHz / 28))^2 - 5.4;
        case 'rurale/aperto'
            path_loss_dB = L_urbano - 4.78 * (log10(f_MHz))^2 - 18.33 * log10(f_MHz) - 40.94;
        otherwise  % Ambienti urbani
            path_loss_dB = L_urbano;
    end

    % 🔍 Aggiunta correzione manuale di 6 dB per scenari a breve distanza
    if d_km < 1
        path_loss_dB = path_loss_dB - 6; % Riduce il path loss per distanze inferiori a 1 km
    end

    % 🐞 DEBUG - Stampa i valori per il controllo
    fprintf('DEBUG COST231-Hata:\n');
    fprintf('  - Frequenza f_MHz: %.2f MHz\n', f_MHz);
    fprintf('  - Distanza d_km: %.4f km (Distanza input: %.2f m)\n', d_km, distanza);
    fprintf('  - Altezza antenna trasmittente hb_m: %.2f m\n', hb_m);
    fprintf('  - Altezza antenna ricevente hm_m: %.2f m\n', hm_m);
    fprintf('  - a_hm: %.4f dB\n', a_hm);
    fprintf('  - L_urbano (senza correzioni): %.4f dB\n', L_urbano);
    fprintf('  - Path Loss finale: %.4f dB\n', path_loss_dB);

end


% --- Modello ITU-R P.1238 (Indoor) ---
function path_loss_dB = calcolaITU1238(params, f_MHz, distanza, altezza_antenna)
%CALCOLAITU1238 Calcola il path loss con il modello ITU-R P.1238 (Indoor).
%   path_loss_dB = CALCOLAITU1238(params, f_MHz, distanza, altezza_antenna)
%   Implementazione del modello ITU-R P.1238 per il calcolo del path loss indoor.
%
%   Input:
%     params - Struttura dei parametri di simulazione.
%     f_MHz - Frequenza in MHz.
%     distanza - Distanza in metri.
%     altezza_antenna - Altezza antenna trasmittente (non usata nel modello ITU-R P.1238, ma mantenuta per uniformità).
%
%   Output:
%     path_loss_dB - Path loss calcolato in dB.

    n = 30; % Coefficiente di attenuazione indoor (VALORE TIPICO, POTREBBE ESSERE PARAMETRIZZATO)
    path_loss_dB = 20 * log10(f_MHz) + n * log10(distanza) - 28;
end

% --- Funzione per la diffrazione Knife Edge ---
function A_diff = calcolaDiffrazioneKnifeEdge(h_edificio, h_ricevitore, distanza)
%CALCOLADIFFRAZIONEKIFEEDGE Calcola l'attenuazione per diffrazione Knife-Edge.
%   A_diff = CALCOLADIFFRAZIONEKIFEEDGE(h_edificio, h_ricevitore, distanza)
%   Calcola l'attenuazione dovuta alla diffrazione di Knife-Edge.
%
%   Input:
%     h_edificio - Altezza dell'edificio (ostacolo) in metri.
%     h_ricevitore - Altezza del ricevitore (punto di misura) in metri.
%     distanza - Distanza tra trasmettitore e ricevitore in metri.
%
%   Output:
%     A_diff - Attenuazione per diffrazione in dB.

    v = (h_edificio - h_ricevitore) / (sqrt(2) * (distanza / 1000));
    if v > -0.78
        A_diff = 6.9 + 20 * log10(sqrt((v - 0.1)^2 + 1) + v - 0.1);
    else
        A_diff = 0; % Nessuna diffrazione se la LOS è libera (v <= -0.78)
    end
end