function [azimuth_relativo, elevazione_relativa, punto_misura_xyz_ruotato_tilt] = calculateRelativeAngles(params, settore, punto_misura_xyz)
%CALCULATERELATIVEANGLES Calcola gli angoli azimutale e di elevazione RELATIVI

fprintf('DEBUG: calculateRelativeAngles - Inizio\n'); % DEBUG
fprintf('DEBUG:   settore = %d\n', settore); % DEBUG
fprintf('DEBUG:   punto_misura_xyz = [%.2f, %.2f, %.2f]\n', punto_misura_xyz); % DEBUG

% 1. Azimuth del Settore (da params):
azimuth_settore_globale = params.direzioniAzimutaliSettori(settore);
fprintf('DEBUG:   azimuth_settore_globale = %.2f gradi\n', azimuth_settore_globale); % DEBUG

% 2. Tilt Meccanico del Settore (da params):
tilt_meccanico = params.tiltMeccanicoSettori{settore, 1};
fprintf('DEBUG:   tilt_meccanico = %.2f gradi\n', tilt_meccanico); % DEBUG

% --- ORDINE CORRETTO: AZIMUTH PRIMA, POI TILT ---

% 3. Rotazione Azimutale (PRIMA):
angolo_rotazione_azimutale_rad = deg2rad(azimuth_settore_globale);
fprintf('DEBUG:   angolo_rotazione_azimutale_rad = %.2f radianti\n', angolo_rotazione_azimutale_rad); % DEBUG

Rz = [cos(angolo_rotazione_azimutale_rad) -sin(angolo_rotazione_azimutale_rad) 0;
      sin(angolo_rotazione_azimutale_rad)  cos(angolo_rotazione_azimutale_rad) 0;
      0                                   0                                     1];
fprintf('DEBUG:   Rz (matrice di rotazione azimuth):\n'); % DEBUG
disp(Rz); % DEBUG

punto_misura_xyz_ruotato_azimuth = Rz * punto_misura_xyz';
punto_misura_xyz_ruotato_azimuth = punto_misura_xyz_ruotato_azimuth';
fprintf('DEBUG:   punto_misura_xyz_ruotato_azimuth: [%.2f, %.2f, %.2f]\n', punto_misura_xyz_ruotato_azimuth); % DEBUG


% 4. Rotazione di Tilt Meccanico (DOPO): attorno all'asse Y!
angolo_rotazione_tilt_meccanico_rad =  deg2rad(tilt_meccanico);
fprintf('DEBUG:   angolo_rotazione_tilt_meccanico_rad = %.2f radianti\n', angolo_rotazione_tilt_meccanico_rad); % DEBUG
Ry = [cos(-angolo_rotazione_tilt_meccanico_rad)  0  sin(-angolo_rotazione_tilt_meccanico_rad);
0                                         1  0;
-sin(-angolo_rotazione_tilt_meccanico_rad) 0  cos(-angolo_rotazione_tilt_meccanico_rad)];
fprintf('DEBUG:   Ry (matrice di rotazione tilt):\n'); % DEBUG
disp(Ry); % DEBUG

punto_misura_xyz_ruotato_tilt = Ry * punto_misura_xyz_ruotato_azimuth';
punto_misura_xyz_ruotato_tilt = punto_misura_xyz_ruotato_tilt';
fprintf('DEBUG:   punto_misura_xyz_ruotato_tilt: [%.2f, %.2f, %.2f]\n', punto_misura_xyz_ruotato_tilt); % DEBUG

% 5. Calcola Azimuth e Elevazione *RELATIVI*
distanza_orizzontale_relativa = sqrt(punto_misura_xyz_ruotato_tilt(1)^2 + punto_misura_xyz_ruotato_tilt(2)^2);
fprintf('DEBUG:   distanza_orizzontale_relativa: %.2f\n', distanza_orizzontale_relativa); % DEBUG

azimuth_relativo_rad = atan2(punto_misura_xyz_ruotato_tilt(1), punto_misura_xyz_ruotato_tilt(2));
azimuth_relativo = mod(rad2deg(azimuth_relativo_rad), 360);
fprintf('DEBUG:   azimuth_relativo: %.2f gradi\n', azimuth_relativo); % DEBUG


elevazione_relativa_rad = atan2(punto_misura_xyz_ruotato_tilt(3), distanza_orizzontale_relativa);
elevazione_relativa = rad2deg(elevazione_relativa_rad);
fprintf('DEBUG:   elevazione_relativa: %.2f gradi\n', elevazione_relativa); % DEBUG

fprintf('DEBUG: calculateRelativeAngles - Fine\n'); % DEBUG

