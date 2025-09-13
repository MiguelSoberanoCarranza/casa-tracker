# Configuración de Redirección de Email

## Problema
Al confirmar el correo electrónico, los usuarios son redirigidos a localhost en lugar de la URL de producción.

## Solución

### 1. Configuración en Supabase Dashboard

Ve a tu proyecto de Supabase y configura las siguientes URLs:

#### Authentication > Settings > URL Configuration

**Site URL:**
- Desarrollo: `http://localhost:4321`
- Producción: `https://tu-dominio.com`

**Redirect URLs:**
- Desarrollo: `http://localhost:4321/auth-redirect`
- Producción: `https://tu-dominio.com/auth-redirect`

### 2. Configuración de Variables de Entorno

Asegúrate de que tu archivo `.env` tenga las URLs correctas:

```env
# Para desarrollo
PUBLIC_SUPABASE_URL=tu_url_de_supabase
PUBLIC_SUPABASE_ANON_KEY=tu_clave_anonima

# Para producción
PUBLIC_SUPABASE_URL=tu_url_de_supabase
PUBLIC_SUPABASE_ANON_KEY=tu_clave_anonima
```

### 3. Verificación de la Configuración

1. **En desarrollo**: Las redirecciones van a `localhost:4321`
2. **En producción**: Las redirecciones van a tu dominio real

### 4. Código Actualizado

El archivo `src/lib/auth.js` ya está configurado para usar `window.location.origin` que automáticamente detecta si estás en desarrollo o producción.

### 5. Pasos para Aplicar la Corrección

1. Ve a Supabase Dashboard
2. Navega a Authentication > Settings
3. Actualiza la **Site URL** con tu dominio de producción
4. Agrega tu dominio de producción a **Redirect URLs**
5. Guarda los cambios

### 6. Verificación

Después de hacer los cambios:
1. Registra un nuevo usuario
2. Revisa el email de confirmación
3. Haz clic en el enlace de confirmación
4. Verifica que te redirija a tu dominio de producción, no a localhost

## Notas Importantes

- Los cambios en Supabase pueden tardar unos minutos en aplicarse
- Asegúrate de que tu dominio esté correctamente configurado en tu proveedor de hosting
- El archivo `auth-redirect.astro` maneja la redirección final al dashboard
