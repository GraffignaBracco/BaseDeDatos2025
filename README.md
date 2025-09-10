# BaseDeDatos2025

# Entorno de Desarrollo con PostgreSQL + pgAdmin

Este proyecto proporciona un entorno completo de desarrollo con PostgreSQL y pgAdmin usando Docker Compose, ideal para proyectos de bases de datos y análisis de datos.

## 🚀 Configuración Rápida

### 1. Clonar el repositorio
```bash
git clone <url-del-repositorio>
cd BaseDeDatos2025
```

### 2. Instalar dependencias con uv
```bash
# Instalar uv si no lo tienes
pip install uv

# Crear y activar entorno virtual
uv venv
source .venv/bin/activate  # En Windows: .venv\Scripts\activate

# Instalar dependencias
uv pip install -r requirements.txt
```

### 3. Configurar variables de entorno
El archivo `.env` no se sube al repositorio (está en `.gitignore`) por buenas prácticas de seguridad. En su lugar, copia el archivo de ejemplo:

```bash
# Copiar el archivo de ejemplo
cp .env.example .env
```

Luego edita el archivo `.env` con tus configuraciones:

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

### 4. Ejecutar los servicios
```bash
# Levantar todos los servicios
docker-compose up -d

# Ver logs en tiempo real
docker-compose logs -f
```

## 📊 Acceso a los Servicios

### PostgreSQL
- **Host**: localhost
- **Puerto**: 5432 (o el configurado en POSTGRES_PORT)
- **Base de datos**: mydatabase (o la configurada en POSTGRES_DB)
- **Usuario**: postgres (o el configurado en POSTGRES_USER)
- **Contraseña**: mysecretpassword (o la configurada en POSTGRES_PASSWORD)

### pgAdmin
- **URL**: http://localhost:8080 (o el puerto configurado en PGADMIN_PORT)
- **Email**: admin@admin.com (o el configurado en PGADMIN_EMAIL)
- **Contraseña**: admin123 (o la configurada en PGADMIN_PASSWORD)

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
├── requirements.txt            # Dependencias de Python
├── data/                       # Carpeta para datos del proyecto
│   └── .gitkeep               # Mantiene la carpeta en git
├── init-scripts/               # Scripts de inicialización de la base de datos
│   ├── 1-schema.sql           # Creación del esquema
│   ├── 2-load_data.sql        # Carga de datos
│   └── .gitkeep               # Mantiene la carpeta en git
├── Clases/                     # Material de clases y notebooks
│   ├── 00_Introducción/
│   ├── 01_Bases_De_Datos/
│   └── 02_SQL/
└── README.md                   # Este archivo
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

## 📊 Carga de Datos

El sistema carga automáticamente los datos desde la carpeta `data/` usando los scripts en `init-scripts/`:

### Características de la carga:
- ✅ **Carga automática**: Los scripts se ejecutan al inicializar PostgreSQL
- ✅ **Manejo de errores**: `\set ON_ERROR_STOP off` permite que continúe si hay errores
- ✅ **Flexibilidad**: Puedes modificar los scripts según tus necesidades
- ✅ **Verificación**: Incluye scripts de verificación de integridad

### Estructura de scripts:
- `1-schema.sql` - Creación de tablas y esquemas
- `2-load_data.sql` - Carga de datos desde archivos CSV/TSV
- `3-verify_data.sql` - Verificación de integridad (opcional)

### Cómo agregar tus datos:
1. Coloca tus archivos de datos en la carpeta `data/`
2. Modifica `1-schema.sql` para crear las tablas necesarias
3. Actualiza `2-load_data.sql` para cargar tus datos específicos
4. Reinicia los contenedores: `docker-compose down && docker-compose up -d`

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

### Tiempo de carga de datos
La carga inicial puede tomar tiempo dependiendo del tamaño de tus archivos:
- **Archivos pequeños** (< 1MB): Carga rápida
- **Archivos medianos** (1-100MB): Carga media
- **Archivos grandes** (> 100MB): Carga lenta (puede tomar varios minutos)

**Consejo**: Para monitorear el progreso de la carga, ejecuta:
```bash
docker-compose logs -f postgres
```

### Problemas con el entorno virtual
Si tienes problemas con el entorno virtual:
```bash
# Recrear el entorno virtual
rm -rf .venv
uv venv
source .venv/bin/activate
uv pip install -r requirements.txt
```
