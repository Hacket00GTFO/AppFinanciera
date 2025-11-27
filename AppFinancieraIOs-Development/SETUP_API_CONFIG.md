# Configuración de API para AppFinancieraIOs

## Setup de API_BASE_URL en Info.plist

Para configurar la URL base de la API en tu aplicación iOS, sigue estos pasos:

### Opción 1: Xcode UI (Recomendado)
1. Abre el proyecto en Xcode
2. Selecciona el target `Appfinancierafuncional`
3. Ve a la pestaña "Info"
4. Añade una nueva fila con la tecla `API_BASE_URL` (tipo String)
5. Establece el valor según tu entorno:
   - **Desarrollo local (Docker Desktop en Mac/Windows):** `http://host.docker.internal:5000/api`
   - **Simulador iOS en localhost:** `http://localhost:5000/api`
   - **Dispositivo físico en tu red local:** `http://192.168.x.x:5000/api` (ajusta IP según tu red)
   - **Producción:** `https://api.tudominio.com/api`

### Opción 2: Editar Info.plist como fuente XML
1. Click derecho en `Info.plist` → "Open As" → "Source Code"
2. Busca la línea de cierre `</dict>` antes de `</plist>`
3. Añade antes de `</dict>`:
```xml
<key>API_BASE_URL</key>
<string>http://host.docker.internal:5000/api</string>
```
4. Guarda y vuelve a "Open As" → "Property List"

### Opción 3: Configuración por esquemas (para múltiples entornos)
1. Edita el esquema del proyecto (`Product` → `Scheme` → `Edit Scheme`)
2. Ve a "Build" → Variables de entorno o argumentos de ejecución
3. Establece variables según el entorno

## Ejemplo de Info.plist completo (XML)
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- ... otras configuraciones ... -->
    <key>API_BASE_URL</key>
    <string>http://host.docker.internal:5000/api</string>
</dict>
</plist>
```

## Pruebas con Docker

### En macOS con Docker Desktop
```bash
# Inicia el backend desde la raíz del proyecto
docker-compose up -d

# En Xcode, configura Info.plist con:
# API_BASE_URL = http://host.docker.internal:5000/api

# El simulador puede comunicarse con contenedores en host.docker.internal
```

### En Windows con Docker Desktop
```powershell
# Inicia el backend desde la raíz del proyecto
docker-compose up -d

# En Xcode, configura Info.plist con:
# API_BASE_URL = http://host.docker.internal:5000/api

# Windows 10+ y Docker Desktop soportan host.docker.internal
```

### En Linux (sin host.docker.internal)
```bash
# Obtén la IP del contenedor o del host
docker inspect <container_name> | grep IPAddress
# O usa el nombre del servicio (si en la misma red):
# API_BASE_URL = http://backendapi:80/api
```

## Verificar conectividad

### 1. Verifica que el backend está corriendo
```bash
curl http://localhost:5000/api/incomes
# Deberías obtener: [] o un listado de ingresos
```

### 2. En el simulador iOS, abre la consola de debug
- Puedes ver logs de APIClient en Xcode → Debug navigator
- Busca mensajes de error si algo falla

### 3. Test manual en Postman
```
GET http://localhost:5000/api/incomes
Content-Type: application/json

# Response esperado:
[]
```

## Troubleshooting

### Error: "Network Error" en la app
- Verifica que `API_BASE_URL` está correctamente configurado en Info.plist
- Abre Developer Settings en el simulador y activa "Network Link Conditioner" para ver tráfico
- Revisa los logs en Xcode Console

### Error: "Respuesta inválida del servidor"
- El backend puede no estar expuesto en el puerto 5000
- Verifica que `docker-compose.yml` tiene el mapeo de puerto correcto: `5000:80`
- Ejecuta `docker ps` para ver los puertos activos

### Error: "Host not reachable"
- En macOS/Windows: `host.docker.internal` no está disponible
- Alternativa: cambia a IP local del host (ej: `192.168.1.100:5000`)
- O usa la IP del contenedor directamente

## Variables de entorno en tiempo de compilación

Si prefieres no hardcodear la URL en Info.plist, puedes usar Build Settings:

1. Project → Build Settings → Busca "Other Swift Flags"
2. Añade: `-D API_BASE_URL="http://host.docker.internal:5000/api"`
3. En el código Swift, accede con: `#if DEBUG`

Pero esto requiere recompilación. Usa Info.plist para configuración en runtime.
