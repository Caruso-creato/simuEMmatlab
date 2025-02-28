function [inEdificio, altezzaEdificio, punto_misura_xyz] = verificaPuntoInEdificio(punto_misura_xyz, datiEdifici)
    % Controlla se il punto di misura cade dentro un edificio
    x_punto = punto_misura_xyz(1);
    y_punto = punto_misura_xyz(2);
    z_punto = punto_misura_xyz(3);

    inEdificio = false;
    altezzaEdificio = 0;

    for i = 1:height(datiEdifici)
        vertici_x = datiEdifici.x(datiEdifici.Id == datiEdifici.Id(i));
        vertici_y = datiEdifici.y(datiEdifici.Id == datiEdifici.Id(i));
        if inpolygon(x_punto, y_punto, vertici_x, vertici_y)
            inEdificio = true;
            altezzaEdificio = datiEdifici.ALTEZZA(i);
            break;
        end
    end

    if inEdificio
        fprintf('⚠️ Il punto di misura cade dentro un edificio alto %.2f metri.\n', altezzaEdificio);
        scelta = input('Vuoi simulare il campo all''altezza dell''edificio (s/n)? ', 's');
        if strcmpi(scelta, 's')
            punto_misura_xyz(3) = altezzaEdificio;
            fprintf('✔ Il punto è stato traslato all''altezza dell''edificio: %.2f metri.\n', altezzaEdificio);
        end
    end
end

