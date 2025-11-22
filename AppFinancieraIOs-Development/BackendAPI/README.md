# Backend API - Aplicación Financiera iOS

API REST en ASP.NET Core 8.0 con Entity Framework Core y PostgreSQL 18 para gestión de datos financieros.

## 📋 Requisitos

- [.NET 8.0 SDK](https://dotnet.microsoft.com/download/dotnet/8.0)
- [PostgreSQL 18](https://www.postgresql.org/download/)
- [pgAdmin](https://www.pgadmin.org/download/) (opcional)

## ⚙️ Configuración

### 1. Configurar PostgreSQL

1. Instala PostgreSQL 18
2. Abre pgAdmin y ejecuta el script `SQL/01_CreateDatabase.sql` para crear la base de datos

### 2. Configurar Cadena de Conexión

Edita `appsettings.json` y actualiza la cadena de conexión:

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Host=localhost;Port=5432;Database=FinancialAppDB;Username=postgres;Password=TU_CONTRASEÑA"
  }
}
```

### 3. Instalar Dependencias y Crear la Base de Datos

```bash
# Restaurar paquetes NuGet
dotnet restore

# Crear migración inicial
dotnet ef migrations add InitialCreate

# Aplicar migraciones (crear tablas)
dotnet ef database update
```

## 🏃‍♂️ Ejecutar el Proyecto

```bash
# Ejecutar en modo desarrollo
dotnet run

# O con recarga automática
dotnet watch run
```

La API estará disponible en:
- **HTTP**: http://localhost:5000
- **HTTPS**: https://localhost:5001
- **Swagger UI**: http://localhost:5000

## 📚 Endpoints de la API

### Ingresos
- `GET /api/incomes` - Listar ingresos
- `POST /api/incomes` - Crear ingreso
- `PUT /api/incomes/{id}` - Actualizar ingreso
- `DELETE /api/incomes/{id}` - Eliminar ingreso
- `GET /api/incomes/summary` - Resumen de ingresos

### Gastos
- `GET /api/expenses` - Listar gastos
- `POST /api/expenses` - Crear gasto
- `PUT /api/expenses/{id}` - Actualizar gasto
- `DELETE /api/expenses/{id}` - Eliminar gasto
- `GET /api/expenses/summary` - Resumen de gastos

### Deducciones
- `GET /api/deductions` - Listar deducciones
- `POST /api/deductions` - Crear deducción
- `PUT /api/deductions/{id}` - Actualizar deducción
- `DELETE /api/deductions/{id}` - Eliminar deducción

### Períodos Financieros
- `GET /api/financialperiods` - Listar períodos
- `POST /api/financialperiods` - Crear período
- `GET /api/financialperiods/current` - Obtener período actual

### Cálculos de Impuestos
- `POST /api/taxcalculations/calculate` - Calcular impuestos
- `POST /api/taxcalculations` - Guardar cálculo

## 🗄️ Estructura de Base de Datos

### Tablas
- **Incomes** - Ingresos
- **Expenses** - Gastos
- **Deductions** - Deducciones fiscales
- **FinancialPeriods** - Períodos financieros
- **TaxCalculations** - Cálculos de impuestos

Ver scripts SQL en la carpeta `SQL/` para más detalles.

## 🔧 Comandos Útiles de Entity Framework

```bash
# Crear nueva migración
dotnet ef migrations add NombreMigracion

# Aplicar migraciones
dotnet ef database update

# Revertir migración
dotnet ef database update NombreMigracionAnterior

# Eliminar última migración (si no se aplicó)
dotnet ef migrations remove

# Ver migraciones
dotnet ef migrations list
```

## 📱 Integración con iOS

Para conectar la app iOS:

1. Usa la IP de tu máquina en lugar de `localhost`
2. Ejemplo de URL: `http://192.168.1.X:5000/api/incomes`
3. Configura CORS en `appsettings.json` si es necesario

Ejemplo de llamada con URLSession:

```swift
let url = URL(string: "http://192.168.1.X:5000/api/incomes")!
var request = URLRequest(url: url)
request.httpMethod = "GET"
request.setValue("application/json", forHTTPHeaderField: "Content-Type")

let (data, _) = try await URLSession.shared.data(for: request)
let incomes = try JSONDecoder().decode([Income].self, from: data)
```

## 📂 Estructura del Proyecto

```
BackendAPI/
├── Models/           # Modelos de datos
├── Data/            # DbContext de Entity Framework
├── Controllers/     # Controladores de la API
├── DTOs/           # Data Transfer Objects
├── SQL/            # Scripts SQL para pgAdmin
└── README.md       # Este archivo
```

## 🐳 Docker (Opcional)

Para ejecutar PostgreSQL en Docker:

```bash
docker run --name financial-postgres \
  -e POSTGRES_PASSWORD=tu_password \
  -e POSTGRES_DB=FinancialAppDB \
  -p 5432:5432 \
  -d postgres:18
```

## 📝 Notas

- Las migraciones se aplican automáticamente al iniciar en modo desarrollo
- Todas las fechas están en UTC
- Los importes usan `decimal(18,2)`
- Swagger UI incluye documentación completa de la API
