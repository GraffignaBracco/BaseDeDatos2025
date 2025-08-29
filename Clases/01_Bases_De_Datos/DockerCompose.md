# Docker Compose - Explicación Detallada

## 🐳 ¿Qué es Docker Compose?

Docker Compose es una herramienta que permite definir y ejecutar aplicaciones con múltiples contenedores Docker usando un archivo de configuración. Es como un "director de orquesta" que coordina varios servicios para que trabajen juntos.

---

## 📋 Análisis Detallado del `docker-compose.yml`

### **1. Versión del archivo**
```yaml
version: '3.8'
```
- **¿Qué hace?** Define la versión de sintaxis de Docker Compose
- **¿Por qué es importante?** Cada versión tiene características diferentes
- **Nota:** Esta línea es opcional en versiones recientes de Docker Compose

### **2. Sección de Servicios**
```yaml
services:
```
- **¿Qué hace?** Define todos los contenedores que queremos ejecutar
- **¿Por qué es importante?** Cada servicio es un contenedor independiente que puede comunicarse con otros

---

## 🗄️ Servicio PostgreSQL

### **Configuración básica**
```yaml
postgres:
  image: postgres:latest
  container_name: postgres_db
  restart: unless-stopped
```

**Explicación línea por línea:**
- `postgres:` - Nombre del servicio (puedes llamarlo como quieras)
- `image: postgres:latest` - Imagen de Docker a usar (PostgreSQL versión más reciente)
- `container_name: postgres_db` - Nombre específico del contenedor
- `restart: unless-stopped` - Reinicia automáticamente si se cae, a menos que lo detengas manualmente

### **Variables de entorno**
```yaml
environment:
  POSTGRES_DB: ${POSTGRES_DB:-mydatabase}
  POSTGRES_USER: ${POSTGRES_USER:-postgres}
  POSTGRES_PASSWORD: ${POSTGRES_PASSWORD:-password}
  POSTGRES_INITDB_ARGS: "--encoding=UTF-8"
```

**Explicación:**
- `POSTGRES_DB` - Nombre de la base de datos a crear
- `POSTGRES_USER` - Usuario administrador
- `POSTGRES_PASSWORD` - Contraseña del usuario
- `${VARIABLE:-valor_por_defecto}` - Sintaxis para usar variables de entorno con valor por defecto
- `POSTGRES_INITDB_ARGS` - Argumentos adicionales para la inicialización

### **Puertos**
```yaml
ports:
  - "${POSTGRES_PORT:-5432}:5432"
```

**Explicación:**
- `puerto_host:puerto_contenedor` - Mapea puertos entre tu computadora y el contenedor
- `5432` - Puerto estándar de PostgreSQL
- `${POSTGRES_PORT:-5432}` - Usa el puerto definido en .env o 5432 por defecto

### **Volúmenes**
```yaml
volumes:
  - postgres_data:/var/lib/postgresql/data
  - ./init-scripts:/docker-entrypoint-initdb.d
  - ./data:/data
```

**Explicación:**
- `postgres_data:/var/lib/postgresql/data` - **Volumen nombrado**: Guarda los datos de PostgreSQL de forma persistente
- `./init-scripts:/docker-entrypoint-initdb.d` - **Bind mount**: Monta tu carpeta local en el contenedor para ejecutar scripts de inicialización
- `./data:/data` - **Bind mount**: Monta tu carpeta de datos GTFS en el contenedor

### **Red**
```yaml
networks:
  - postgres_network
```

**Explicación:**
- Define en qué red virtual debe estar el contenedor
- Permite que los servicios se comuniquen entre sí

### **Health Check**
```yaml
healthcheck:
  test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER:-postgres} -d ${POSTGRES_DB:-mydatabase}"]
  interval: 30s
  timeout: 10s
  retries: 3
```

**Explicación:**
- `test` - Comando que verifica si PostgreSQL está funcionando
- `interval` - Cada cuánto tiempo hacer la verificación
- `timeout` - Cuánto tiempo esperar por respuesta
- `retries` - Cuántas veces intentar antes de marcar como "no saludable"

---

## 🖥️ Servicio pgAdmin

### **Configuración básica**
```yaml
pgadmin:
  image: dpage/pgadmin4:latest
  container_name: pgadmin
  restart: unless-stopped
```

**Explicación:**
- `pgadmin` - Nombre del servicio
- `image: dpage/pgadmin4:latest` - Imagen oficial de pgAdmin 4
- pgAdmin es una interfaz web para administrar bases de datos PostgreSQL

### **Variables de entorno**
```yaml
environment:
  PGADMIN_DEFAULT_EMAIL: ${PGADMIN_EMAIL:-admin@admin.com}
  PGADMIN_DEFAULT_PASSWORD: ${PGADMIN_PASSWORD:-admin}
  PGADMIN_CONFIG_SERVER_MODE: 'False'
  PGADMIN_CONFIG_MASTER_PASSWORD_REQUIRED: 'False'
```

**Explicación:**
- `PGADMIN_DEFAULT_EMAIL` - Email para iniciar sesión
- `PGADMIN_DEFAULT_PASSWORD` - Contraseña para iniciar sesión
- `PGADMIN_CONFIG_SERVER_MODE: 'False'` - Modo de escritorio (más simple)
- `PGADMIN_CONFIG_MASTER_PASSWORD_REQUIRED: 'False'` - No requiere contraseña maestra

### **Dependencias**
```yaml
depends_on:
  postgres:
    condition: service_healthy
```

