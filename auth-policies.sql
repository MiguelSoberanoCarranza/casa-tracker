-- Políticas de autenticación para Casa Tracker
-- Ejecutar este script en el SQL Editor de Supabase después de configurar la autenticación

-- Eliminar políticas existentes
DROP POLICY IF EXISTS "Enable all operations for all users" ON prospectos;
DROP POLICY IF EXISTS "Enable all operations for all users" ON seguimientos;
DROP POLICY IF EXISTS "Enable all operations for all users" ON agentes;

-- Políticas para la tabla prospectos
-- Los usuarios solo pueden ver/editar prospectos de su agente
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

-- Política para permitir que los usuarios inserten su propio perfil de agente
CREATE POLICY "Users can insert their own agente profile" ON agentes
  FOR INSERT WITH CHECK (
    id = auth.uid() AND email = auth.jwt() ->> 'email'
  );

-- Actualizar el agente existente para que tenga el ID correcto
-- (Esto es solo para el agente de ejemplo que ya existe)
UPDATE agentes 
SET id = (SELECT id FROM auth.users WHERE email = 'agente@example.com' LIMIT 1)
WHERE email = 'agente@example.com' AND id != (SELECT id FROM auth.users WHERE email = 'agente@example.com' LIMIT 1);
