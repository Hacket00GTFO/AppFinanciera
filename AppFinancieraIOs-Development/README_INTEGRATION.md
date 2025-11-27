# AppFinancieraIOs - Integración Backend y Dockerización

## Resumen de cambios realizados

### 1. **Cliente de Red (Networking)**
- ✅ Creado `Appfinancierafuncional/Networking/APIClient.swift`
  - Cliente HTTP centralizado con `async/await` + `URLSession`
  - Métodos para CRUD: `getIncomes()`, `createIncome()`, `updateIncome()`, `deleteIncome()`
  - Análogos para Expenses, Deductions, TaxCalculations
  - Manejo de errores: `APIError` con casos personalizados
  - Soporte para filtros: `startDate`, `endDate`, `category`
  - Decodificación JSON automática con `JSONDecoder` (ISO8601, camelCase)

### 2. **Configuración de URL Base**
- ✅ Adición de `API_BASE_URL` en Info.plist (ver `SETUP_API_CONFIG.md`)
  - Lee desde Info.plist → fallback a `http://localhost:5000/api`
  - Soporta múltiples entornos: desarrollo, simulador, producción

### 3. **Modelos Actualizados**
- ✅ `Models/Income.swift` - UUID, inicializadores, CodingKeys
- ✅ `Models/Expense.swift` - UUID, inicializadores, ignora `receiptImage` en JSON
- ✅ `Models/Deduction.swift` - UUID, inicializadores
- ✅ `Models/TaxCalculation.swift` - UUID, inicializadores con defaults

### 4. **ViewModels con Consumo de API**
- ✅ `ViewModels/IncomeViewModel.swift`
  - `fetchIncomes()` → GET `/api/incomes` con filtros opcionales
  - `addIncome()` → POST `/api/incomes`
  - `updateIncome()` → PUT `/api/incomes/{id}`
  - `deleteIncome()` → DELETE `/api/incomes/{id}`
  - Estados: `@Published isLoading`, `errorMessage`

- ✅ `ViewModels/ExpensesViewModel.swift`
  - `fetchExpenses()` → GET `/api/expenses` con filtros
  - `addExpense()`, `removeExpense()`, `updateExpense()`
  - Recalcula totales por categoría automáticamente

- ✅ `ViewModels/DeductionsViewModel.swift`
  - `fetchDeductions()` → GET `/api/deductions`
  - CRUD: `addDeduction()`, `updateDeduction()`, `deleteDeduction()`

### 5. **Diseño Glass Morphism**
- ✅ Creado `Utils/GlassStyles.swift`
  - `GlassCard` modifier: efecto translúcido con sombra
  - `GlassBackground` modifier: Material.ultraThinMaterial
  - `FrostedBlur` view: blur translúcido
  - `GlassButtonStyle`: botón con efecto glass
  - `GlassCardContainer`: contenedor reutilizable
  - Gradientes: `glassGradient`, `glassGradientDark`

- ✅ Actualizado `Utils/Constants.swift`
  - Nuevo struct `API` con `baseURL`
  - Colores expandidos: glass tints, overlays

- ✅ Refactorizado `Utils/FloatingActionButton.swift`
  - Borde translúcido (glass effect)
  - Sombras mejoradas para profundidad

- ✅ Actualizado `Views/Expenses/ExpenseCategoryCard.swift`
  - Aplicado `.glassCard()` modifier
  - Diseño visual moderno con iconos e indentación

### 6. **Documentación**
- ✅ Creado `SETUP_API_CONFIG.md`
  - Instrucciones para configurar Info.plist
  - URLs para diferentes entornos (Docker, simulador, localhost)
  - Troubleshooting y verificación de conectividad

---

## Próximos pasos: Dockerizar Backend y Base de Datos

### Paso 1: Crear `docker-compose.yml` en la raíz del proyecto

```yaml
version: '3.8'

services:
  db:
    image: postgres:15-alpine
    container_name: appfinanciera-db
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres_password_secure
      POSTGRES_DB: FinancialAppDB
    ports:
      - "5432:5432"
    volumes:
      - ./BackendAPI/SQL:/docker-entrypoint-initdb.d:ro
      - pgdata:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 10s
      timeout: 5s
      retries: 5

  backendapi:
    build:
      context: ./BackendAPI
      dockerfile: Dockerfile
    container_name: appfinanciera-api
    environment:
      ConnectionStrings__DefaultConnection: "Host=db;Port=5432;Database=FinancialAppDB;Username=postgres;Password=postgres_password_secure"
      ASPNETCORE_ENVIRONMENT: Development
      ASPNETCORE_URLS: "http://+:80"
      APPLY_MIGRATIONS: "true"
    ports:
      - "5000:80"
    depends_on:
      db:
        condition: service_healthy
    volumes:
      - ./BackendAPI:/app

  pgadmin:
    image: dpage/pgadmin4:latest
    container_name: appfinanciera-pgadmin
    environment:
      PGADMIN_DEFAULT_EMAIL: admin@local
      PGADMIN_DEFAULT_PASSWORD: admin_password_secure
    ports:
      - "8080:80"
    depends_on:
      - db

volumes:
  pgdata:
```

