# BaseDeDatos2025

# Docker Compose - PostgreSQL + pgAdmin

Este docker-compose configura un entorno completo con PostgreSQL y pgAdmin conectados mediante networking.

## 🚀 Configuración Rápida

### 1. Crear archivo .env
Copia el contenido de `env_template.txt` a un archivo `.env` en el mismo directorio:

```bash
# En Windows PowerShell
Copy-Item env_template.txt .env

# En Linux/Mac
cp env_template.txt .env
```

### 2. Personalizar variables (opcional)
Edita el archivo `.env` para cambiar las credenciales por defecto:

```env
# Configuración de PostgreSQL
POSTGRES_DB=mydatabase
POSTGRES_USER=postgres
POSTGRES_PASSWORD=mysecretpassword
POSTGRES_PORT=5432

# Configuración de pgAdmin
PGADMIN_EMAIL=admin@admin.com
PGADMIN_PASSWORD=admin123
PGADMIN_PORT=8080
```

### 3. Ejecutar los servicios
```bash
# Levantar todos los servicios
docker-compose up -d

# Ver logs en tiempo real
docker-compose logs -f

# Detener servicios
docker-compose down
```

## 📊 Acceso a los Servicios

### PostgreSQL
- **Host**: localhost
- **Puerto**: 5432 (o el configurado en POSTGRES_PORT)
- **Base de datos**: mydatabase
- **Usuario**: postgres
- **Contraseña**: mysecretpassword

### pgAdmin
- **URL**: http://localhost:8080 (o el puerto configurado en PGADMIN_PORT)
- **Email**: admin@admin.com
- **Contraseña**: admin123

## 🔧 Configuración de pgAdmin

1. Accede a http://localhost:8080
2. Inicia sesión con las credenciales del archivo .env
3. Para conectar a PostgreSQL:
   - **Host**: postgres (nombre del servicio en docker-compose)
   - **Puerto**: 5432
   - **Base de datos**: mydatabase
   - **Usuario**: postgres
   - **Contraseña**: mysecretpassword

## 📁 Estructura de Archivos

```
.
├── docker-compose.yml          # Configuración principal
├── .env                        # Variables de entorno (crear manualmente)
├── env_template.txt            # Plantilla de variables
├── data/                       # Datos GTFS
│   ├── feed-gtfs/             # Archivos GTFS (.txt)
│   └── feed_gtfs_buenosaires.zip
├── init-scripts/               # Scripts de inicialización
│   ├── 1-gtfs_schema.sql      # Creación del esquema GTFS
│   ├── 2-load_gtfs_data.sql   # Carga de datos con manejo de errores
│   └── 3-verify_data.sql      # Verificación de integridad
└── README_Docker.md           # Este archivo
```

## 🛠️ Comandos Útiles

```bash
# Ver estado de los servicios
docker-compose ps

# Reiniciar un servicio específico
docker-compose restart postgres

# Ver logs de un servicio específico
docker-compose logs postgres

# Eliminar volúmenes (¡CUIDADO! Esto borra todos los datos)
docker-compose down -v

# Reconstruir imágenes
docker-compose build

# Ejecutar comandos dentro del contenedor
docker-compose exec postgres psql -U postgres -d mydatabase
```

## 🔒 Seguridad

- **Nunca** subas el archivo `.env` a control de versiones
- Cambia las contraseñas por defecto en producción
- Considera usar secrets de Docker para entornos de producción

## 📊 Carga de Datos GTFS

El sistema carga automáticamente los datos GTFS desde la carpeta `data/feed-gtfs/`:

### Características de la carga:
- ✅ **Carga simple y directa**: Script simplificado sin complejidad innecesaria
- ✅ **Rutas correctas**: Usa `/data/feed-gtfs/` para acceder a los archivos
- ✅ **Continuación en errores**: `\set ON_ERROR_STOP off` permite que continúe si hay errores
- ✅ **Verificación automática**: El script `3-verify_data.sql` verifica la integridad

### Archivos que se cargan:
- `agency.txt` - Información de agencias de transporte
- `stops.txt` - Paradas de transporte público
- `routes.txt` - Rutas de transporte
- `shapes.txt` - Geometrías de las rutas
- `trips.txt` - Viajes específicos
- `stop_times.txt` - Horarios de paradas
- `calendar_dates.txt` - Calendario de servicios

## 🐛 Solución de Problemas

### pgAdmin no puede conectar a PostgreSQL
- Verifica que ambos servicios estén corriendo: `docker-compose ps`
- Asegúrate de usar `postgres` como host en pgAdmin (no localhost)
- Revisa los logs: `docker-compose logs pgadmin`

### Puerto ya en uso
- Cambia el puerto en el archivo `.env`
- O detén otros servicios que usen el mismo puerto

### Datos no persisten
- Verifica que los volúmenes estén creados: `docker volume ls`
- No uses `docker-compose down -v` a menos que quieras borrar todo

### Tiempo de carga de datos GTFS
La carga inicial puede tomar tiempo debido al tamaño de los archivos:
- **agency.txt**: ~21KB - Carga rápida
- **stops.txt**: ~3.1MB - Carga rápida  
- **routes.txt**: ~74KB - Carga rápida
- **shapes.txt**: ~29MB - Carga media
- **trips.txt**: ~31MB - Carga media
- **stop_times.txt**: ~1.3GB - **Carga lenta** (puede tomar 10-30 minutos)
- **calendar_dates.txt**: ~8.4MB - Carga rápida

**Consejo**: Para la primera carga, ejecuta `docker-compose logs -f postgres` para monitorear el progreso.
