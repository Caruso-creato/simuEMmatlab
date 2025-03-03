function [azimuth_relativo, elevazione_relativa, punto_misura_xyz_ruotato_tilt] = calculateRelativeAngles(params, settore, punto_misura_xyz, srb)
%CALCULATERELATIVEANGLES Calcola gli angoli azimutale e di elevazione RELATIVI rispetto al settore

fprintf('DEBUG: calculateRelativeAngles - Inizio\n');
fprintf('DEBUG:   Settore = %d\n', settore);
fprintf('DEBUG:   Punto misura XYZ (prima della trasformazione) = [%.2f, %.2f, %.2f]\n', punto_misura_xyz);

% 1️⃣ Azimuth globale del settore
azimuth_settore_globale = params.direzioniAzimutaliSettori(settore);
fprintf('DEBUG:   Azimuth Settore Globale = %.2f gradi\n', azimuth_settore_globale);

% 2️⃣ Tilt Meccanico del Settore
tilt_meccanico = params.tiltMeccanicoSettori{settore, 1};
fprintf('DEBUG:   Tilt Meccanico = %.2f gradi\n', tilt_meccanico);

% 3️⃣ Posizione della SRB per il settore specifico
srb_x = srb.x;
srb_y = srb.y;
srb_z = params.altezzaAntenneSettori{settore, 1};

% 4️⃣ Traslazione rispetto alla SRB
punto_misura_relativo = punto_misura_xyz - [srb_x, srb_y, srb_z];

% 5️⃣ Calcolo Azimuth Relativo
differenza_x = punto_misura_relativo(1);
differenza_y = punto_misura_relativo(2);
azimuth_assoluto_rad = atan2d(differenza_x, differenza_y);
azimuth_relativo = mod(azimuth_assoluto_rad - azimuth_settore_globale, 360);

% 🔴 CORREZIONE: Se l'azimuth relativo è 360°, impostalo a 0° perché il punto è allineato.
if abs(azimuth_relativo - 360) < 0.5
    azimuth_relativo = 0;
end

fprintf('DEBUG:   Azimuth Relativo finale = %.2f°\n', azimuth_relativo);

% 6️⃣ Rotazione tilt meccanico (SOLO per l'elevazione)
angolo_rotazione_tilt_meccanico_rad = deg2rad(tilt_meccanico);
Ry = [cos(-angolo_rotazione_tilt_meccanico_rad)  0  sin(-angolo_rotazione_tilt_meccanico_rad);
      0                                         1  0;
     -sin(-angolo_rotazione_tilt_meccanico_rad)  0  cos(-angolo_rotazione_tilt_meccanico_rad)];

punto_misura_xyz_ruotato_tilt = Ry * punto_misura_relativo';

% 7️⃣ Calcolo Elevazione Relativa
distanza_orizzontale_relativa = sqrt(punto_misura_xyz_ruotato_tilt(1)^2 + punto_misura_xyz_ruotato_tilt(2)^2);
elevazione_relativa_rad = atan2d(punto_misura_xyz_ruotato_tilt(3), distanza_orizzontale_relativa);
elevazione_relativa = abs(elevazione_relativa_rad);


fprintf('DEBUG:   Elevazione Relativa finale = %.2f°\n', elevazione_relativa);
fprintf('DEBUG: calculateRelativeAngles - Fine\n');
end