### Paso 2: Crear `BackendAPI/Dockerfile`

```dockerfile
# Stage 1: Build
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

COPY ["BackendAPI.csproj", "./"]
RUN dotnet restore "BackendAPI.csproj"

COPY . .
RUN dotnet build "BackendAPI.csproj" -c Release -o /app/build

# Stage 2: Publish
FROM build AS publish
RUN dotnet publish "BackendAPI.csproj" -c Release -o /app/publish

# Stage 3: Runtime
FROM mcr.microsoft.com/dotnet/aspnet:8.0
WORKDIR /app
COPY --from=publish /app/publish .

EXPOSE 80

ENTRYPOINT ["dotnet", "BackendAPI.dll"]
```

### Paso 3: Corregir scripts SQL en `BackendAPI/SQL/`

Verifica que `01_CreateDatabase.sql` use la extensión correcta:

```sql
-- Opción 1: Usar uuid-ossp (más compatible)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- O Opción 2: Usar pgcrypto (gen_random_uuid)
CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE DATABASE IF NOT EXISTS FinancialAppDB;
```

En `02_CreateTables.sql`, asegúrate que los defaults coinciden:

```sql
CREATE TABLE IF NOT EXISTS incomes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    -- ... otros campos
);
```

### Paso 4: Ajustar `BackendAPI/Program.cs`

Verifica que las migraciones se aplican condicionalmente:

```csharp
var app = builder.Build();

// Aplicar migraciones solo si APPLY_MIGRATIONS es true
var applyMigrations = app.Configuration.GetValue<bool>("ApplyMigrations", true);
if (applyMigrations)
{
    using (var scope = app.Services.CreateScope())
    {
        var dbContext = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        dbContext.Database.Migrate();
    }
}

app.Run();
```

### Paso 5: Cambiar JSON a camelCase en Backend (Opcional pero recomendado)

En `Program.cs`, añade:

```csharp
var jsonOptions = new JsonSerializerOptions
{
    PropertyNamingPolicy = JsonNamingPolicy.CamelCase
};
builder.Services.Configure<JsonOptions>(options =>
{
    options.JsonSerializerOptions.PropertyNamingPolicy = JsonNamingPolicy.CamelCase;
});
```

Esto evita usar `CodingKeys` en Swift. El `APIClient` ya está configurado con `.keyDecodingStrategy = .convertFromSnakeCase`.

---

## Instrucciones para Ejecutar Localmente

### En macOS/Windows con Docker Desktop

```bash
# 1. Navega a la raíz del proyecto
cd /ruta/a/AppFinanciera/AppFinancieraIOs-Development

# 2. Levanta los servicios
docker-compose up -d

# 3. Verifica que los contenedores están corriendo
docker ps

# 4. Revisa los logs
docker-compose logs -f backendapi

# 5. Prueba el endpoint
curl http://localhost:5000/api/incomes
# Deberías obtener: [] o un listado de ingresos

# 6. Abre pgAdmin en http://localhost:8080
# Email: admin@local
# Password: admin_password_secure
# Conecta a: db (hostname), puerto 5432, usuario postgres
```

### En Xcode (Simulador iOS)

1. **Abre `Appfinancierafuncional.xcodeproj`**

2. **Configura Info.plist**
   - Xcode → Selecciona el target `Appfinancierafuncional`
   - Pestaña "Info"
   - Añade clave: `API_BASE_URL`
   - Valor: `http://host.docker.internal:5000/api` (macOS/Windows con Docker Desktop)
   - Valor alternativo: `http://localhost:5000/api` (si en localhost)

3. **Build y Run**
   - Cmd + R o "Play" en Xcode
   - Selecciona un simulador (ej: iPhone 15)

4. **Verifica Logs**
   - Abre Debug → Breakpoints
   - En la vista de consola verás logs del APIClient

### En Linux (sin `host.docker.internal`)

```bash
# Obtén la IP del contenedor
docker inspect appfinanciera-api | grep IPAddress

# Usa esa IP en Info.plist
# Ejemplo: http://172.18.0.2:80/api
```

---

## Testing del Flujo Completo

### Test 1: Obtener listado de Ingresos

```bash
curl http://localhost:5000/api/incomes

# Esperado:
[]

# O si hay datos:
[
  {
    "id": "uuid-aqui",
    "grossAmount": 25000,
    "netAmount": 21328,
    "date": "2025-11-26T10:00:00Z",
    "type": "Freelance",
    "description": "Proyecto web",
    "isRecurring": true,
    "recurringPeriod": "Mensual"
  }
]
```

### Test 2: Crear un Ingreso

