-- Script para arreglar la base de datos existente
-- Ejecutar este script en el SQL Editor de Supabase

-- Eliminar triggers existentes si existen
DROP TRIGGER IF EXISTS update_prospectos_updated_at ON prospectos;

-- Eliminar función si existe
DROP FUNCTION IF EXISTS update_updated_at_column();

-- Eliminar políticas existentes
DROP POLICY IF EXISTS "Enable all operations for all users" ON prospectos;
DROP POLICY IF EXISTS "Enable all operations for all users" ON seguimientos;
DROP POLICY IF EXISTS "Enable all operations for all users" ON agentes;

-- Crear la función actualizada
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    NEW.fecha_actualizacion = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Crear trigger para prospectos
CREATE TRIGGER update_prospectos_updated_at 
    BEFORE UPDATE ON prospectos 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- Actualizar la tabla agentes para que el ID coincida con auth.users
-- Primero, eliminar la tabla agentes si existe
DROP TABLE IF EXISTS agentes CASCADE;

-- Crear la tabla agentes con la estructura correcta
CREATE TABLE agentes (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  nombre VARCHAR(100) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  telefono VARCHAR(20),
  activo BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Recrear la tabla prospectos con las referencias correctas
DROP TABLE IF EXISTS seguimientos CASCADE;
DROP TABLE IF EXISTS prospectos CASCADE;

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

-- Recrear el trigger
DROP TRIGGER IF EXISTS update_prospectos_updated_at ON prospectos;
CREATE TRIGGER update_prospectos_updated_at 
    BEFORE UPDATE ON prospectos 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- Crear índices
CREATE INDEX idx_prospectos_status ON prospectos(status);
CREATE INDEX idx_prospectos_agente ON prospectos(agente_id);
CREATE INDEX idx_prospectos_fecha_actualizacion ON prospectos(fecha_actualizacion);
CREATE INDEX idx_seguimientos_prospecto ON seguimientos(prospecto_id);
CREATE INDEX idx_seguimientos_agente ON seguimientos(agente_id);
CREATE INDEX idx_seguimientos_fecha ON seguimientos(fecha_seguimiento);
CREATE INDEX idx_seguimientos_tipo ON seguimientos(tipo_seguimiento);
CREATE INDEX idx_seguimientos_proxima_accion_fecha ON seguimientos(proxima_accion_fecha) WHERE proxima_accion_fecha IS NOT NULL;

-- Habilitar RLS
ALTER TABLE prospectos ENABLE ROW LEVEL SECURITY;
ALTER TABLE seguimientos ENABLE ROW LEVEL SECURITY;
ALTER TABLE agentes ENABLE ROW LEVEL SECURITY;

-- Políticas para la tabla prospectos
CREATE POLICY "Users can view their own prospectos" ON prospectos
  FOR SELECT USING (
    auth.uid() IN (
      SELECT id FROM agentes WHERE email = auth.jwt() ->> 'email'
    )
  );

CREATE POLICY "Users can insert prospectos for their agente" ON prospectos
  FOR INSERT WITH CHECK (
    auth.uid() IN (
      SELECT id FROM agentes WHERE email = auth.jwt() ->> 'email'
    )
  );

CREATE POLICY "Users can update their own prospectos" ON prospectos
  FOR UPDATE USING (
    auth.uid() IN (
      SELECT id FROM agentes WHERE email = auth.jwt() ->> 'email'
    )
  );

CREATE POLICY "Users can delete their own prospectos" ON prospectos
  FOR DELETE USING (
    auth.uid() IN (
      SELECT id FROM agentes WHERE email = auth.jwt() ->> 'email'
    )
  );

-- Políticas para la tabla seguimientos
CREATE POLICY "Users can view seguimientos for their prospectos" ON seguimientos
  FOR SELECT USING (
    prospecto_id IN (
      SELECT id FROM prospectos WHERE agente_id IN (
        SELECT id FROM agentes WHERE email = auth.jwt() ->> 'email'
      )
    )
  );

CREATE POLICY "Users can insert seguimientos for their prospectos" ON seguimientos
  FOR INSERT WITH CHECK (
    prospecto_id IN (
      SELECT id FROM prospectos WHERE agente_id IN (
        SELECT id FROM agentes WHERE email = auth.jwt() ->> 'email'
      )
    )
  );

CREATE POLICY "Users can update seguimientos for their prospectos" ON seguimientos
  FOR UPDATE USING (
    prospecto_id IN (
      SELECT id FROM prospectos WHERE agente_id IN (
        SELECT id FROM agentes WHERE email = auth.jwt() ->> 'email'
      )
    )
  );

CREATE POLICY "Users can delete seguimientos for their prospectos" ON seguimientos
  FOR DELETE USING (
    prospecto_id IN (
      SELECT id FROM prospectos WHERE agente_id IN (
        SELECT id FROM agentes WHERE email = auth.jwt() ->> 'email'
      )
    )
  );

-- Políticas para la tabla agentes
CREATE POLICY "Users can view their own agente profile" ON agentes
  FOR SELECT USING (
    email = auth.jwt() ->> 'email'
  );

CREATE POLICY "Users can update their own agente profile" ON agentes
  FOR UPDATE USING (
    email = auth.jwt() ->> 'email'
  );

CREATE POLICY "Users can insert their own agente profile" ON agentes
  FOR INSERT WITH CHECK (
    id = auth.uid() AND email = auth.jwt() ->> 'email'
  );

-- Función para crear automáticamente un perfil de agente cuando se registra un usuario
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.agentes (id, nombre, email, activo)
  VALUES (
    new.id,
    COALESCE(new.raw_user_meta_data->>'nombre', split_part(new.email, '@', 1)),
    new.email,
    true
  );
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger para crear perfil de agente automáticamente
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

-- Mensaje de confirmación
SELECT 'Base de datos actualizada correctamente' as mensaje;
