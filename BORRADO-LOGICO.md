# Funcionalidad de Borrado Lógico de Prospectos

## Descripción

Se ha implementado un sistema de borrado lógico para los prospectos en lugar del borrado físico. Esto permite "eliminar" prospectos sin perder los datos históricos, manteniendo la integridad referencial con los seguimientos.

## Cambios Realizados

### 1. Base de Datos

- **Archivo**: `add-activo-column.sql`
- **Descripción**: Script para agregar la columna `activo` a la tabla `prospectos`
- **Ejecutar**: En el SQL Editor de Supabase

```sql
ALTER TABLE prospectos ADD COLUMN activo BOOLEAN DEFAULT true;
```

### 2. Componente ProspectoForm

- **Archivo**: `src/components/ProspectoForm.vue`
- **Cambios**:
  - Agregado botón "🗑️ Eliminar" que aparece solo al editar un prospecto
  - Función `deleteProspecto()` que marca el prospecto como inactivo
  - Confirmación antes de eliminar
  - Emite evento `deleted` al padre

### 3. Componente Dashboard

- **Archivo**: `src/components/Dashboard.vue`
- **Cambios**:
  - Filtra solo prospectos activos en `loadProspectos()`
  - Maneja el evento `deleted` del ProspectoForm
  - Actualiza automáticamente la lista después de eliminar

### 4. Queries Actualizadas

- Todas las consultas ahora filtran por `activo = true`
- Los seguimientos solo muestran prospectos activos
- La verificación de duplicados solo considera prospectos activos

## Cómo Usar

### Eliminar un Prospecto

1. Ve a la lista de prospectos
2. Haz clic en un prospecto para editarlo
3. En el formulario de edición, haz clic en el botón "🗑️ Eliminar"
4. Confirma la eliminación
5. El prospecto desaparecerá de la lista (pero los datos se mantienen)

### Restaurar un Prospecto

Si necesitas restaurar un prospecto eliminado:

1. Usa el script `restore-prospecto.sql`
2. Reemplaza `'PROSPECTO_ID_AQUI'` con el ID del prospecto
3. Ejecuta en el SQL Editor de Supabase

### Ver Prospectos Eliminados

Para ver qué prospectos han sido eliminados:

1. Usa el script `view-deleted-prospectos.sql`
2. Ejecuta en el SQL Editor de Supabase

## Archivos Creados

- `add-activo-column.sql` - Script para agregar la columna activo
- `restore-prospecto.sql` - Script para restaurar prospectos eliminados
- `view-deleted-prospectos.sql` - Script para ver prospectos eliminados
- `BORRADO-LOGICO.md` - Esta documentación

## Ventajas del Borrado Lógico

1. **Preservación de Datos**: Los datos históricos se mantienen
2. **Integridad Referencial**: Los seguimientos no se pierden
3. **Auditoría**: Se puede rastrear cuándo se eliminó cada prospecto
4. **Recuperación**: Los prospectos pueden restaurarse si es necesario
5. **Reportes**: Se pueden generar reportes que incluyan datos históricos

## Consideraciones Técnicas

- La columna `activo` tiene valor por defecto `true`
- Se crearon índices para optimizar las consultas
- Todos los prospectos existentes se marcan como activos automáticamente
- Las consultas de seguimientos usan `!inner` join para filtrar prospectos activos

## Próximos Pasos Recomendados

1. Ejecutar el script `add-activo-column.sql` en producción
2. Probar la funcionalidad de eliminación
3. Considerar implementar una interfaz para restaurar prospectos desde la UI
4. Agregar filtros para mostrar prospectos eliminados en la interfaz (opcional)
