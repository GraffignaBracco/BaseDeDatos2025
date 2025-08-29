-- Script de carga de datos GTFS
-- Configurar para continuar en caso de errores
\set ON_ERROR_STOP off

-- Cargar datos GTFS desde la carpeta data
COPY gtfs.agency(agency_id, agency_name, agency_url, agency_timezone, agency_lang, agency_phone)
FROM '/data/feed-gtfs/agency.txt' DELIMITER ',' CSV HEADER ENCODING 'UTF8';

COPY gtfs.stops(stop_id, stop_code, stop_name, stop_lat, stop_lon)
FROM '/data/feed-gtfs/stops.txt' DELIMITER ',' CSV HEADER ENCODING 'UTF8';

COPY gtfs.routes(route_id, agency_id, route_short_name, route_long_name, route_desc, route_type)
FROM '/data/feed-gtfs/routes.txt' DELIMITER ',' CSV HEADER ENCODING 'UTF8';

COPY gtfs.shapes(shape_id, shape_pt_lat, shape_pt_lon, shape_pt_sequence, shape_dist_traveled)
FROM '/data/feed-gtfs/shapes.txt' DELIMITER ',' CSV HEADER ENCODING 'UTF8';

COPY gtfs.trips(route_id, service_id, trip_id, trip_headsign, trip_short_name, direction_id, block_id, shape_id, exceptional)
FROM '/data/feed-gtfs/trips.txt' DELIMITER ',' CSV HEADER ENCODING 'UTF8';

COPY gtfs.stop_times(trip_id, arrival_time, departure_time, stop_id, stop_sequence, timepoint, shape_dist_traveled)
FROM '/data/feed-gtfs/stop_times.txt' DELIMITER ',' CSV HEADER ENCODING 'UTF8';

COPY gtfs.calendar_dates(service_id, date, exception_type)
FROM '/data/feed-gtfs/calendar_dates.txt' DELIMITER ',' CSV HEADER ENCODING 'UTF8';