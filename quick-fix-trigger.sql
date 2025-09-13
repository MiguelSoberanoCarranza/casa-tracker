-- Solución rápida para el error del trigger
-- Ejecutar este script en el SQL Editor de Supabase

-- Eliminar el trigger existente
DROP TRIGGER IF EXISTS update_prospectos_updated_at ON prospectos;

-- Eliminar la función existente
DROP FUNCTION IF EXISTS update_updated_at_column();

-- Crear la función actualizada
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    NEW.fecha_actualizacion = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Crear el trigger nuevamente
CREATE TRIGGER update_prospectos_updated_at 
    BEFORE UPDATE ON prospectos 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- Mensaje de confirmación
SELECT 'Trigger actualizado correctamente' as mensaje;
