-- Esquema de base de datos para Casa Tracker
-- Ejecutar este script en el SQL Editor de Supabase

-- Tabla de agentes (debe crearse primero porque es referenciada por otras tablas)
-- El ID debe coincidir con auth.users.id para la autenticación
CREATE TABLE agentes (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  nombre VARCHAR(100) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  telefono VARCHAR(20),
  activo BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla de prospectos
CREATE TABLE prospectos (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL,
  apellido VARCHAR(100) NOT NULL,
  email VARCHAR(255),
  telefono VARCHAR(20),
  direccion TEXT,
  ciudad VARCHAR(100),
  estado VARCHAR(100),
  codigo_postal VARCHAR(10),
  presupuesto_max DECIMAL(12,2),
  tipo_propiedad VARCHAR(50),
  habitaciones INTEGER,
  banos INTEGER,
  metros_cuadrados INTEGER,
  notas TEXT,
  status VARCHAR(20) DEFAULT 'nuevo',
  puntuacion_interes INTEGER DEFAULT 1 CHECK (puntuacion_interes >= 1 AND puntuacion_interes <= 4),
  fecha_creacion TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  fecha_actualizacion TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  agente_id UUID REFERENCES agentes(id) ON DELETE SET NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla de seguimientos
CREATE TABLE seguimientos (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  prospecto_id UUID REFERENCES prospectos(id) ON DELETE CASCADE,
  agente_id UUID REFERENCES agentes(id) ON DELETE SET NULL,
  tipo_seguimiento VARCHAR(50) NOT NULL, -- 'llamada', 'email', 'visita', 'mensaje'
  descripcion TEXT NOT NULL,
  resultado VARCHAR(100), -- 'positivo', 'negativo', 'neutral', 'pendiente'
  proxima_accion TEXT,
  proxima_accion_fecha TIMESTAMP WITH TIME ZONE, -- Fecha programada para la próxima acción
  proxima_accion_tipo VARCHAR(50), -- Tipo de próxima acción programada
  fecha_seguimiento TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices para mejorar el rendimiento
CREATE INDEX idx_prospectos_status ON prospectos(status);
CREATE INDEX idx_prospectos_agente ON prospectos(agente_id);
CREATE INDEX idx_prospectos_fecha_actualizacion ON prospectos(fecha_actualizacion);
CREATE INDEX idx_seguimientos_prospecto ON seguimientos(prospecto_id);
CREATE INDEX idx_seguimientos_agente ON seguimientos(agente_id);
CREATE INDEX idx_seguimientos_fecha ON seguimientos(fecha_seguimiento);
CREATE INDEX idx_seguimientos_tipo ON seguimientos(tipo_seguimiento);
CREATE INDEX idx_seguimientos_proxima_accion_fecha ON seguimientos(proxima_accion_fecha) WHERE proxima_accion_fecha IS NOT NULL;

-- Función para actualizar fecha_actualizacion automáticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Trigger para prospectos
CREATE TRIGGER update_prospectos_updated_at 
    BEFORE UPDATE ON prospectos 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- Políticas de seguridad RLS (Row Level Security)
ALTER TABLE prospectos ENABLE ROW LEVEL SECURITY;
ALTER TABLE seguimientos ENABLE ROW LEVEL SECURITY;
ALTER TABLE agentes ENABLE ROW LEVEL SECURITY;

-- Política básica (ajustar según necesidades de autenticación)
CREATE POLICY "Enable all operations for all users" ON prospectos FOR ALL USING (true);
CREATE POLICY "Enable all operations for all users" ON seguimientos FOR ALL USING (true);
CREATE POLICY "Enable all operations for all users" ON agentes FOR ALL USING (true);

-- Nota: El agente se creará automáticamente cuando se registre un usuario
-- gracias al trigger handle_new_user()
