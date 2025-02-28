function [T, A] = tryshaperead(fname, varargin)
%   [T, A] = tryshaperead(fname, varargin) reads a shapefile, handling
%   'Z' shapefiles using readgeotable.
%
%   Inputs:
%       fname:      The name of the shapefile (e.g., 'my_shapefile.shp').
%       varargin:  Optional arguments to be passed to readgeotable
%                  
%
%   Outputs:
%       T:          The geostruct (or a table if readgeotable is used).
%       A:          The attribute table (already a table).  This is often
%                   the same as T, except T may have geometry columns.

    try
        % Use readgeotable, which handles Z types.
         %T = readgeotable('VE30016_003m4.shp'); %per testare singolo file
         T = readgeotable(fname, varargin{:});

        % No need for separate attribute handling; readgeotable returns a table.
        A = T;

        % Convert to geostruct if you specifically need a geostruct.  This
        % is generally NOT needed if you are using geoplot or other modern
        % geospatial functions.  It's only needed for older functions or
        % very specific workflows.
        if nargout > 0 && ~istable(T) % Return struct only if requested and not already a table

            geometryType = lower(T.Shape(1));
            
            if strcmp(geometryType, 'point')
                fieldnames = T.Properties.VariableNames;
                fieldnames(ismember(fieldnames,{'Shape','X','Y'})) = [];
                S = geostructinit('point',height(T),'fieldnames',fieldnames);

                for i = 1:height(T)
                    S(i).Lon = T.X(i);
                    S(i).Lat = T.Y(i);
                    for j = 1:numel(fieldnames)
                        S(i).(fieldnames{j}) = T.(fieldnames{j})(i);
                    end
                end
                T = S;
            elseif any(strcmp(geometryType,{'polyline','polygon'}))
               
                
                fieldnames = T.Properties.VariableNames;
                fieldnames(ismember(fieldnames,{'Shape'})) = []; % remove shape from attribute names
                S = geostructinit(geometryType,height(T),'fieldnames',fieldnames);

                for i = 1:height(T)
                  
                    S(i).Lon = T.Shape(i).Longitude'; % correct way to get coordinate
                    S(i).Lat = T.Shape(i).Latitude';

                    for j = 1:numel(fieldnames)
                         S(i).(fieldnames{j}) = T.(fieldnames{j})(i);
                    end
                end
                T = S;
            
            end
        end

    catch ME
        warning('Error reading shapefile: %s', ME.message);
        T = [];  % Return empty values on failure
        A = [];
        return;
    end
end



