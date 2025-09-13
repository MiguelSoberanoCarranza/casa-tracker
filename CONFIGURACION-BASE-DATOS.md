# 🗄️ Configuración de la Base de Datos

## ⚠️ Importante: Orden de Ejecución

Para evitar errores de dependencias, ejecuta los scripts SQL en este orden específico:

### 1. Si es la primera vez (Base de datos limpia)
Ejecuta directamente el archivo `supabase-schema.sql` en el SQL Editor de Supabase.

### 2. Si ya tienes datos y quieres empezar de nuevo
1. Primero ejecuta `reset-database.sql`
2. Luego ejecuta `supabase-schema.sql`

### 3. Si solo quieres agregar consultas útiles
Ejecuta `queries-utiles.sql` después de tener las tablas principales.

## 📋 Pasos Detallados

### Paso 1: Acceder a Supabase
1. Ve a [supabase.com](https://supabase.com)
2. Inicia sesión en tu cuenta
3. Selecciona tu proyecto o crea uno nuevo

### Paso 2: Abrir el SQL Editor
1. En el panel lateral, haz clic en "SQL Editor"
2. Haz clic en "New query"

### Paso 3: Ejecutar el Esquema Principal
1. Copia todo el contenido de `supabase-schema.sql`
2. Pégalo en el editor
3. Haz clic en "Run" o presiona Ctrl+Enter

### Paso 4: Verificar las Tablas
Después de ejecutar el script, deberías ver estas tablas en la sección "Table Editor":
- ✅ `agentes`
- ✅ `prospectos` 
- ✅ `seguimientos`

### Paso 5: Configurar Variables de Entorno
1. En tu proyecto local, copia `env.example` a `.env`
2. Ve a Supabase > Settings > API
3. Copia la "Project URL" y "anon public" key
4. Pégalas en tu archivo `.env`:

```env
PUBLIC_SUPABASE_URL=tu_url_aqui
PUBLIC_SUPABASE_ANON_KEY=tu_clave_aqui
```

## 🔍 Verificación

### Verificar que las relaciones funcionan:
```sql
-- Esta consulta debería funcionar sin errores
SELECT 
  p.nombre,
  p.apellido,
  a.nombre as agente
FROM prospectos p
LEFT JOIN agentes a ON p.agente_id = a.id
LIMIT 5;
```

### Verificar que el agente de ejemplo existe:
```sql
-- Debería mostrar 1 fila con el agente de ejemplo
SELECT * FROM agentes;
```

## 🚨 Solución de Problemas

### Error: "relation 'agentes' does not exist"
- **Causa**: Las tablas se crearon en orden incorrecto
- **Solución**: Ejecuta `reset-database.sql` y luego `supabase-schema.sql`

### Error: "duplicate key value violates unique constraint"
- **Causa**: Ya existe un agente con el mismo email
- **Solución**: Elimina el agente duplicado o cambia el email en el script

### Error: "permission denied for table"
- **Causa**: Las políticas RLS están bloqueando el acceso
- **Solución**: Verifica que las políticas estén configuradas correctamente

## 📊 Datos de Prueba

Después de configurar la base de datos, puedes agregar datos de prueba:

```sql
-- Agregar más agentes
INSERT INTO agentes (nombre, email, telefono) VALUES 
('María González', 'maria@ejemplo.com', '+52 555 123 4567'),
('Carlos López', 'carlos@ejemplo.com', '+52 555 987 6543');

-- Agregar un prospecto de ejemplo
INSERT INTO prospectos (
  nombre, apellido, email, telefono, ciudad, 
  presupuesto_max, tipo_propiedad, status, agente_id
) VALUES (
  'Juan', 'Pérez', 'juan@email.com', '+52 555 111 2222', 'Ciudad de México',
  1500000, 'casa', 'nuevo', (SELECT id FROM agentes LIMIT 1)
);
```

## ✅ Lista de Verificación

- [ ] Tabla `agentes` creada correctamente
- [ ] Tabla `prospectos` creada con relación a `agentes`
- [ ] Tabla `seguimientos` creada con relaciones a `prospectos` y `agentes`
- [ ] Índices creados para optimizar consultas
- [ ] Políticas RLS configuradas
- [ ] Agente de ejemplo insertado
- [ ] Variables de entorno configuradas en `.env`
- [ ] Aplicación se conecta correctamente a Supabase

¡Una vez completados todos estos pasos, tu aplicación Casa Tracker estará lista para usar! 🏠✨
