@echo off
REM Script para levantar AppFinancieraIOs con Docker en Windows
REM Uso: start-docker.bat

setlocal enabledelayedexpansion

REM Colores y símbolos (aproximados para cmd)
cls
echo.
echo ================================================
echo   AppFinancieraIOs - Docker Startup Script
echo   Windows Version
echo ================================================
echo.

REM Verificar si Docker está instalado
where docker >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] Docker no esta instalado
    echo Descargalo desde: https://www.docker.com/products/docker-desktop
    pause
    exit /b 1
)

REM Verificar si Docker daemon está corriendo
docker ps >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] Docker no esta corriendo
    echo Inicia Docker Desktop desde: 
    echo   Inicio ^> Aplicaciones ^> Docker Desktop
    pause
    exit /b 1
)

echo [OK] Docker esta instalado y corriendo
echo.

REM Obtener directorio actual
cd /d "%~dp0"
echo [INFO] Directorio de trabajo: %cd%
echo.

REM Verificar que docker-compose.yml existe
if not exist "docker-compose.yml" (
    echo [ERROR] docker-compose.yml no encontrado en %cd%
    pause
    exit /b 1
)

echo ==========================================
echo 1. Deteniendo contenedores existentes...
docker-compose down --remove-orphans 2>nul

echo.
echo 2. Levantando contenedores (esto puede tardar 30-60 segundos)...
docker-compose up -d

REM Esperar a que servicios inicien
echo.
echo 3. Esperando a que los servicios esten listos...
timeout /t 5 /nobreak

echo.
echo ==========================================
echo 4. Verificando estado de los servicios...
echo.

REM Intentar verificar DB
docker-compose exec -T db pg_isready -U postgres >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] PostgreSQL esta listo
) else (
    echo [WAIT] PostgreSQL aun esta iniciando...
    timeout /t 5 /nobreak
)

REM Intentar verificar Backend
curl -s http://localhost:5000/api/incomes >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Backend API esta listo en http://localhost:5000
) else (
    echo [WAIT] Backend API aun esta iniciando...
)

echo.
echo ==========================================
echo [OK] Servicios levantados correctamente
echo ==========================================
echo.
echo [ENDPOINTS DISPONIBLES]
echo   Backend API: http://localhost:5000/api
echo   PgAdmin:     http://localhost:8080
echo   PostgreSQL:  localhost:5432
echo.
echo [CREDENCIALES]
echo   PgAdmin Email:    admin@localhost.com
echo   PgAdmin Password: admin_password_secure
echo   PostgreSQL User:  postgres
echo   PostgreSQL Pass:  postgres_password_secure
echo.
echo [CONFIGURACION XCODE]
echo   Target: Appfinancierafuncional
echo   Info.plist -> API_BASE_URL: http://host.docker.internal:5000/api
echo            (o http://localhost:5000/api si usas simulador local)
echo.
echo [TEST DE CONECTIVIDAD]
echo   curl http://localhost:5000/api/incomes
echo           (verificar en PowerShell o Git Bash)
echo.
echo [PARA DETENER LOS SERVICIOS]
echo   docker-compose down
echo.

echo.
set /p LOGS="Ver logs del backend en tiempo real? (s/n): "
if /i "%LOGS%"=="s" (
    docker-compose logs -f backendapi
)

endlocal
pause