```bash
curl -X POST http://localhost:5000/api/incomes \
  -H "Content-Type: application/json" \
  -d '{
    "grossAmount": 30000,
    "netAmount": 25500,
    "date": "2025-11-26T10:00:00Z",
    "type": "Freelance",
    "description": "Nuevo proyecto",
    "isRecurring": false,
    "recurringPeriod": null
  }'
```

### Test 3: En la app iOS

1. Abre la app en el simulador
2. Ve a la sección "Ingresos"
3. Debería mostrar datos desde la API (vacío inicialmente)
4. Toca el botón "+" para añadir un ingreso
5. Verifica que se guarda en la BD (refresh o reinicia la app)

---

## Troubleshooting

### Error: "Red error" en la app
- ✅ Verifica que Docker está corriendo: `docker ps`
- ✅ Verifica que el backend está saludable: `docker-compose logs backendapi`
- ✅ Prueba endpoint con curl: `curl http://localhost:5000/api/incomes`

### Error: "Host not reachable"
- ✅ En Windows/Mac, asegúrate de usar `host.docker.internal`
- ✅ O prueba con localhost: `curl http://localhost:5000/api/incomes`
- ✅ En Linux, obtén la IP del contenedor

### Error: "Decodificación fallida"
- ✅ Backend puede estar devolviendo PascalCase (`GrossAmount` en lugar de `grossAmount`)
- ✅ Aplica el cambio de JSON a camelCase en `Program.cs` (ver Paso 5 arriba)
- ✅ O ajusta `APIClient` con `CodingKeys` personalizados

### Error: "Base de datos no existe"
- ✅ Verifica que los scripts SQL ejecutaron: `docker-compose logs db`
- ✅ Manual: `docker exec -i appfinanciera-db psql -U postgres -f /docker-entrypoint-initdb.d/01_CreateDatabase.sql`

---

## Estructura final del proyecto

```
AppFinancieraIOs-Development/
├── docker-compose.yml                    (Nueva) ← Orquesta backend + DB
├── SETUP_API_CONFIG.md                   (Nueva) ← Config Info.plist
├── README_INTEGRATION.md                 (Este archivo)
├── BackendAPI/
│   ├── Dockerfile                        (Nueva) ← Build backend .NET
│   ├── Program.cs                        (Modificado) ← Migraciones condicionales
│   ├── SQL/
│   │   ├── 01_CreateDatabase.sql
│   │   ├── 02_CreateTables.sql
│   │   ├── 03_InsertSampleData.sql
│   │   └── 04_Queries.sql
│   └── ...
├── Appfinancierafuncional/
│   ├── Appfinancierafuncional/
│   │   ├── Networking/
│   │   │   └── APIClient.swift           (Nueva) ← Cliente HTTP
│   │   ├── Models/
│   │   │   ├── Income.swift              (Modificado)
│   │   │   ├── Expense.swift             (Modificado)
│   │   │   ├── Deduction.swift           (Modificado)
│   │   │   └── TaxCalculation.swift      (Modificado)
│   │   ├── ViewModels/
│   │   │   ├── IncomeViewModel.swift     (Modificado) ← Consumo API
│   │   │   ├── ExpensesViewModel.swift   (Modificado) ← Consumo API
│   │   │   ├── DeductionsViewModel.swift (Modificado) ← Consumo API
│   │   │   └── ReportsViewModel.swift
│   │   ├── Utils/
│   │   │   ├── GlassStyles.swift         (Nueva) ← Glass design
│   │   │   ├── Constants.swift           (Modificado)
│   │   │   └── FloatingActionButton.swift (Modificado)
│   │   ├── Views/
│   │   │   └── Expenses/
│   │   │       └── ExpenseCategoryCard.swift (Modificado) ← Glass design
│   │   ├── Info.plist                    (Modificado) ← API_BASE_URL
│   │   └── ...
│   └── ...
```

---

## Próximos pasos recomendados

1. **Deploy en la nube** (AWS, Azure, Digital Ocean)
   - Cambiar Dockerfile a usar `ASPNETCORE_ENVIRONMENT=Production`
   - Usar variables de entorno seguras (AWS Secrets Manager, etc.)

2. **Autenticación y Autorización**
   - Añadir JWT tokens en `APIClient`
   - Implementar login/logout en iOS

3. **Caching local (CoreData)**
   - Guardar datos localmente para offline-first
   - Sincronizar con backend en background

4. **Testing**
   - Unit tests para `APIClient`
   - Integration tests con servidor mock

5. **Monitoreo**
   - Application Insights / Sentry para errores
   - Logs centralizados

---

## Contacto y Preguntas

Si tienes dudas sobre la integración o el setup de Docker, revisa:
- `SETUP_API_CONFIG.md` - Configuración detallada de Info.plist
- `BackendAPI/README.md` - Instrucciones específicas del backend
- Logs: `docker-compose logs <servicio>`

¡Listo para dockerizar y escalar tu app! 🚀
