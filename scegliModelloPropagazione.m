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
        if punto_misura_xyz(3) == altezzaEdificio
            modello = 'COST 231-Hata'; % Se l'utente ha scelto di simulare all'altezza dell'edificio, usa il modello outdoor
            fprintf('✅ Il punto è stato simulato all''altezza dell''edificio, usando il modello outdoor (COST 231-Hata).\n');
        else
            modello = 'ITU-R P.1238'; % Se il punto è effettivamente indoor, usa il modello indoor
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

