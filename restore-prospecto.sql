-- Script para restaurar un prospecto eliminado lógicamente
-- Ejecutar este script en el SQL Editor de Supabase

-- Función para restaurar un prospecto por ID
-- Reemplaza 'PROSPECTO_ID_AQUI' con el UUID del prospecto que quieres restaurar
UPDATE prospectos 
SET activo = true, 
    fecha_actualizacion = NOW()
WHERE id = 'PROSPECTO_ID_AQUI' AND activo = false;

-- Verificar que el prospecto fue restaurado
SELECT id, nombre, apellido, activo, fecha_actualizacion 
FROM prospectos 
WHERE id = 'PROSPECTO_ID_AQUI';

-- Consulta para ver todos los prospectos eliminados (para encontrar el ID)
-- SELECT id, nombre, apellido, email, activo, fecha_actualizacion 
-- FROM prospectos 
-- WHERE activo = false 
-- ORDER BY fecha_actualizacion DESC;

-- Función para restaurar todos los prospectos eliminados (usar con precaución)
-- UPDATE prospectos 
-- SET activo = true, 
--     fecha_actualizacion = NOW()
-- WHERE activo = false;
