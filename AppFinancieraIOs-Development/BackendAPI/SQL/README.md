# Scripts SQL para PostgreSQL

Esta carpeta contiene los scripts SQL necesarios para configurar la base de datos en pgAdmin.

## 📋 Orden de Ejecución

Ejecuta los scripts en el siguiente orden:

1. **01_CreateDatabase.sql** - Crea la base de datos `FinancialAppDB`
2. **02_CreateTables.sql** - Crea todas las tablas (OPCIONAL - Entity Framework las crea automáticamente)
3. **03_InsertSampleData.sql** - Inserta datos de ejemplo (OPCIONAL - solo para pruebas)
4. **04_Queries.sql** - Consultas útiles para verificar y analizar datos

## 🚀 Configuración Rápida

### Opción 1: Dejar que Entity Framework cree las tablas (Recomendado)

1. Ejecuta solo `01_CreateDatabase.sql` en pgAdmin
2. Configura la cadena de conexión en `appsettings.json`
3. Ejecuta: `dotnet ef migrations add InitialCreate`
4. Ejecuta: `dotnet ef database update`

### Opción 2: Crear las tablas manualmente

1. Ejecuta `01_CreateDatabase.sql` en pgAdmin
2. Ejecuta `02_CreateTables.sql` en pgAdmin
3. Ejecuta `03_InsertSampleData.sql` (opcional) en pgAdmin
4. Configura la cadena de conexión en `appsettings.json`
5. El backend está listo para usarse

## 📝 Cómo ejecutar los scripts en pgAdmin

1. Abre pgAdmin
2. Conéctate a tu servidor PostgreSQL
3. Para crear la base de datos:
   - Click derecho en el servidor > "Query Tool"
   - Abre y ejecuta `01_CreateDatabase.sql`
4. Para crear tablas o insertar datos:
   - Click derecho en la base de datos `FinancialAppDB` > "Query Tool"
   - Abre y ejecuta los scripts correspondientes

## 🔍 Verificar la instalación

Usa las consultas en `04_Queries.sql` para verificar que todo esté funcionando correctamente.

