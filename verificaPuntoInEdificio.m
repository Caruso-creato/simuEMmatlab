function [inEdificio, altezzaEdificio, punto_misura_xyz] = verificaPuntoInEdificio(punto_misura_xyz, datiEdifici)
    % Controlla se il punto di misura cade dentro un edificio
    x_punto = punto_misura_xyz(1);
    y_punto = punto_misura_xyz(2);
    z_punto = punto_misura_xyz(3);

    inEdificio = false;
    altezzaEdificio = 0;

    % Itera solo sugli edifici unici
    edifici_unici = unique(datiEdifici.Id);
    
    for i = 1:length(edifici_unici)
        current_building = edifici_unici(i);
        vertici_x = datiEdifici.x(datiEdifici.Id == current_building);
        vertici_y = datiEdifici.y(datiEdifici.Id == current_building);
        
        if inpolygon(x_punto, y_punto, vertici_x, vertici_y)
            inEdificio = true;
            altezzaEdificio = mean(datiEdifici.ALTEZZA(datiEdifici.Id == current_building)); % Altezza media dell'edificio
            break;
        end
    end

    if inEdificio
        fprintf('⚠️ Il punto di misura cade dentro un edificio alto %.2f metri.\n', altezzaEdificio);
        
        % Se il punto è già sopra, non abbassarlo
        if z_punto > altezzaEdificio
            fprintf('✔ Il punto è sopra l''edificio, non viene modificato.\n');
        else
            scelta = input('Vuoi simulare il campo all''altezza dell''edificio (s/n)? ', 's');
            if strcmpi(scelta, 's')
                punto_misura_xyz(3) = altezzaEdificio;
                fprintf('✔ Il punto è stato traslato all''altezza dell''edificio: %.2f metri.\n', altezzaEdificio);
            end
        end
    end
end

