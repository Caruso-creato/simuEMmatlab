function modello = scegliModelloPropagazione(inEdificio, numOstacoli, punto_misura_xyz, altezzaEdificio)
    % SCEGLIMODELLOPROPAGAZIONE - Determina il modello di propagazione corretto
    %
    % Input:
    %   inEdificio - Booleano (true se il punto è dentro un edificio)
    %   numOstacoli - Numero di ostacoli sulla linea di vista
    %   punto_misura_xyz - Coordinate del punto di misura [x, y, z]
    %   altezzaEdificio - Altezza dell'edificio in cui si trova il punto (se dentro un edificio)
    %
    % Output:
    %   modello - Modello di propagazione scelto

    if inEdificio
        if punto_misura_xyz(3) >= altezzaEdificio  % Se il punto è sopra o uguale all'edificio
            modello = 'COST 231-Hata';  
            fprintf('✅ Il punto è sopra l''edificio o alla stessa altezza. Modello usato: COST 231-Hata (Outdoor).\n');
        else
            modello = 'ITU-R P.1238';  
            fprintf('✅ Il punto è dentro un edificio. Modello usato: ITU-R P.1238 (Indoor).\n');
        end
    else
        if numOstacoli > 0
            modello = 'COST 231-Hata + Attenuazione Ostacoli';
        else
            modello = 'COST 231-Hata';
        end
    end
end

