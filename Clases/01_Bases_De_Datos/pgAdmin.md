# Tutorial: Conectarse a pgAdmin y Explorar Datos GTFS

## 🎯 Objetivo del Tutorial

Este tutorial te guiará paso a paso para conectarte a pgAdmin y explorar la base de datos GTFS que acabamos de crear con Docker Compose.

---

## 📋 Prerrequisitos

Antes de comenzar, asegúrate de que:

- ✅ Docker Compose esté ejecutándose (`docker-compose up -d`)
- ✅ Los servicios PostgreSQL y pgAdmin estén funcionando
- ✅ Los datos GTFS se hayan cargado correctamente

**Verificar estado de los servicios:**
```bash
docker-compose ps
```

---

## 🌐 Paso 1: Acceder a pgAdmin

### **1.1 Abrir pgAdmin en el navegador**

1. **Abre tu navegador web** (Chrome, Firefox, Edge, etc.)
2. **Ve a la URL**: `http://localhost:8080`
3. **Deberías ver** la pantalla de login de pgAdmin

### **1.2 Iniciar sesión**

**Credenciales por defecto:**
- **Email**: `admin@admin.com`
- **Contraseña**: `admin123`

> **Nota**: Si cambiaste estas credenciales en tu archivo `.env`, usa las tuyas.

