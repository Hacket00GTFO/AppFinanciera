#!/bin/bash

# Script para levantar AppFinancieraIOs con Docker en macOS/Linux
# Uso: ./start-docker.sh

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Banner
echo -e "${BLUE}"
echo "================================================"
echo "  AppFinancieraIOs - Docker Startup Script"
echo "  macOS/Linux Version"
echo "================================================"
echo -e "${NC}"

# Verificar si Docker está instalado
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Error: Docker no está instalado${NC}"
    echo "Descargalo desde: https://www.docker.com/products/docker-desktop"
    exit 1
fi

# Verificar si Docker daemon está corriendo
if ! docker ps &> /dev/null; then
    echo -e "${RED}❌ Error: Docker no está corriendo${NC}"
    echo "Inicia Docker Desktop desde Applications/Docker.app"
    exit 1
fi

echo -e "${GREEN}✓ Docker está instalado y corriendo${NC}"

# Obtener el directorio del script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

echo -e "${BLUE}Directorio de trabajo: ${SCRIPT_DIR}${NC}"

# Verificar que docker-compose.yml existe
if [ ! -f "docker-compose.yml" ]; then
    echo -e "${RED}❌ Error: docker-compose.yml no encontrado en ${SCRIPT_DIR}${NC}"
    exit 1
fi

echo -e "${BLUE}──────────────────────────────────────────${NC}"
echo -e "${YELLOW}1. Deteniendo contenedores existentes...${NC}"
docker-compose down --remove-orphans 2>/dev/null || true

echo -e "${YELLOW}2. Levantando contenedores (esto puede tardar 30-60 segundos)...${NC}"
docker-compose up -d

# Esperar a que los servicios estén listos
echo -e "${YELLOW}3. Esperando a que los servicios estén listos...${NC}"
sleep 5

# Verificar estado de los servicios
echo -e "${BLUE}──────────────────────────────────────────${NC}"
echo -e "${YELLOW}4. Verificando estado de los servicios...${NC}"

# Verificar DB
if docker-compose exec -T db pg_isready -U postgres &> /dev/null; then
    echo -e "${GREEN}✓ PostgreSQL está listo${NC}"
else
    echo -e "${YELLOW}⚠ PostgreSQL aún está iniciando...${NC}"
    sleep 5
fi

# Verificar Backend
BACKEND_HEALTH=$(curl -s http://localhost:5000/api/incomes 2>/dev/null || echo "")
if [ ! -z "$BACKEND_HEALTH" ]; then
    echo -e "${GREEN}✓ Backend API está listo en http://localhost:5000${NC}"
else
    echo -e "${YELLOW}⚠ Backend API aún está iniciando...${NC}"
fi

# Mostrar información de acceso
echo -e "${BLUE}──────────────────────────────────────────${NC}"
echo -e "${GREEN}✅ Servicios levantados correctamente${NC}"
echo -e "${BLUE}──────────────────────────────────────────${NC}"
echo ""
echo -e "${YELLOW}📍 Endpoints disponibles:${NC}"
echo -e "  ${GREEN}Backend API:${NC} http://localhost:5000/api"
echo -e "  ${GREEN}PgAdmin:${NC}      http://localhost:8080"
echo -e "  ${GREEN}PostgreSQL:${NC}   localhost:5432"
echo ""
echo -e "${YELLOW}🔐 Credenciales:${NC}"
echo -e "  ${GREEN}PgAdmin Email:${NC}    admin@local"
echo -e "  ${GREEN}PgAdmin Password:${NC} admin_password_secure"
echo -e "  ${GREEN}PostgreSQL User:${NC}  postgres"
echo -e "  ${GREEN}PostgreSQL Pass:${NC}  postgres_password_secure"
echo ""
echo -e "${YELLOW}📱 Configuración Xcode:${NC}"
echo -e "  ${GREEN}Target:${NC} Appfinancierafuncional"
echo -e "  ${GREEN}Info.plist → API_BASE_URL:${NC} http://host.docker.internal:5000/api"
echo ""
echo -e "${YELLOW}🧪 Test de conectividad:${NC}"
echo -e "  ${GREEN}curl http://localhost:5000/api/incomes${NC}"
echo ""
echo -e "${YELLOW}🛑 Para detener los servicios:${NC}"
echo -e "  ${GREEN}docker-compose down${NC}"
echo ""
echo -e "${BLUE}──────────────────────────────────────────${NC}"

# Mostrar logs en opción
read -p "¿Ver logs del backend en tiempo real? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    docker-compose logs -f backendapi
fi
