-- Script de ALTER para agregar funcionalidad de recordatorios
-- Ejecutar este script en el SQL Editor de Supabase después de tener la BD creada

-- Agregar columnas para próximas acciones programadas
ALTER TABLE seguimientos 
ADD COLUMN proxima_accion_fecha TIMESTAMP WITH TIME ZONE,
ADD COLUMN proxima_accion_tipo VARCHAR(50);

-- Agregar comentarios para documentar las nuevas columnas
COMMENT ON COLUMN seguimientos.proxima_accion_fecha IS 'Fecha programada para la próxima acción de seguimiento';
COMMENT ON COLUMN seguimientos.proxima_accion_tipo IS 'Tipo de próxima acción programada (llamada, email, visita, etc.)';

-- Crear índice para optimizar consultas de recordatorios
CREATE INDEX idx_seguimientos_proxima_accion_fecha 
ON seguimientos(proxima_accion_fecha) 
WHERE proxima_accion_fecha IS NOT NULL;

-- Crear función para obtener recordatorios del día
CREATE OR REPLACE FUNCTION obtener_recordatorios_hoy()
RETURNS TABLE (
  seguimiento_id UUID,
  prospecto_nombre VARCHAR,
  prospecto_apellido VARCHAR,
  proxima_accion TEXT,
  proxima_accion_tipo VARCHAR,
  proxima_accion_fecha TIMESTAMP WITH TIME ZONE,
  agente_nombre VARCHAR
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    s.id,
    p.nombre,
    p.apellido,
    s.proxima_accion,
    s.proxima_accion_tipo,
    s.proxima_accion_fecha,
    a.nombre
  FROM seguimientos s
  JOIN prospectos p ON s.prospecto_id = p.id
  LEFT JOIN agentes a ON s.agente_id = a.id
  WHERE s.proxima_accion_fecha IS NOT NULL
    AND DATE(s.proxima_accion_fecha) = CURRENT_DATE
    AND s.proxima_accion_fecha > NOW()
  ORDER BY s.proxima_accion_fecha ASC;
END;
$$ LANGUAGE plpgsql;

-- Crear función para obtener recordatorios pendientes (próximos 7 días)
CREATE OR REPLACE FUNCTION obtener_recordatorios_proximos()
RETURNS TABLE (
  seguimiento_id UUID,
  prospecto_nombre VARCHAR,
  prospecto_apellido VARCHAR,
  proxima_accion TEXT,
  proxima_accion_tipo VARCHAR,
  proxima_accion_fecha TIMESTAMP WITH TIME ZONE,
  dias_restantes INTEGER,
  agente_nombre VARCHAR
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    s.id,
    p.nombre,
    p.apellido,
    s.proxima_accion,
    s.proxima_accion_tipo,
    s.proxima_accion_fecha,
    EXTRACT(DAY FROM (s.proxima_accion_fecha - NOW()))::INTEGER as dias_restantes,
    a.nombre
  FROM seguimientos s
  JOIN prospectos p ON s.prospecto_id = p.id
  LEFT JOIN agentes a ON s.agente_id = a.id
  WHERE s.proxima_accion_fecha IS NOT NULL
    AND s.proxima_accion_fecha > NOW()
    AND s.proxima_accion_fecha <= NOW() + INTERVAL '7 days'
  ORDER BY s.proxima_accion_fecha ASC;
END;
$$ LANGUAGE plpgsql;

-- Crear función para marcar recordatorio como completado
CREATE OR REPLACE FUNCTION completar_recordatorio(seguimiento_uuid UUID)
RETURNS BOOLEAN AS $$
BEGIN
  UPDATE seguimientos 
  SET proxima_accion_fecha = NULL,
      proxima_accion_tipo = NULL,
      fecha_actualizacion = NOW()
  WHERE id = seguimiento_uuid;
  
  RETURN FOUND;
END;
$$ LANGUAGE plpgsql;

-- Crear vista para dashboard con recordatorios
CREATE OR REPLACE VIEW vista_recordatorios AS
SELECT 
  s.id as seguimiento_id,
  p.nombre || ' ' || p.apellido as prospecto_nombre,
  p.email as prospecto_email,
  p.telefono as prospecto_telefono,
  s.proxima_accion,
  s.proxima_accion_tipo,
  s.proxima_accion_fecha,
  CASE 
    WHEN s.proxima_accion_fecha IS NULL THEN 'Sin recordatorio'
    WHEN s.proxima_accion_fecha < NOW() THEN 'Vencido'
    WHEN DATE(s.proxima_accion_fecha) = CURRENT_DATE THEN 'Hoy'
    WHEN s.proxima_accion_fecha <= NOW() + INTERVAL '3 days' THEN 'Próximos 3 días'
    ELSE 'Programado'
  END as estado_recordatorio,
  a.nombre as agente_nombre
FROM seguimientos s
JOIN prospectos p ON s.prospecto_id = p.id
LEFT JOIN agentes a ON s.agente_id = a.id
WHERE s.proxima_accion_fecha IS NOT NULL
ORDER BY s.proxima_accion_fecha ASC;

-- Insertar algunos datos de ejemplo (opcional)
-- Descomenta las siguientes líneas si quieres datos de prueba

/*
-- Ejemplo de seguimiento con recordatorio
INSERT INTO seguimientos (
  prospecto_id, 
  agente_id, 
  tipo_seguimiento, 
  descripcion, 
  resultado, 
  proxima_accion, 
  proxima_accion_fecha, 
  proxima_accion_tipo
) VALUES (
  (SELECT id FROM prospectos LIMIT 1),
  (SELECT id FROM agentes LIMIT 1),
  'llamada',
  'Cliente interesado en casa de 3 habitaciones',
  'positivo',
  'Llamar para agendar visita',
  NOW() + INTERVAL '2 days',
  'llamada'
);
*/

-- Verificar que las columnas se agregaron correctamente
SELECT 
  column_name, 
  data_type, 
  is_nullable
FROM information_schema.columns 
WHERE table_name = 'seguimientos' 
  AND column_name IN ('proxima_accion_fecha', 'proxima_accion_tipo')
ORDER BY column_name;
