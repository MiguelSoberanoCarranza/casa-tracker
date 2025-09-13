-- Políticas de seguridad RLS (Row Level Security) para Casa Tracker
-- Ejecutar este script en el SQL Editor de Supabase

-- Eliminar políticas existentes si existen
DROP POLICY IF EXISTS "Enable all operations for all users" ON prospectos;
DROP POLICY IF EXISTS "Enable all operations for all users" ON seguimientos;
DROP POLICY IF EXISTS "Enable all operations for all users" ON agentes;

-- Políticas para la tabla de prospectos
-- Los usuarios solo pueden ver, insertar, actualizar y eliminar sus propios prospectos
CREATE POLICY "Users can view own prospects" ON prospectos
  FOR SELECT USING (agente_id = auth.uid());

CREATE POLICY "Users can insert own prospects" ON prospectos
  FOR INSERT WITH CHECK (agente_id = auth.uid());

CREATE POLICY "Users can update own prospects" ON prospectos
  FOR UPDATE USING (agente_id = auth.uid());

CREATE POLICY "Users can delete own prospects" ON prospectos
  FOR DELETE USING (agente_id = auth.uid());

-- Políticas para la tabla de seguimientos
-- Los usuarios solo pueden ver, insertar, actualizar y eliminar seguimientos de sus propios prospectos
CREATE POLICY "Users can view own follow-ups" ON seguimientos
  FOR SELECT USING (
    agente_id = auth.uid() OR 
    prospecto_id IN (
      SELECT id FROM prospectos WHERE agente_id = auth.uid()
    )
  );

CREATE POLICY "Users can insert own follow-ups" ON seguimientos
  FOR INSERT WITH CHECK (
    agente_id = auth.uid() AND
    prospecto_id IN (
      SELECT id FROM prospectos WHERE agente_id = auth.uid()
    )
  );

CREATE POLICY "Users can update own follow-ups" ON seguimientos
  FOR UPDATE USING (
    agente_id = auth.uid() AND
    prospecto_id IN (
      SELECT id FROM prospectos WHERE agente_id = auth.uid()
    )
  );

CREATE POLICY "Users can delete own follow-ups" ON seguimientos
  FOR DELETE USING (
    agente_id = auth.uid() AND
    prospecto_id IN (
      SELECT id FROM prospectos WHERE agente_id = auth.uid()
    )
  );

-- Políticas para la tabla de agentes
-- Los usuarios solo pueden ver y actualizar su propio perfil de agente
CREATE POLICY "Users can view own agent profile" ON agentes
  FOR SELECT USING (id = auth.uid());

CREATE POLICY "Users can insert own agent profile" ON agentes
  FOR INSERT WITH CHECK (id = auth.uid());

CREATE POLICY "Users can update own agent profile" ON agentes
  FOR UPDATE USING (id = auth.uid());

-- Función para crear automáticamente un registro de agente cuando se registra un usuario
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO agentes (id, nombre, email, activo)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.email),
    NEW.email,
    true
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger para crear agente automáticamente
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();