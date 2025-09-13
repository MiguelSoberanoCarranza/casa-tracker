-- Script para resetear la base de datos
-- ⚠️ CUIDADO: Este script eliminará TODOS los datos existentes
-- Solo ejecutar si necesitas empezar desde cero

-- Eliminar tablas en orden inverso (por las dependencias)
DROP TABLE IF EXISTS seguimientos CASCADE;
DROP TABLE IF EXISTS prospectos CASCADE;
DROP TABLE IF EXISTS agentes CASCADE;

-- Eliminar funciones si existen
DROP FUNCTION IF EXISTS update_updated_at_column() CASCADE;
DROP FUNCTION IF EXISTS estadisticas_agente(UUID) CASCADE;

-- Eliminar vistas si existen
DROP VIEW IF EXISTS vista_dashboard CASCADE;

-- Ahora ejecutar el script principal: supabase-schema.sql