**Explicación:**
- `depends_on` - Define que pgAdmin debe esperar a que PostgreSQL esté listo
- `condition: service_healthy` - Espera hasta que PostgreSQL pase el health check

---

## 💾 Sección de Volúmenes

```yaml
volumes:
  postgres_data:
    driver: local
  pgadmin_data:
    driver: local
```

**Explicación:**
- Define volúmenes nombrados que persisten los datos
- `driver: local` - Almacena los datos en el disco local
- Estos volúmenes sobreviven a reinicios del contenedor

---

## 🌐 Sección de Redes

```yaml
networks:
  postgres_network:
    driver: bridge
```

**Explicación:**
- `postgres_network` - Nombre de la red virtual
- `driver: bridge` - Tipo de red que permite comunicación entre contenedores
- Los contenedores en la misma red pueden comunicarse usando el nombre del servicio

---

## 📁 Análisis de los Scripts SQL

### **1. `1-gtfs_schema.sql` - Creación del Esquema**

**¿Qué hace este archivo?**
Este script crea la estructura de la base de datos para almacenar datos GTFS (General Transit Feed Specification).

**Componentes principales:**

#### **Esquema GTFS**
```sql
CREATE SCHEMA IF NOT EXISTS gtfs;
```
- **¿Qué hace?** Crea un "contenedor" llamado `gtfs` para organizar todas las tablas
- **¿Por qué es importante?** Mantiene las tablas organizadas y evita conflictos de nombres

#### **Tablas creadas:**

1. **`agency`** - Información de las empresas de transporte
2. **`stops`** - Paradas de transporte público
3. **`routes`** - Rutas de transporte
4. **`shapes`** - Geometrías de las rutas (coordenadas GPS)
5. **`trips`** - Viajes específicos
6. **`stop_times`** - Horarios de cada parada
7. **`calendar_dates`** - Calendario de servicios

#### **Índices**
```sql
CREATE INDEX IF NOT EXISTS idx_trips_route ON gtfs.trips(route_id);
CREATE INDEX IF NOT EXISTS idx_stop_times_trip ON gtfs.stop_times(trip_id);
```
- **¿Qué hace?** Crea índices para acelerar las consultas
- **¿Por qué es importante?** Sin índices, las consultas serían muy lentas

---

### **2. `2-load_gtfs_data.sql` - Carga de Datos**

**¿Qué hace este archivo?**
Este script carga los datos desde los archivos GTFS (.txt) a las tablas de la base de datos.

**Configuración inicial:**
```sql
\set ON_ERROR_STOP off
```
- **¿Qué hace?** Permite que el script continúe aunque haya errores
- **¿Por qué es importante?** Si un archivo falla, los demás siguen cargándose

**Comandos COPY:**
```sql
COPY gtfs.agency(...) FROM '/data/feed-gtfs/agency.txt' DELIMITER ',' CSV HEADER ENCODING 'UTF8';
```

**Explicación del comando COPY:**
- `COPY` - Comando de PostgreSQL para cargar datos masivos
- `gtfs.agency(...)` - Tabla destino y columnas
- `FROM '/data/feed-gtfs/agency.txt'` - Archivo fuente
- `DELIMITER ','` - Separador de campos (coma)
- `CSV HEADER` - Formato CSV con encabezados
- `ENCODING 'UTF8'` - Codificación de caracteres

---

## 🔍 ¿Por qué funciona la carga con COPY pero no con SQLAlchemy?

### **El problema con SQLAlchemy:**

El error que mostraste:
```
InvalidTextRepresentation: invalid input syntax for type bigint: "tai6"
```

**¿Qué pasó?**
1. **SQLAlchemy infiere tipos** basándose en las primeras filas del archivo
2. **En las primeras filas**, `stop_id` contenía solo números (ej: "206991")
3. **SQLAlchemy decidió** que era una columna de tipo `BIGINT` (número entero)
4. **Más adelante en el archivo**, encontró valores como "tai6" (texto)
5. **PostgreSQL rechazó** "tai6" porque no es un número válido

### **¿Por qué funciona COPY?**

**COPY es más inteligente:**
1. **Lee todo el archivo** antes de decidir tipos
2. **Detecta automáticamente** que hay valores mixtos (números y texto)
3. **Usa el tipo más flexible** (TEXT) que puede contener todo
4. **No hace inferencias** basadas solo en las primeras filas

### **Comparación:**

| Método | Ventaja | Desventaja |
|--------|---------|------------|
| **SQLAlchemy** | Fácil de usar en Python | Inferencia de tipos problemática |
| **COPY** | Más rápido y confiable | Solo funciona en PostgreSQL |

### **Solución alternativa con SQLAlchemy:**

Si quisieras usar SQLAlchemy, tendrías que:
```python
# Especificar tipos manualmente
dtype = {
    'stop_id': str,  # Forzar tipo texto
    'trip_id': str,
    # ... otros campos
}

pd.read_csv('stop_times.txt', dtype=dtype)
```

---

## 🎯 Resumen

### **Docker Compose:**
- Es como un "director de orquesta" para contenedores
- Define servicios, volúmenes, redes y dependencias
- Permite ejecutar aplicaciones complejas con un solo comando

### **Scripts SQL:**
- **Schema**: Define la estructura (tablas, índices)
- **Load**: Carga los datos desde archivos
- **COPY**: Método más confiable para cargar datos masivos

### **Lección aprendida:**
- **SQLAlchemy** es genial para Python, pero tiene limitaciones con inferencia de tipos
- **COPY** es más robusto para cargar datos masivos en PostgreSQL
- **Siempre verifica** los tipos de datos antes de cargar archivos grandes
