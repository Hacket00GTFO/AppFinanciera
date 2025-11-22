# Aplicación Financiera Personal

Aplicación completa para gestión de finanzas personales con frontend en iOS (Swift/SwiftUI) y backend en ASP.NET Core con PostgreSQL.

## Descripción

Sistema de administración financiera que permite registrar ingresos, gastos, deducciones fiscales y calcular impuestos. Incluye visualización de datos mediante gráficos, períodos financieros y categorización detallada de transacciones.

## Estructura del Proyecto

```
AppFinancieraIOs/
├── Appfinancierafuncional/     # Aplicación iOS (Swift/SwiftUI)
│   ├── Models/                 # Modelos de datos
│   ├── Views/                  # Vistas de la aplicación
│   ├── ViewModels/             # Lógica de negocio
│   └── Utils/                  # Utilidades y componentes reutilizables
│
├── BackendAPI/                 # API REST (ASP.NET Core 8.0)
│   ├── Models/                 # Modelos de datos
│   ├── Controllers/            # Controladores API
│   ├── Data/                   # Entity Framework DbContext
│   ├── DTOs/                   # Data Transfer Objects
│   └── SQL/                    # Scripts SQL para PostgreSQL
│
└── README.md                   # Este archivo
```

## Tecnologías Utilizadas

### Frontend (iOS)
- Swift
- SwiftUI
- Core Data (almacenamiento local)
- Combine (manejo de estados)

### Backend
- ASP.NET Core 8.0
- Entity Framework Core
- PostgreSQL 18
- Swagger/OpenAPI

## Funcionalidades

### Gestión de Ingresos
- Registro de ingresos con categorización (Empleo, Freelance, Inversiones)
- Soporte para ingresos recurrentes (semanal, quincenal, mensual, anual)
- Cálculo automático de montos brutos y netos

### Gestión de Gastos
- Categorización de gastos en:
  - Fijos obligatorios (Renta, Préstamos, Impuestos)
  - Fijos reducibles (Servicios, Alimentación, Transporte)
  - Variables (Ocio, Viajes, Suscripciones)
- Gastos recurrentes
- Adjuntar recibos (imágenes)

### Deducciones Fiscales
- Cálculo de ISR (Impuesto Sobre la Renta)
- Cálculo de IMSS (Instituto Mexicano del Seguro Social)
- Subsidio al Empleo
- Deducciones personalizadas

### Períodos Financieros
- Gestión de períodos (semanal, quincenal, mensual)
- Cálculo automático de balance
- Histórico de períodos

### Calculadora de Impuestos
- Cálculo automático de ISR e IMSS
- Basado en tablas fiscales mexicanas 2024
- Visualización del salario neto

### Visualización de Datos
- Gráficos animados de ingresos y gastos
- Dashboard con resumen financiero
- Tarjetas informativas con estadísticas

## Requisitos

### Para el Backend
- .NET 8.0 SDK
- PostgreSQL 18
- pgAdmin (opcional)

### Para el Frontend
- macOS Ventura o superior
- Xcode 15 o superior
- iOS 16.0 o superior

## Instalación y Configuración

### Backend

1. Instalar PostgreSQL 18

2. Crear la base de datos:
   ```bash
   # Ejecutar en pgAdmin el script:
   BackendAPI/SQL/01_CreateDatabase.sql
   ```

3. Configurar la cadena de conexión en `BackendAPI/appsettings.json`:
   ```json
   {
     "ConnectionStrings": {
       "DefaultConnection": "Host=localhost;Port=5432;Database=FinancialAppDB;Username=postgres;Password=TU_CONTRASEÑA"
     }
   }
   ```

4. Restaurar dependencias y crear la base de datos:
   ```bash
   cd BackendAPI
   dotnet restore
   dotnet ef migrations add InitialCreate
   dotnet ef database update
   ```

5. Ejecutar el backend:
   ```bash
   dotnet run
   ```
   
   El servidor estará disponible en:
   - http://localhost:5000
   - https://localhost:5001
   - Swagger UI: http://localhost:5000

### Frontend (iOS)

1. Abrir el proyecto en Xcode:
   ```bash
   open Appfinancierafuncional/Appfinancierafuncional.xcodeproj
   ```

2. Seleccionar el simulador o dispositivo de destino

