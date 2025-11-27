# Guía Rápida: Ejecutar AppFinancieraIOs con Docker

## 🚀 Start (Iniciar todo)

### 1️⃣ Desde PowerShell (Windows)

```powershell
# Navega a la carpeta raíz del proyecto
cd C:\Users\Norbe\OneDrive -\Desktop\repositorios\AppFinanciera\AppFinancieraIOs-Development

# Levanta los servicios
docker-compose up -d

# Verifica que están corriendo
docker-compose ps

# Ve los logs
docker-compose logs -f backendapi
```

### 2️⃣ Desde Terminal (macOS/Linux)

```bash
# Navega a la carpeta raíz
cd ~/ruta/a/AppFinanciera/AppFinancieraIOs-Development

# Levanta los servicios
docker-compose up -d

# Verifica estado
docker-compose ps

# Logs
docker-compose logs -f backendapi
```

---

## ✅ Verificación de conectividad

### Desde PowerShell/Terminal

```bash
# Test 1: ¿Está corriendo el backend?
curl http://localhost:5000/api/incomes

# Test 2: ¿Está corriendo la BD?
docker exec appfinanciera-db psql -U postgres -c "SELECT version();"

# Test 3: ¿Está corriendo PgAdmin?
# Abre en el navegador: http://localhost:8080
# Email: admin@local
# Password: admin_password_secure
```

---

## 📱 Configurar la App iOS

### En Xcode

1. Abre `Appfinancierafuncional.xcodeproj`
2. Selecciona el target `Appfinancierafuncional`
3. Ve a la pestaña "Info"
4. Añade o edita la clave `API_BASE_URL`:
   - **Windows + Docker Desktop**: `http://host.docker.internal:5000/api`
   - **macOS + Docker Desktop**: `http://host.docker.internal:5000/api`
   - **Simulador en localhost**: `http://localhost:5000/api`

5. Build & Run (Cmd + R)

---

## 🛑 Stop (Detener todo)

```bash
# Detiene los contenedores pero mantiene los datos
docker-compose stop

# Detiene y elimina los contenedores (pero no los volúmenes)
docker-compose down

# Para eliminar TODO incluyendo datos:
docker-compose down -v
```

---

## 🔍 Debugging

### Ver logs en tiempo real

```bash
# Logs del backend
docker-compose logs -f backendapi

# Logs de la BD
docker-compose logs -f db

# Logs de PgAdmin
docker-compose logs -f pgadmin
```

### Acceder a la BD directamente

```bash
# Entra en psql interactivo
docker exec -it appfinanciera-db psql -U postgres -d FinancialAppDB

# Ejemplo de query
SELECT * FROM incomes;
```

### Rebuild el backend (si cambiaste código C#)

```bash
docker-compose down backendapi
docker-compose up -d backendapi --build
```

---

## 📊 Endpoints de ejemplo

```bash
# GET: Obtener todos los ingresos
curl http://localhost:5000/api/incomes

# POST: Crear un ingreso
curl -X POST http://localhost:5000/api/incomes \
  -H "Content-Type: application/json" \
  -d '{
    "grossAmount": 25000,
    "netAmount": 21328,
    "date": "2025-11-26T10:00:00Z",
    "type": "Freelance",
    "description": "Proyecto web",
    "isRecurring": true,
    "recurringPeriod": "Mensual"
  }'

# GET: Resumen de ingresos
curl http://localhost:5000/api/incomes/summary

# GET: Obtener gastos
curl http://localhost:5000/api/expenses

# GET: Obtener deducciones
curl http://localhost:5000/api/deductions

# POST: Calcular impuestos
curl -X POST http://localhost:5000/api/taxcalculations/calculate \
  -H "Content-Type: application/json" \
  -d '{"grossSalary": 25000}'
```

---

## 🐛 Soluciones rápidas

| Problema | Solución |
|----------|----------|
| "Host not reachable" | Verifica que Docker está corriendo, usa `host.docker.internal` en macOS/Windows |
| Error de conexión a BD | Espera 10 segundos después de `docker-compose up` (healthcheck) |
| Puertos en uso (5000, 5432) | `docker-compose down` primero o cambia puertos en `docker-compose.yml` |
| Base de datos vacía | Los scripts SQL (`/SQL/*.sql`) se ejecutan automáticamente al iniciar |
| App no ve datos | Verifica `API_BASE_URL` en Info.plist y que curl funciona |

---

## 📝 Estructura de archivos generados

```
AppFinancieraIOs-Development/
├── docker-compose.yml                   ← Orquestación de servicios
├── BackendAPI/
│   ├── Dockerfile                       ← Build del backend
│   └── SQL/
│       ├── 01_CreateDatabase.sql        ← Scripts ejecutados automáticamente
│       ├── 02_CreateTables.sql
│       ├── 03_InsertSampleData.sql
│       └── 04_Queries.sql
├── Appfinancierafuncional/
│   ├── Appfinancierafuncional/
│   │   ├── Networking/APIClient.swift   ← Cliente HTTP
│   │   ├── Utils/GlassStyles.swift      ← Diseño Glass
│   │   ├── ViewModels/*ViewModel.swift  ← Consumo de API
│   │   └── Info.plist                   ← Configuración API_BASE_URL
│   └── ...
├── README_INTEGRATION.md                ← Documentación completa
├── SETUP_API_CONFIG.md                  ← Config de Info.plist
└── QUICK_START.md                       ← Este archivo
```

---

## 💡 Tips

- **Desarrollo**: Mantén `docker-compose up -d` corriendo en background mientras desarrollas
- **Datos de prueba**: Los scripts SQL en `/SQL/03_InsertSampleData.sql` se cargan automáticamente
- **Cambios en .NET**: Si cambias código backend, rebuild con `docker-compose up -d backendapi --build`
- **CORS**: Si la app da error de CORS, ajusta `CORS_ALLOWED_ORIGINS` en `docker-compose.yml`

---

¡Lista tu infraestructura! 🎉