![Pantalla de login de pgAdmin](https://i.imgur.com/example1.png)

---

## 🔗 Paso 2: Conectar pgAdmin a PostgreSQL

### **2.1 Agregar un nuevo servidor**

1. **Haz clic derecho** en "Servers" en el panel izquierdo
2. **Selecciona** "Register" → "Server..."
3. **Se abrirá** el diálogo "Register - Server"

### **2.2 Configurar la conexión**

#### **Pestaña "General":**
- **Name**: `GTFS Database` (o cualquier nombre que prefieras)

#### **Pestaña "Connection":**
- **Host name/address**: `postgres` ⭐ **IMPORTANTE**
- **Port**: `5432`
- **Maintenance database**: `mydatabase`
- **Username**: `postgres`
- **Password**: `mysecretpassword` (o la que configuraste)

> **💡 Nota importante**: El "Host name" debe ser `postgres` (nombre del servicio en docker-compose), NO `localhost`.

### **2.3 Guardar la conexión**

1. **Haz clic** en "Save"
2. **pgAdmin intentará conectarse** automáticamente
3. **Si todo está bien**, verás el servidor en el panel izquierdo

---

## 📊 Paso 3: Explorar la Base de Datos

### **3.1 Navegar por la estructura**

Una vez conectado, expande:
```
Servers → GTFS Database → Databases → mydatabase → Schemas → gtfs → Tables
```

**Deberías ver estas tablas:**
- `agency`
- `calendar_dates`
- `routes`
- `shapes`
- `stops`
- `stop_times`
- `trips`

### **3.2 Ver la estructura de una tabla**

1. **Haz clic derecho** en cualquier tabla (ej: `agency`)
2. **Selecciona** "Properties"
3. **Ve a la pestaña** "Columns"
4. **Verás** todas las columnas y sus tipos de datos

---

## 🔍 Paso 4: Ejecutar Consultas SQL

### **4.1 Abrir el Query Tool**

1. **Haz clic derecho** en `mydatabase`
2. **Selecciona** "Query Tool"
3. **Se abrirá** una nueva pestaña con un editor SQL

### **4.2 Consultas básicas para explorar**

#### **Ver cuántas filas tiene cada tabla:**
```sql
SELECT 
    'agency' as tabla, COUNT(*) as filas FROM gtfs.agency
UNION ALL
SELECT 'stops', COUNT(*) FROM gtfs.stops
UNION ALL
SELECT 'routes', COUNT(*) FROM gtfs.routes
UNION ALL
SELECT 'shapes', COUNT(*) FROM gtfs.shapes
UNION ALL
SELECT 'trips', COUNT(*) FROM gtfs.trips
UNION ALL
SELECT 'stop_times', COUNT(*) FROM gtfs.stop_times
UNION ALL
SELECT 'calendar_dates', COUNT(*) FROM gtfs.calendar_dates
ORDER BY filas DESC;
```

#### **Ver las primeras filas de agency:**
```sql
SELECT * FROM gtfs.agency LIMIT 5;
```

#### **Ver las primeras filas de stops:**
```sql
SELECT stop_id, stop_name, stop_lat, stop_lon 
FROM gtfs.stops 
LIMIT 10;
```

#### **Ver las primeras filas de routes:**
```sql
SELECT route_id, route_short_name, route_long_name, route_type 
FROM gtfs.routes 
LIMIT 10;
```

### **4.3 Ejecutar consultas**

1. **Escribe** la consulta SQL en el editor
2. **Presiona** `F5` o haz clic en el botón "Execute" (▶️)
3. **Los resultados** aparecerán en la pestaña "Data Output"

---

## 📈 Paso 5: Consultas Interesantes para GTFS

### **5.1 Estadísticas básicas**

```sql
-- Cuántas rutas hay por tipo
SELECT 
    route_type,
    COUNT(*) as cantidad_rutas
FROM gtfs.routes 
GROUP BY route_type 
ORDER BY route_type;
```

### **5.2 Paradas más populares**

```sql
-- Paradas con más servicios
SELECT 
    s.stop_name,
    COUNT(DISTINCT st.trip_id) as cantidad_viajes
FROM gtfs.stops s
JOIN gtfs.stop_times st ON s.stop_id = st.stop_id
GROUP BY s.stop_id, s.stop_name
ORDER BY cantidad_viajes DESC
LIMIT 10;
```

### **5.3 Rutas con más paradas**

```sql
-- Rutas con más paradas
SELECT 
    r.route_short_name,
    r.route_long_name,
    COUNT(DISTINCT st.stop_id) as cantidad_paradas
FROM gtfs.routes r
JOIN gtfs.trips t ON r.route_id = t.route_id
JOIN gtfs.stop_times st ON t.trip_id = st.trip_id
GROUP BY r.route_id, r.route_short_name, r.route_long_name
ORDER BY cantidad_paradas DESC
LIMIT 10;
```

### **5.4 Horarios de una ruta específica**

```sql
-- Horarios de la ruta "1" (ajusta el nombre según tus datos)
SELECT 
    r.route_short_name,
    t.trip_id,
    s.stop_name,
    st.arrival_time,
    st.departure_time
FROM gtfs.routes r
JOIN gtfs.trips t ON r.route_id = t.route_id
JOIN gtfs.stop_times st ON t.trip_id = st.trip_id
JOIN gtfs.stops s ON st.stop_id = s.stop_id
WHERE r.route_short_name = '1'
ORDER BY t.trip_id, st.stop_sequence
LIMIT 50;
```

---

## 🛠️ Paso 6: Funciones Avanzadas de pgAdmin

### **6.1 Exportar datos**

1. **Ejecuta** una consulta
2. **Haz clic derecho** en los resultados
3. **Selecciona** "Export" → "CSV"
4. **Guarda** el archivo en tu computadora

### **6.2 Crear vistas**

```sql
-- Crear una vista para rutas con estadísticas
CREATE VIEW gtfs.routes_stats AS
SELECT 
    r.route_id,
    r.route_short_name,
    r.route_long_name,
    COUNT(DISTINCT t.trip_id) as total_trips,
    COUNT(DISTINCT st.stop_id) as total_stops
FROM gtfs.routes r
LEFT JOIN gtfs.trips t ON r.route_id = t.route_id
LEFT JOIN gtfs.stop_times st ON t.trip_id = st.trip_id
GROUP BY r.route_id, r.route_short_name, r.route_long_name;
```

### **6.3 Ver el plan de ejecución**

1. **Escribe** una consulta compleja
2. **Presiona** `F7` o haz clic en "Explain" (📊)
3. **Verás** cómo PostgreSQL ejecuta la consulta

---

## 🐛 Paso 7: Solución de Problemas

### **7.1 Error de conexión**

**Síntoma**: "Unable to connect to server"

**Soluciones:**
1. **Verifica** que Docker Compose esté corriendo
2. **Confirma** que usaste `postgres` como host (no localhost)
3. **Revisa** las credenciales en tu archivo `.env`

### **7.2 No aparecen las tablas**

**Síntoma**: No ves las tablas GTFS

**Soluciones:**
1. **Verifica** que los scripts de inicialización se ejecutaron
2. **Revisa** los logs: `docker-compose logs postgres`
3. **Asegúrate** de estar conectado a la base de datos `mydatabase`

### **7.3 Consultas lentas**

**Síntoma**: Las consultas tardan mucho

**Soluciones:**
1. **Usa LIMIT** en tus consultas iniciales
2. **Agrega índices** si es necesario
3. **Optimiza** las consultas con EXPLAIN

---

## 📚 Paso 8: Próximos Pasos

### **8.1 Consultas más complejas**

Una vez que te sientas cómodo, puedes explorar:

- **Análisis temporal**: Horarios por día de la semana
- **Análisis geográfico**: Paradas por zona
- **Análisis de frecuencias**: Rutas más frecuentes
- **Análisis de transferencias**: Conexiones entre rutas

### **8.2 Integración con Python**

```python
# Conectar desde Python usando psycopg2
import psycopg2

conn = psycopg2.connect(
    host="localhost",
    port="5432",
    database="mydatabase",
    user="postgres",
    password="mysecretpassword"
)

# O usando SQLAlchemy
from sqlalchemy import create_engine
engine = create_engine('postgresql://postgres:mysecretpassword@localhost:5432/mydatabase')
```

### **8.3 Recursos adicionales**

- **Documentación oficial de pgAdmin**: https://www.pgadmin.org/docs/
- **Documentación de PostgreSQL**: https://www.postgresql.org/docs/
- **Especificación GTFS**: https://developers.google.com/transit/gtfs

---

## 🎉 ¡Felicidades!

Has completado el tutorial de pgAdmin. Ahora puedes:

- ✅ **Conectarte** a tu base de datos GTFS
- ✅ **Explorar** la estructura de las tablas
- ✅ **Ejecutar** consultas SQL básicas
- ✅ **Analizar** datos de transporte público
- ✅ **Exportar** resultados para análisis adicionales

**¡Sigue explorando y descubriendo insights interesantes en tus datos GTFS!**
