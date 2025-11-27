# Optimización: JSON camelCase en Backend

## Problema actual

El backend .NET emite JSON en **PascalCase** por defecto:
```json
{
  "GrossAmount": 25000,
  "NetAmount": 21328,
  "Date": "2025-11-26T10:00:00Z"
}
```

Swift espera **camelCase** por convención:
```json
{
  "grossAmount": 25000,
  "netAmount": 21328,
  "date": "2025-11-26T10:00:00Z"
}
```

## Solución: Configurar JSON en camelCase en Program.cs

### Paso 1: Abre `BackendAPI/Program.cs`

Busca la línea que comienza con `var builder = WebApplicationBuilder.CreateBuilder(args);`

### Paso 2: Añade configuración JSON después de `var builder = ...`

```csharp
var builder = WebApplicationBuilder.CreateBuilder(args);

// Configurar JSON para usar camelCase (compatible con Swift)
var jsonOptions = new JsonSerializerOptions
{
    PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
    WriteIndented = true // Opcional: para debugging
};

// Aplica a todos los Controllers
builder.Services.Configure<JsonOptions>(options =>
{
    options.JsonSerializerOptions.PropertyNamingPolicy = JsonNamingPolicy.CamelCase;
    options.JsonSerializerOptions.WriteIndented = true;
});

// Resto de configuraciones...
builder.Services.AddControllers();
// ... más código
```

### Paso 3: Verifica que se aplica en todas las respuestas

Ubica la línea `app.MapControllers()` y asegúrate que está después de todas las configuraciones de servicios.

### Paso 4: Rebuild y reinicia el backend

```bash
# Opción 1: Si estás usando Docker
docker-compose up -d --build backendapi

# Opción 2: Si ejecutas localmente en Visual Studio
# Click derecho en el proyecto → Rebuild → Run
```

### Paso 5: Verifica la salida

```bash
# Prueba el endpoint
curl http://localhost:5000/api/incomes

# Deberías ver camelCase:
{
  "id": "...",
  "grossAmount": 25000,
  "netAmount": 21328,
  "date": "2025-11-26T10:00:00Z",
  "type": "Freelance",
  "description": "...",
  "isRecurring": true,
  "recurringPeriod": "Mensual",
  "createdAt": "...",
  "updatedAt": "..."
}
```

---

## Alternativa: Si NO cambias el Backend

Si prefieres que el backend siga en **PascalCase**, el `APIClient.swift` ya está configurado para convertir automáticamente:

```swift
self.decoder.keyDecodingStrategy = .convertFromSnakeCase
```

Aunque `convertFromSnakeCase` está pensado para snake_case, también convierte PascalCase a camelCase de forma parcial. Para mejor compatibilidad, es recomendable el cambio en el backend.

---

## Comparación: Antes vs Después

### Antes (sin cambios en backend)

Backend emite: `GrossAmount` (PascalCase)  
Swift espera: `grossAmount` (camelCase)  
Solución en iOS: `.convertFromSnakeCase` (parcial, no 100% confiable)

### Después (con cambios en backend)

Backend emite: `grossAmount` (camelCase)  
Swift espera: `grossAmount` (camelCase)  
Solución en iOS: Funciona perfecto ✅

---

## Archivos a modificar en Backend

```
BackendAPI/
├── Program.cs                   ← MODIFICAR (añade JsonOptions)
├── Controllers/
│   ├── IncomesController.cs     ← Sin cambios (heredan configuración)
│   ├── ExpensesController.cs    ← Sin cambios
│   ├── DeductionsController.cs  ← Sin cambios
│   └── ...
├── DTOs/
│   ├── IncomeDto.cs             ← Sin cambios (los nombres ya son correctos)
│   └── ...
└── ...
```

Solo necesitas modificar `Program.cs`. Los DTOs y Controllers no necesitan cambios.

---

## Verificación de diferencias

### Antes (PascalCase)
```json
[
  {
    "Id": "123e4567-e89b-12d3-a456-426614174000",
    "GrossAmount": 25000,
    "NetAmount": 21328,
    "Date": "2025-11-26T10:00:00Z",
    "Type": "Freelance",
    "Description": "Proyecto web",
    "IsRecurring": true,
    "RecurringPeriod": "Mensual",
    "CreatedAt": "2025-11-26T09:00:00Z",
    "UpdatedAt": "2025-11-26T09:00:00Z"
  }
]
```

### Después (camelCase)
```json
[
  {
    "id": "123e4567-e89b-12d3-a456-426614174000",
    "grossAmount": 25000,
    "netAmount": 21328,
    "date": "2025-11-26T10:00:00Z",
    "type": "Freelance",
    "description": "Proyecto web",
    "isRecurring": true,
    "recurringPeriod": "Mensual",
    "createdAt": "2025-11-26T09:00:00Z",
    "updatedAt": "2025-11-26T09:00:00Z"
  }
]
```

---

## Testing post-cambio

```bash
# Reinicia Docker
docker-compose down
docker-compose up -d --build

# Espera a que el backend esté listo (5-10 segundos)
sleep 10

# Test curls
curl http://localhost:5000/api/incomes | jq '.'

# Debería mostrar JSON en camelCase
```

---

## Rollback (si algo falla)

Si necesitas revertir:

```bash
# Comenta o elimina la sección JsonOptions en Program.cs
# Guarda cambios
# Rebuild:
docker-compose up -d --build backendapi
```

---

**Recomendación**: Aplica este cambio. Solo requiere una modificación pequeña en `Program.cs` y elimina posibles problemas de deserialización en Swift. ✅
