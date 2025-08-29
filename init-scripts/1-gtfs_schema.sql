-- Esquema GTFS
CREATE SCHEMA IF NOT EXISTS gtfs;

-- ======================
-- agency.txt (puede haber 1..N agencias)
-- ======================
CREATE TABLE IF NOT EXISTS gtfs.agency (
    agency_id       TEXT PRIMARY KEY,            -- En feeds con 1 sola agencia puede faltar; en CABA suele haber más de una.
    agency_name     TEXT NOT NULL,
    agency_url      TEXT NOT NULL,
    agency_timezone TEXT NOT NULL,
    agency_lang     TEXT,
    agency_phone    TEXT
);

-- ======================
-- calendar_dates.txt
-- ======================
CREATE TABLE IF NOT EXISTS gtfs.calendar_dates (
    service_id      TEXT   NOT NULL,
    date            DATE   NOT NULL,
    exception_type  SMALLINT NOT NULL CHECK (exception_type IN (1,2))
    -- OJO: según la spec, service_id puede referenciar calendar.service_id o ser un ID independiente si no se usa calendar.txt
);

-- ======================
-- routes.txt
-- ======================
CREATE TABLE IF NOT EXISTS gtfs.routes (
    route_id         TEXT PRIMARY KEY,
    agency_id        TEXT,
    route_short_name TEXT,
    route_long_name  TEXT,
    route_desc       TEXT,
    route_type       INTEGER NOT NULL            -- Enum GTFS (0..7 y extensiones)
);

-- ======================
-- shapes.txt
-- ======================
CREATE TABLE IF NOT EXISTS gtfs.shapes (
    shape_id            TEXT NOT NULL,
    shape_pt_lat        DOUBLE PRECISION NOT NULL CHECK (shape_pt_lat BETWEEN -90 AND 90),
    shape_pt_lon        DOUBLE PRECISION NOT NULL CHECK (shape_pt_lon BETWEEN -180 AND 180),
    shape_pt_sequence   INTEGER NOT NULL CHECK (shape_pt_sequence >= 0),
    shape_dist_traveled DOUBLE PRECISION        -- Unidades deben ser consistentes con stop_times.shape_dist_traveled
);

-- ======================
-- stops.txt (sencillo; podés ampliarlo con location_type, parent_station, zone_id, etc.)
-- ======================
CREATE TABLE IF NOT EXISTS gtfs.stops (
    stop_id    TEXT PRIMARY KEY,
    stop_code  TEXT,
    stop_name  TEXT,
    stop_lat   DOUBLE PRECISION CHECK (stop_lat BETWEEN -90 AND 90),
    stop_lon   DOUBLE PRECISION CHECK (stop_lon BETWEEN -180 AND 180)
);

-- ======================
-- trips.txt
-- ======================
CREATE TABLE IF NOT EXISTS gtfs.trips (
    route_id         TEXT NOT NULL,
    service_id       TEXT NOT NULL,       -- Puede referenciar calendar.service_id o ser ID independiente si no hay calendar.txt
    trip_id          TEXT PRIMARY KEY,
    trip_headsign    TEXT,
    trip_short_name  TEXT,
    direction_id     SMALLINT CHECK (direction_id IN (0,1)),
    block_id         TEXT,
    shape_id         TEXT,
    exceptional      INTEGER              -- Campo no estándar (extensión local)
);

-- ======================
-- stop_times.txt
-- ======================
CREATE TABLE IF NOT EXISTS gtfs.stop_times (
    trip_id               TEXT NOT NULL,
    arrival_time          TEXT,                 -- HH:MM:SS (puede ser > 24:00:00, por eso TEXT)
    departure_time        TEXT,
    stop_id               TEXT NOT NULL,
    stop_sequence         INTEGER NOT NULL CHECK (stop_sequence >= 0),
    timepoint             SMALLINT,            -- 0 aprox / 1 exacto, recomendado si informás tiempos
    shape_dist_traveled   DOUBLE PRECISION
);

-- ======================
-- Índices básicos para consultas
-- ======================
CREATE INDEX IF NOT EXISTS idx_trips_route ON gtfs.trips(route_id);
CREATE INDEX IF NOT EXISTS idx_stop_times_trip ON gtfs.stop_times(trip_id);