3. Ejecutar el proyecto (Cmd + R)

## Endpoints de la API

### Ingresos
- `GET /api/incomes` - Listar todos los ingresos
- `POST /api/incomes` - Crear un nuevo ingreso
- `PUT /api/incomes/{id}` - Actualizar un ingreso
- `DELETE /api/incomes/{id}` - Eliminar un ingreso
- `GET /api/incomes/summary` - Obtener resumen de ingresos

### Gastos
- `GET /api/expenses` - Listar todos los gastos
- `POST /api/expenses` - Crear un nuevo gasto
- `PUT /api/expenses/{id}` - Actualizar un gasto
- `DELETE /api/expenses/{id}` - Eliminar un gasto
- `GET /api/expenses/summary` - Obtener resumen de gastos

### Deducciones
- `GET /api/deductions` - Listar todas las deducciones
- `POST /api/deductions` - Crear una nueva deducción
- `PUT /api/deductions/{id}` - Actualizar una deducción
- `DELETE /api/deductions/{id}` - Eliminar una deducción
- `GET /api/deductions/summary` - Obtener resumen de deducciones

### Períodos Financieros
- `GET /api/financialperiods` - Listar todos los períodos
- `POST /api/financialperiods` - Crear un nuevo período
- `GET /api/financialperiods/current` - Obtener el período actual
- `PUT /api/financialperiods/{id}` - Actualizar un período
- `DELETE /api/financialperiods/{id}` - Eliminar un período

### Cálculos de Impuestos
- `POST /api/taxcalculations/calculate` - Calcular impuestos (sin guardar)
- `POST /api/taxcalculations` - Guardar un cálculo de impuestos
- `GET /api/taxcalculations` - Listar todos los cálculos
- `DELETE /api/taxcalculations/{id}` - Eliminar un cálculo

## Base de Datos

### Tablas Principales

**Incomes** - Registro de ingresos
- Id, GrossAmount, NetAmount, Date, Type, Description, IsRecurring, RecurringPeriod

**Expenses** - Registro de gastos
- Id, Amount, Category, Date, Description, IsRecurring, RecurringPeriod, Notes, ReceiptImage

**Deductions** - Registro de deducciones fiscales
- Id, Type, Amount, Percentage, Date, Description

**FinancialPeriods** - Períodos financieros
- Id, Type, StartDate, EndDate, TotalIncome, TotalExpenses, TotalDeductions, Balance, IsCompleted

**TaxCalculations** - Cálculos de impuestos
- Id, GrossSalary, LowerLimit, MarginalPercentage, TotalISR, IMSS, EmploymentSubsidy, NetSalary

## Integración Frontend-Backend

Para conectar la aplicación iOS con el backend:

1. Asegurarse de que el backend esté ejecutándose
2. Obtener la IP local de la máquina donde corre el backend
3. Configurar la URL base en la aplicación iOS:
   ```swift
   let baseURL = "http://192.168.1.X:5000/api"
   ```
4. Realizar las llamadas HTTP usando URLSession o Alamofire

## Documentación Adicional

- `BackendAPI/README.md` - Documentación detallada del backend
- `BackendAPI/SQL/README.md` - Guía de scripts SQL
- Swagger UI - Documentación interactiva de la API en http://localhost:5000

## Scripts SQL Disponibles

La carpeta `BackendAPI/SQL/` contiene:

- `01_CreateDatabase.sql` - Crear la base de datos
- `02_CreateTables.sql` - Crear tablas (opcional, EF lo hace automáticamente)
- `03_InsertSampleData.sql` - Insertar datos de ejemplo para pruebas
- `04_Queries.sql` - Consultas útiles para verificar y analizar datos

## Desarrollo

### Comandos útiles del Backend

```bash
# Restaurar paquetes
dotnet restore

# Ejecutar en modo desarrollo con recarga automática
dotnet watch run

# Crear una nueva migración
dotnet ef migrations add NombreMigracion

# Aplicar migraciones
dotnet ef database update

# Ver migraciones aplicadas
dotnet ef migrations list
```

### Estructura de Datos en Swift

Los modelos en Swift están sincronizados con los modelos del backend:
- Income
- Expense
- ExpenseCategory (enum)
- Deduction
- FinancialPeriod
- TaxCalculation


