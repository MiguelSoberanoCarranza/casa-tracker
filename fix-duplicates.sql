-- Script para identificar y limpiar duplicados en la tabla de prospectos
-- Ejecutar este script en el SQL Editor de Supabase

-- 1. Primero, vamos a ver cuántos duplicados hay
SELECT 
  nombre, 
  apellido, 
  email, 
  telefono,
  agente_id,
  COUNT(*) as duplicados
FROM prospectos 
GROUP BY nombre, apellido, email, telefono, agente_id
HAVING COUNT(*) > 1
ORDER BY duplicados DESC;

-- 2. Ver todos los prospectos del usuario actual (reemplaza 'USER_ID_AQUI' con el ID real)
-- SELECT * FROM prospectos WHERE agente_id = 'USER_ID_AQUI' ORDER BY fecha_creacion;

-- 3. Eliminar duplicados manteniendo solo el más reciente
-- IMPORTANTE: Ejecutar solo después de verificar los duplicados
WITH duplicados AS (
  SELECT 
    id,
    ROW_NUMBER() OVER (
      PARTITION BY nombre, apellido, email, telefono, agente_id 
      ORDER BY fecha_actualizacion DESC, created_at DESC
    ) as rn
  FROM prospectos
)
DELETE FROM prospectos 
WHERE id IN (
  SELECT id FROM duplicados WHERE rn > 1
);

-- 4. Verificar que no queden duplicados
SELECT 
  nombre, 
  apellido, 
  email, 
  telefono,
  agente_id,
  COUNT(*) as duplicados
FROM prospectos 
GROUP BY nombre, apellido, email, telefono, agente_id
HAVING COUNT(*) > 1;

-- 5. Agregar índice único para prevenir futuros duplicados
-- (Solo si no existe ya)
CREATE UNIQUE INDEX IF NOT EXISTS idx_prospectos_unique 
ON prospectos (nombre, apellido, email, telefono, agente_id) 
WHERE email IS NOT NULL AND email != '';

-- 6. Para prospectos sin email, usar solo nombre, apellido, telefono y agente
CREATE UNIQUE INDEX IF NOT EXISTS idx_prospectos_unique_no_email 
ON prospectos (nombre, apellido, telefono, agente_id) 
WHERE email IS NULL OR email = '';
