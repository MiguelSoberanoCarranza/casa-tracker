-- Script para agregar columna 'activo' a la tabla prospectos para borrado lógico
-- Ejecutar este script en el SQL Editor de Supabase

-- Agregar columna 'activo' a la tabla prospectos
ALTER TABLE prospectos 
ADD COLUMN activo BOOLEAN DEFAULT true;

-- Crear índice para mejorar el rendimiento de consultas que filtren por activo
CREATE INDEX idx_prospectos_activo ON prospectos(activo);

-- Crear índice compuesto para consultas que filtren por agente y activo
CREATE INDEX idx_prospectos_agente_activo ON prospectos(agente_id, activo);

-- Actualizar todos los prospectos existentes para que estén activos por defecto
UPDATE prospectos SET activo = true WHERE activo IS NULL;

-- Agregar comentario a la columna para documentación
COMMENT ON COLUMN prospectos.activo IS 'Indica si el prospecto está activo (true) o eliminado lógicamente (false)';

-- Verificar que la columna se agregó correctamente
SELECT column_name, data_type, is_nullable, column_default 
FROM information_schema.columns 
WHERE table_name = 'prospectos' AND column_name = 'activo';
