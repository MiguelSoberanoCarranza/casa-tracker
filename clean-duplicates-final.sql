-- Script final para limpiar duplicados causados por doble click
-- Ejecutar este script en el SQL Editor de Supabase

-- 1. VER DUPLICADOS ANTES DE LIMPIAR
SELECT 
  'ANTES DE LIMPIAR' as estado,
  COUNT(*) as total_prospectos,
  COUNT(DISTINCT CONCAT(nombre, apellido, COALESCE(email, ''), COALESCE(telefono, ''), agente_id)) as prospectos_unicos,
  COUNT(*) - COUNT(DISTINCT CONCAT(nombre, apellido, COALESCE(email, ''), COALESCE(telefono, ''), agente_id)) as duplicados
FROM prospectos;

-- 2. VER DETALLES DE DUPLICADOS
WITH duplicados_detalle AS (
  SELECT 
    nombre, apellido, email, telefono, agente_id,
    COUNT(*) as total_duplicados,
    MIN(fecha_creacion) as primera_creacion,
    MAX(fecha_creacion) as ultima_creacion,
    EXTRACT(EPOCH FROM (MAX(fecha_creacion) - MIN(fecha_creacion))) as diferencia_segundos,
    array_agg(id ORDER BY fecha_creacion) as ids_ordenados
  FROM prospectos 
  GROUP BY nombre, apellido, email, telefono, agente_id
  HAVING COUNT(*) > 1
)
SELECT 
  nombre, apellido, total_duplicados, diferencia_segundos,
  CASE 
    WHEN diferencia_segundos < 5 THEN 'DOBLE CLICK (menos de 5 segundos)'
    WHEN diferencia_segundos < 60 THEN 'CLICKS RÁPIDOS (menos de 1 minuto)'
    ELSE 'DUPLICACIÓN MANUAL'
  END as tipo_duplicacion,
  ids_ordenados
FROM duplicados_detalle
ORDER BY diferencia_segundos ASC;

-- 3. ELIMINAR DUPLICADOS MANTENIENDO EL MÁS RECIENTE
-- (Ejecutar solo después de verificar los duplicados)
WITH duplicados_para_eliminar AS (
  SELECT 
    id,
    ROW_NUMBER() OVER (
      PARTITION BY nombre, apellido, email, telefono, agente_id 
      ORDER BY fecha_actualizacion DESC, created_at DESC, id DESC
    ) as rn
  FROM prospectos
)
DELETE FROM prospectos 
WHERE id IN (
  SELECT id FROM duplicados_para_eliminar WHERE rn > 1
);

-- 4. VER RESULTADO DESPUÉS DE LIMPIAR
SELECT 
  'DESPUÉS DE LIMPIAR' as estado,
  COUNT(*) as total_prospectos,
  COUNT(DISTINCT CONCAT(nombre, apellido, COALESCE(email, ''), COALESCE(telefono, ''), agente_id)) as prospectos_unicos,
  COUNT(*) - COUNT(DISTINCT CONCAT(nombre, apellido, COALESCE(email, ''), COALESCE(telefono, ''), agente_id)) as duplicados
FROM prospectos;

-- 5. AGREGAR ÍNDICES ÚNICOS PARA PREVENIR FUTUROS DUPLICADOS
-- (Solo si no existen ya)
CREATE UNIQUE INDEX IF NOT EXISTS idx_prospectos_unique_with_email 
ON prospectos (nombre, apellido, email, telefono, agente_id) 
WHERE email IS NOT NULL AND email != '';

CREATE UNIQUE INDEX IF NOT EXISTS idx_prospectos_unique_no_email 
ON prospectos (nombre, apellido, telefono, agente_id) 
WHERE email IS NULL OR email = '';

-- 6. VERIFICAR QUE NO QUEDEN DUPLICADOS
SELECT 
  'VERIFICACIÓN FINAL' as estado,
  COUNT(*) as total_prospectos,
  COUNT(DISTINCT CONCAT(nombre, apellido, COALESCE(email, ''), COALESCE(telefono, ''), agente_id)) as prospectos_unicos,
  CASE 
    WHEN COUNT(*) = COUNT(DISTINCT CONCAT(nombre, apellido, COALESCE(email, ''), COALESCE(telefono, ''), agente_id)) 
    THEN '✅ NO HAY DUPLICADOS'
    ELSE '❌ AÚN HAY DUPLICADOS'
  END as resultado
FROM prospectos;
