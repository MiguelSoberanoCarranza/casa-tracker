-- Script para ver prospectos eliminados lógicamente
-- Ejecutar este script en el SQL Editor de Supabase

-- Ver todos los prospectos eliminados
SELECT 
    p.id,
    p.nombre,
    p.apellido,
    p.email,
    p.telefono,
    p.status,
    p.fecha_actualizacion as fecha_eliminacion,
    a.nombre as agente_nombre
FROM prospectos p
LEFT JOIN agentes a ON p.agente_id = a.id
WHERE p.activo = false
ORDER BY p.fecha_actualizacion DESC;

-- Contar prospectos eliminados por agente
SELECT 
    a.nombre as agente_nombre,
    COUNT(p.id) as prospectos_eliminados
FROM agentes a
LEFT JOIN prospectos p ON a.id = p.agente_id AND p.activo = false
GROUP BY a.id, a.nombre
HAVING COUNT(p.id) > 0
ORDER BY prospectos_eliminados DESC;

-- Ver prospectos eliminados en los últimos 30 días
SELECT 
    p.id,
    p.nombre,
    p.apellido,
    p.email,
    p.fecha_actualizacion as fecha_eliminacion,
    a.nombre as agente_nombre
FROM prospectos p
LEFT JOIN agentes a ON p.agente_id = a.id
WHERE p.activo = false 
    AND p.fecha_actualizacion >= NOW() - INTERVAL '30 days'
ORDER BY p.fecha_actualizacion DESC;
