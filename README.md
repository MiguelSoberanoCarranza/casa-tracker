# 🏠 Casa Tracker

Una aplicación moderna de seguimiento de prospectos de ventas de casas construida con Astro, Vue y Supabase.

## ✨ Características

- **Gestión de Prospectos**: Registra y organiza información completa de clientes potenciales
- **Sistema de Seguimiento**: Lleva un registro detallado de todas las interacciones
- **Puntuación de Interés**: Evalúa el nivel de interés de cada prospecto
- **Dashboard Intuitivo**: Vista general con estadísticas y métricas importantes
- **Interfaz Responsiva**: Funciona perfectamente en dispositivos móviles y desktop
- **Filtros y Búsqueda**: Encuentra prospectos rápidamente

## 🚀 Tecnologías

- **Frontend**: Astro + Vue 3
- **Backend**: Supabase (PostgreSQL)
- **Despliegue**: Vercel
- **Estilos**: CSS moderno con gradientes y animaciones

## 📋 Requisitos Previos

- Node.js 18+ 
- Cuenta de Supabase
- Cuenta de Vercel (para despliegue)

## 🛠️ Instalación

1. **Clona el repositorio**
   ```bash
   git clone <tu-repositorio>
   cd casa-tracker
   ```

2. **Instala las dependencias**
   ```bash
   npm install
   ```

3. **Configura las variables de entorno**
   ```bash
   cp env.example .env
   ```
   
   Edita el archivo `.env` con tus credenciales de Supabase:
   ```
   PUBLIC_SUPABASE_URL=tu_url_de_supabase
   PUBLIC_SUPABASE_ANON_KEY=tu_clave_anonima_de_supabase
   ```

4. **Configura la base de datos**
   - Ve a tu proyecto de Supabase
   - Abre el SQL Editor
   - Ejecuta el contenido del archivo `supabase-schema.sql`

5. **Ejecuta la aplicación en desarrollo**
   ```bash
   npm run dev
   ```

   La aplicación estará disponible en `http://localhost:4321`

## 🗄️ Configuración de la Base de Datos

El archivo `supabase-schema.sql` contiene todo el esquema necesario:

- **Tabla `prospectos`**: Información de los clientes potenciales
- **Tabla `seguimientos`**: Registro de interacciones y seguimientos
- **Tabla `agentes`**: Información de los agentes de ventas
- **Índices**: Para optimizar las consultas
- **Políticas RLS**: Para seguridad de datos

## 🚀 Despliegue en Vercel

1. **Conecta tu repositorio a Vercel**
   - Ve a [vercel.com](https://vercel.com)
   - Importa tu proyecto desde GitHub

2. **Configura las variables de entorno**
   - En el dashboard de Vercel, ve a Settings > Environment Variables
   - Agrega:
     - `PUBLIC_SUPABASE_URL`
     - `PUBLIC_SUPABASE_ANON_KEY`

3. **Despliega**
   - Vercel detectará automáticamente que es un proyecto Astro
   - El despliegue se realizará automáticamente

## 📱 Uso de la Aplicación

### 1. Dashboard Principal
- Ve estadísticas generales de tus prospectos
- Accede rápidamente a las diferentes secciones

### 2. Gestión de Prospectos
- **Agregar**: Completa el formulario con toda la información del cliente
- **Editar**: Haz clic en cualquier prospecto para editarlo
- **Filtrar**: Usa los filtros para encontrar prospectos específicos
- **Buscar**: Utiliza la barra de búsqueda para localizar clientes

### 3. Sistema de Seguimiento
- **Agregar Seguimientos**: Registra cada interacción (llamadas, emails, visitas)
- **Calificar Resultados**: Marca si el seguimiento fue positivo, negativo, etc.
- **Planificar Acciones**: Define qué hacer después de cada seguimiento
- **Actualizar Puntuación**: Ajusta el nivel de interés del prospecto

### 4. Puntuación de Interés
- **1 estrella**: Bajo interés
- **2 estrellas**: Interés medio
- **3 estrellas**: Alto interés
- **4 estrellas**: Muy alto interés

## 🎨 Personalización

### Colores y Estilos
Los estilos están en los archivos `.vue` y `Layout.astro`. Puedes personalizar:
- Colores del gradiente principal
- Tipografía
- Espaciado y tamaños
- Iconos y emojis

### Campos Adicionales
Para agregar nuevos campos:
1. Actualiza el esquema en `supabase-schema.sql`
2. Modifica el formulario en `ProspectoForm.vue`
3. Actualiza la visualización en `Dashboard.vue`

## 🔧 Estructura del Proyecto

```
casa-tracker/
├── src/
│   ├── components/
│   │   ├── Dashboard.vue          # Componente principal
│   │   ├── ProspectoForm.vue     # Formulario de prospectos
│   │   └── SeguimientosList.vue  # Gestión de seguimientos
│   ├── layouts/
│   │   └── Layout.astro          # Layout principal
│   ├── lib/
│   │   └── supabase.js           # Configuración de Supabase
│   └── pages/
│       └── index.astro           # Página principal
├── public/                       # Archivos estáticos
├── astro.config.mjs             # Configuración de Astro
├── supabase-schema.sql          # Esquema de base de datos
└── vercel.json                  # Configuración de Vercel
```

## 🤝 Contribuciones

Las contribuciones son bienvenidas. Para contribuir:

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia ISC.

## 🆘 Soporte

Si tienes problemas o preguntas:

1. Revisa la documentación de [Astro](https://docs.astro.build/)
2. Consulta la documentación de [Supabase](https://supabase.com/docs)
3. Revisa la documentación de [Vercel](https://vercel.com/docs)

## 🎯 Roadmap

- [ ] Autenticación de usuarios
- [ ] Notificaciones por email
- [ ] Reportes y analytics avanzados
- [ ] Integración con CRM
- [ ] App móvil nativa
- [ ] Sistema de tareas y recordatorios

---

¡Disfruta gestionando tus prospectos de ventas de casas! 🏠✨

## 🚀 Despliegue Automático en Vercel

Este proyecto está configurado para desplegarse automáticamente en Vercel cuando se hace push a la rama main.