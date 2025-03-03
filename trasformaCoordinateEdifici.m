function [datiEdifici, puntoMisura] = trasformaCoordinateEdifici(datiEdifici, puntoMisura)
    % Trasforma le coordinate dei poligoni degli edifici rispetto alla SRB

    % Determina il centro medio dei centroidi degli edifici
    centro_x = mean(datiEdifici.centroidex);
    centro_y = mean(datiEdifici.centroidey);

    fprintf('DEBUG: Centro medio dei centroidi edifici: centro_x = %.2f, centro_y = %.2f\n', centro_x, centro_y);

    % Trasformiamo le coordinate per riportarle al centro della SRB
    datiEdifici.centroidex = datiEdifici.centroidex - centro_x;
    datiEdifici.centroidey = datiEdifici.centroidey - centro_y;
    datiEdifici.x = datiEdifici.x - centro_x;
    datiEdifici.y = datiEdifici.y - centro_y;
end
