-- Consultas útiles para Casa Tracker
-- Ejecutar estas consultas en el SQL Editor de Supabase

-- 1. Ver todos los prospectos con su agente asignado
SELECT 
  p.nombre,
  p.apellido,
  p.email,
  p.status,
  p.puntuacion_interes,
  a.nombre as agente_nombre,
  p.fecha_actualizacion
FROM prospectos p
LEFT JOIN agentes a ON p.agente_id = a.id
ORDER BY p.fecha_actualizacion DESC;

-- 2. Contar prospectos por agente
SELECT 
  a.nombre as agente,
  COUNT(p.id) as total_prospectos,
  COUNT(CASE WHEN p.status = 'vendido' THEN 1 END) as vendidos,
  COUNT(CASE WHEN p.puntuacion_interes >= 3 THEN 1 END) as calificados
FROM agentes a
LEFT JOIN prospectos p ON a.id = p.agente_id
GROUP BY a.id, a.nombre
ORDER BY total_prospectos DESC;

-- 3. Ver seguimientos recientes con información del agente
SELECT 
  s.tipo_seguimiento,
  s.descripcion,
  s.resultado,
  s.fecha_seguimiento,
  a.nombre as agente,
  p.nombre || ' ' || p.apellido as prospecto
FROM seguimientos s
JOIN agentes a ON s.agente_id = a.id
JOIN prospectos p ON s.prospecto_id = p.id
ORDER BY s.fecha_seguimiento DESC
LIMIT 20;

-- 4. Prospectos que necesitan seguimiento (sin actividad en los últimos 7 días)
SELECT 
  p.nombre,
  p.apellido,
  p.email,
  p.telefono,
  p.status,
  p.fecha_actualizacion,
  a.nombre as agente
FROM prospectos p
LEFT JOIN agentes a ON p.agente_id = a.id
WHERE p.status NOT IN ('vendido', 'perdido')
  AND p.fecha_actualizacion < NOW() - INTERVAL '7 days'
ORDER BY p.fecha_actualizacion ASC;

-- 5. Estadísticas por mes
SELECT 
  DATE_TRUNC('month', fecha_creacion) as mes,
  COUNT(*) as nuevos_prospectos,
  COUNT(CASE WHEN status = 'vendido' THEN 1 END) as vendidos,
  COUNT(CASE WHEN status = 'perdido' THEN 1 END) as perdidos,
  ROUND(
    COUNT(CASE WHEN status = 'vendido' THEN 1 END) * 100.0 / COUNT(*), 
    2
  ) as tasa_conversion
FROM prospectos
GROUP BY DATE_TRUNC('month', fecha_creacion)
ORDER BY mes DESC;

-- 6. Top agentes por ventas
SELECT 
  a.nombre as agente,
  COUNT(CASE WHEN p.status = 'vendido' THEN 1 END) as ventas,
  SUM(p.presupuesto_max) as valor_total_vendido,
  AVG(p.presupuesto_max) as promedio_venta
FROM agentes a
LEFT JOIN prospectos p ON a.id = p.agente_id
WHERE p.status = 'vendido'
GROUP BY a.id, a.nombre
ORDER BY ventas DESC;

-- 7. Prospectos por tipo de propiedad
SELECT 
  tipo_propiedad,
  COUNT(*) as cantidad,
  AVG(presupuesto_max) as presupuesto_promedio,
  COUNT(CASE WHEN status = 'vendido' THEN 1 END) as vendidos
FROM prospectos
WHERE tipo_propiedad IS NOT NULL
GROUP BY tipo_propiedad
ORDER BY cantidad DESC;

-- 8. Seguimientos por tipo y resultado
SELECT 
  tipo_seguimiento,
  resultado,
  COUNT(*) as cantidad,
  ROUND(AVG(EXTRACT(EPOCH FROM (fecha_seguimiento - fecha_creacion))/86400), 1) as dias_promedio
FROM seguimientos s
JOIN prospectos p ON s.prospecto_id = p.id
GROUP BY tipo_seguimiento, resultado
ORDER BY tipo_seguimiento, cantidad DESC;

-- 9. Crear vista para dashboard
CREATE OR REPLACE VIEW vista_dashboard AS
SELECT 
  (SELECT COUNT(*) FROM prospectos) as total_prospectos,
  (SELECT COUNT(*) FROM prospectos WHERE status = 'vendido') as vendidos,
  (SELECT COUNT(*) FROM prospectos WHERE puntuacion_interes >= 3) as calificados,
  (SELECT COUNT(*) FROM seguimientos WHERE fecha_seguimiento::date = CURRENT_DATE) as seguimientos_hoy,
  (SELECT COALESCE(SUM(presupuesto_max), 0) FROM prospectos WHERE presupuesto_max IS NOT NULL) as valor_total;

-- 10. Función para obtener estadísticas de un agente específico
CREATE OR REPLACE FUNCTION estadisticas_agente(agente_uuid UUID)
RETURNS TABLE (
  total_prospectos BIGINT,
  prospectos_activos BIGINT,
  vendidos BIGINT,
  perdidos BIGINT,
  calificados BIGINT,
  valor_total NUMERIC
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    COUNT(p.id) as total_prospectos,
    COUNT(CASE WHEN p.status NOT IN ('vendido', 'perdido') THEN 1 END) as prospectos_activos,
    COUNT(CASE WHEN p.status = 'vendido' THEN 1 END) as vendidos,
    COUNT(CASE WHEN p.status = 'perdido' THEN 1 END) as perdidos,
    COUNT(CASE WHEN p.puntuacion_interes >= 3 THEN 1 END) as calificados,
    COALESCE(SUM(p.presupuesto_max), 0) as valor_total
  FROM prospectos p
  WHERE p.agente_id = agente_uuid;
END;
$$ LANGUAGE plpgsql;

-- Ejemplo de uso de la función:
-- SELECT * FROM estadisticas_agente('tu-uuid-del-agente-aqui');
