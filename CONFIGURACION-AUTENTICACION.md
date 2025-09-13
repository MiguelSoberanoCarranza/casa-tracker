# 🔐 Configuración de Autenticación - Casa Tracker

Esta guía te ayudará a configurar el sistema de autenticación en Casa Tracker usando Supabase.

## 📋 Pasos de Configuración

### 1. Configurar Variables de Entorno

Copia el archivo de ejemplo y configura tus credenciales:

```bash
cp env.example .env
```

Edita el archivo `.env` con tus credenciales de Supabase:
```
PUBLIC_SUPABASE_URL=tu_url_de_supabase
PUBLIC_SUPABASE_ANON_KEY=tu_clave_anonima_de_supabase
```

### 2. Configurar Autenticación en Supabase

1. **Ve a tu proyecto de Supabase**
2. **Navega a Authentication > Settings**
3. **Configura las siguientes URLs:**

   **Para desarrollo:**
   - Site URL: `http://localhost:4321`
   - Redirect URLs: `http://localhost:4321/auth-redirect`

   **Para producción:**
   - Site URL: `https://tu-dominio.com`
   - Redirect URLs: `https://tu-dominio.com/auth-redirect`

4. **Habilita la autenticación por email:**
   - En Authentication > Settings, asegúrate de que "Enable email confirmations" esté activado
   - Opcional: Configura un template de email personalizado

### 3. Configurar la Base de Datos

#### Opción A: Base de datos nueva (recomendado)
1. **Ejecutar el esquema principal:**
   Ejecuta el contenido de `supabase-schema.sql` en el SQL Editor de Supabase.

2. **Ejecutar las políticas de autenticación:**
   Ejecuta el contenido de `auth-policies.sql` en el SQL Editor de Supabase.

#### Opción B: Base de datos existente (si ya tienes datos)
Si ya ejecutaste el esquema anteriormente y tienes errores como "trigger already exists":

1. **Arreglo rápido (solo el trigger):**
   Ejecuta el contenido de `quick-fix-trigger.sql` en el SQL Editor de Supabase.

2. **Arreglo completo (recrear toda la estructura):**
   ⚠️ **ADVERTENCIA:** Esto eliminará todos los datos existentes
   Ejecuta el contenido de `fix-database.sql` en el SQL Editor de Supabase.

### 4. Verificar la Configuración

1. **Inicia la aplicación:**
   ```bash
   npm run dev
   ```

2. **Visita la página de login:**
   ```
   http://localhost:4321/login
   ```

3. **Crea una cuenta de prueba:**
   - Haz clic en "Regístrate aquí"
   - Completa el formulario de registro
   - Revisa tu email para confirmar la cuenta

4. **Inicia sesión:**
   - Usa las credenciales que acabas de crear
   - Deberías ser redirigido al dashboard

## 🔧 Funcionalidades de Autenticación

### ✅ Lo que incluye el sistema:

- **Registro de usuarios** con confirmación por email
- **Inicio de sesión** con email y contraseña
- **Protección de rutas** - solo usuarios autenticados pueden acceder
- **Logout** con limpieza de sesión
- **Políticas RLS** - cada usuario solo ve sus propios datos
- **Perfil automático** - se crea automáticamente un perfil de agente
- **Interfaz responsive** - funciona en móvil y desktop

### 🔒 Seguridad implementada:

- **Row Level Security (RLS)** en todas las tablas
- **Políticas específicas** por usuario
- **Validación de sesión** en cada request
- **Limpieza automática** de datos al eliminar usuarios
- **Tokens JWT** manejados por Supabase

## 🚨 Solución de Problemas

### Error: "trigger already exists" o "relation already exists"
**Problema:** Ya ejecutaste el esquema de base de datos anteriormente.

**Solución:**
1. **Para solo el trigger:** Ejecuta `quick-fix-trigger.sql`
2. **Para recrear todo:** Ejecuta `fix-database.sql` (⚠️ elimina datos existentes)

### Error: "Invalid login credentials"
- Verifica que el usuario esté registrado
- Asegúrate de haber confirmado el email
- Revisa que las credenciales sean correctas

### Error: "Email not confirmed"
- Revisa tu bandeja de entrada
- Busca emails de Supabase
- Verifica que no estén en spam

### Error: "Redirect URL mismatch"
- Verifica las URLs configuradas en Supabase
- Asegúrate de que coincidan exactamente
- Incluye el protocolo (http/https)

### La aplicación no redirige correctamente
- Verifica que `auth-redirect.astro` esté en la carpeta correcta
- Revisa la consola del navegador para errores
- Asegúrate de que las variables de entorno estén configuradas

## 📱 URLs Importantes

- **Login:** `/login`
- **Registro:** `/login` (cambiar a modo registro)
- **Dashboard:** `/` (requiere autenticación)
- **Redirección:** `/auth-redirect`

## 🔄 Flujo de Autenticación

1. **Usuario no autenticado** → Redirigido a `/login`
2. **Usuario se registra** → Email de confirmación enviado
3. **Usuario confirma email** → Puede iniciar sesión
4. **Usuario inicia sesión** → Redirigido a `/`
5. **Usuario navega** → Sesión mantenida automáticamente
6. **Usuario hace logout** → Redirigido a `/login`

## 🛠️ Personalización

### Cambiar el diseño del login
Edita `src/pages/login.astro` para personalizar:
- Colores y estilos
- Mensajes de error
- Campos adicionales
- Validaciones

### Agregar campos al perfil
1. Modifica la tabla `agentes` en `supabase-schema.sql`
2. Actualiza el trigger `handle_new_user` en `auth-policies.sql`
3. Agrega los campos en la interfaz

### Cambiar las políticas de seguridad
Modifica `auth-policies.sql` para ajustar:
- Quién puede ver qué datos
- Permisos de edición
- Reglas de negocio específicas

## 📞 Soporte

Si tienes problemas:
1. Revisa los logs de Supabase en el dashboard
2. Verifica la consola del navegador
3. Asegúrate de que todos los scripts SQL se ejecutaron correctamente
4. Consulta la documentación de [Supabase Auth](https://supabase.com/docs/guides/auth)
