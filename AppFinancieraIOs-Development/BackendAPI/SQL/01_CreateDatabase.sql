-- =========================================
-- Script para crear la base de datos
-- =========================================
-- Ejecuta este script en pgAdmin conectado al servidor PostgreSQL
-- (no a una base de datos específica, usa la base 'postgres')

-- Eliminar la base de datos si existe (opcional - solo para desarrollo)
-- DROP DATABASE IF EXISTS "FinancialAppDB";

-- Crear la base de datos
CREATE DATABASE "FinancialAppDB"
    WITH 
    OWNER = postgres
    ENCODING = 'UTF8'
    LC_COLLATE = 'Spanish_Mexico.1252'
    LC_CTYPE = 'Spanish_Mexico.1252'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1
    IS_TEMPLATE = False;

COMMENT ON DATABASE "FinancialAppDB"
    IS 'Base de datos para la aplicación financiera personal';

-- Conectar a la nueva base de datos
\c FinancialAppDB;

-- Crear extensión para UUID (opcional, pero recomendado)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

