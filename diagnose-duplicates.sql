-- Script de diagnóstico para analizar la causa de los duplicados
-- Ejecutar este script en el SQL Editor de Supabase

-- 1. ANÁLISIS DETALLADO DE DUPLICADOS
-- Ver duplicados con información de timestamps y diferencias
WITH duplicados_detalle AS (
  SELECT 
    nombre, 
    apellido, 
    email, 
    telefono,
    agente_id,
    COUNT(*) as total_duplicados,
    MIN(fecha_creacion) as primera_creacion,
    MAX(fecha_creacion) as ultima_creacion,
    MIN(created_at) as primer_created_at,
    MAX(created_at) as ultimo_created_at,
    MIN(fecha_actualizacion) as primera_actualizacion,
    MAX(fecha_actualizacion) as ultima_actualizacion,
    -- Calcular diferencia en segundos entre creaciones
    EXTRACT(EPOCH FROM (MAX(fecha_creacion) - MIN(fecha_creacion))) as diferencia_segundos,
    -- Ver si hay diferencias en otros campos
    COUNT(DISTINCT status) as status_diferentes,
    COUNT(DISTINCT presupuesto_max) as presupuesto_diferentes,
    COUNT(DISTINCT puntuacion_interes) as puntuacion_diferentes
  FROM prospectos 
  GROUP BY nombre, apellido, email, telefono, agente_id
  HAVING COUNT(*) > 1
)
SELECT 
  nombre,
  apellido,
  email,
  telefono,
  total_duplicados,
  primera_creacion,
  ultima_creacion,
  diferencia_segundos,
  CASE 
    WHEN diferencia_segundos < 5 THEN 'POSIBLE DUPLICACIÓN AUTOMÁTICA (menos de 5 segundos)'
    WHEN diferencia_segundos < 60 THEN 'POSIBLE DUPLICACIÓN RÁPIDA (menos de 1 minuto)'
    WHEN diferencia_segundos < 3600 THEN 'POSIBLE DUPLICACIÓN MANUAL (menos de 1 hora)'
    ELSE 'DUPLICACIÓN MANUAL (más de 1 hora)'
  END as tipo_duplicacion,
  status_diferentes,
  presupuesto_diferentes,
  puntuacion_diferentes
FROM duplicados_detalle
ORDER BY diferencia_segundos ASC, total_duplicados DESC;

-- 2. VER TODOS LOS REGISTROS DUPLICADOS CON DETALLES
-- (Reemplaza 'NOMBRE_DUPLICADO' con un nombre real de los duplicados encontrados)
/*
SELECT 
  id,
  nombre,
  apellido,
  email,
  telefono,
  status,
  presupuesto_max,
  puntuacion_interes,
  fecha_creacion,
  created_at,
  fecha_actualizacion,
  updated_at,
  agente_id
FROM prospectos 
WHERE (nombre, apellido, email, telefono, agente_id) IN (
  SELECT nombre, apellido, email, telefono, agente_id
  FROM prospectos 
  GROUP BY nombre, apellido, email, telefono, agente_id
  HAVING COUNT(*) > 1
)
ORDER BY nombre, apellido, fecha_creacion;
*/

-- 3. ANÁLISIS POR USUARIO/AGENTE
-- Ver cuántos duplicados tiene cada agente
SELECT 
  agente_id,
  COUNT(*) as total_prospectos,
  COUNT(DISTINCT CONCAT(nombre, apellido, COALESCE(email, ''), COALESCE(telefono, ''))) as prospectos_unicos,
  COUNT(*) - COUNT(DISTINCT CONCAT(nombre, apellido, COALESCE(email, ''), COALESCE(telefono, ''))) as duplicados_totales
FROM prospectos
GROUP BY agente_id
ORDER BY duplicados_totales DESC;

-- 4. ANÁLISIS TEMPORAL
-- Ver si hay patrones de duplicación en ciertos momentos
SELECT 
  DATE_TRUNC('hour', fecha_creacion) as hora_creacion,
  COUNT(*) as total_creados,
  COUNT(DISTINCT CONCAT(nombre, apellido, COALESCE(email, ''), COALESCE(telefono, ''))) as unicos_creados,
  COUNT(*) - COUNT(DISTINCT CONCAT(nombre, apellido, COALESCE(email, ''), COALESCE(telefono, ''))) as duplicados_en_hora
FROM prospectos
GROUP BY DATE_TRUNC('hour', fecha_creacion)
HAVING COUNT(*) > 1
ORDER BY duplicados_en_hora DESC, hora_creacion;

-- 5. VERIFICAR SI HAY TRIGGERS O FUNCIONES QUE PUEDAN CAUSAR DUPLICADOS
-- Ver triggers en la tabla prospectos
SELECT 
  trigger_name,
  event_manipulation,
  action_timing,
  action_statement
FROM information_schema.triggers 
WHERE event_object_table = 'prospectos';

-- 6. ANÁLISIS DE CAMPOS VACÍOS O NULOS
-- Ver si los duplicados tienen campos vacíos que puedan causar problemas
SELECT 
  'email_nulos' as campo,
  COUNT(*) as total,
  COUNT(*) FILTER (WHERE email IS NULL OR email = '') as nulos_vacios
FROM prospectos
UNION ALL
SELECT 
  'telefono_nulos' as campo,
  COUNT(*) as total,
  COUNT(*) FILTER (WHERE telefono IS NULL OR telefono = '') as nulos_vacios
FROM prospectos;
