function datiEdifici = leggiDatiShapefile(fname)
    % LEGIGDATISHAPEFILE - Legge lo shapefile e restituisce una tabella con:
    % - x, y: Coordinate dei vertici degli edifici
    % - ALTEZZA: Altezza dell'edificio
    % - centroidex, centroidey: Coordinate del centroide dell'edificio
    %
    % Input:
    %   fname - Percorso dello shapefile.
    %
    % Output:
    %   datiEdifici - Tabella contenente i dati essenziali per la simulazione.

    % Legge lo shapefile
    [T, ~] = tryshapereadversioneok(fname);

    % Estrazione dei dati necessari
    datiEdifici = table();
    datiEdifici.Id = T.Id;  % Aggiungi la colonna 'Id'
    datiEdifici.x = T.x; % Coordinate x dei vertici
    datiEdifici.y = T.y; % Coordinate y dei vertici
    datiEdifici.ALTEZZA = T.ALTEZZA; % Altezza dell'edificio
    datiEdifici.centroidex = T.centroidex; % Centroide x
    datiEdifici.centroidey = T.centroidey; % Centroide y
    

end
