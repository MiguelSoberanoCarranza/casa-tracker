import { ref, computed, onMounted, onUnmounted } from 'vue'
import { supabase } from './supabase.js'

// Estado global de autenticación
const user = ref(null)
const loading = ref(true)

// Función para inicializar la autenticación
const initAuth = async () => {
  try {
    // Obtener sesión actual
    const { data: { session }, error } = await supabase.auth.getSession()
    
    if (error) {
      console.error('Error obteniendo sesión:', error)
      return
    }
    
    user.value = session?.user || null
  } catch (error) {
    console.error('Error inicializando auth:', error)
  } finally {
    loading.value = false
  }
}

// Función para hacer login
const login = async (email, password) => {
  try {
    loading.value = true
    const { data, error } = await supabase.auth.signInWithPassword({
      email,
      password,
    })
    
    if (error) throw error
    
    user.value = data.user
    return { success: true, user: data.user }
  } catch (error) {
    return { success: false, error: error.message }
  } finally {
    loading.value = false
  }
}

// Función para hacer logout
const logout = async () => {
  try {
    const { error } = await supabase.auth.signOut()
    if (error) throw error
    
    user.value = null
    return { success: true }
  } catch (error) {
    return { success: false, error: error.message }
  }
}

// Función para registrar usuario
const register = async (email, password) => {
  try {
    loading.value = true
    const { data, error } = await supabase.auth.signUp({
      email,
      password,
    })
    
    if (error) throw error
    
    return { success: true, user: data.user }
  } catch (error) {
    return { success: false, error: error.message }
  } finally {
    loading.value = false
  }
}

// Función para login con Google
const loginWithGoogle = async () => {
  try {
    loading.value = true
    const { data, error } = await supabase.auth.signInWithOAuth({
      provider: 'google',
      options: {
        redirectTo: `${window.location.origin}/auth-redirect`
      }
    })
    
    if (error) throw error
    
    return { success: true, data }
  } catch (error) {
    return { success: false, error: error.message }
  } finally {
    loading.value = false
  }
}

// Función para resetear contraseña
const resetPassword = async (email) => {
  try {
    const { error } = await supabase.auth.resetPasswordForEmail(email, {
      redirectTo: `${window.location.origin}/login`,
    })
    
    if (error) throw error
    
    return { success: true }
  } catch (error) {
    return { success: false, error: error.message }
  }
}

// Función para actualizar perfil
const updateProfile = async (updates) => {
  try {
    const { error } = await supabase.auth.updateUser(updates)
    if (error) throw error
    
    return { success: true }
  } catch (error) {
    return { success: false, error: error.message }
  }
}

// Composable principal
export const useAuth = () => {
  // Inicializar auth al montar el composable
  onMounted(() => {
    initAuth()
    
    // Escuchar cambios de autenticación
    const { data: { subscription } } = supabase.auth.onAuthStateChange(
      async (event, session) => {
        user.value = session?.user || null
        loading.value = false
        
        // Redirigir según el estado de autenticación
        if (event === 'SIGNED_OUT') {
          window.location.href = '/login'
        } else if (event === 'SIGNED_IN' && window.location.pathname === '/login') {
          window.location.href = '/'
        }
      }
    )
    
    // Limpiar suscripción al desmontar
    onUnmounted(() => {
      subscription?.unsubscribe()
    })
  })

  // Computed properties
  const isAuthenticated = computed(() => !!user.value)
  const isAdmin = computed(() => {
    // Aquí puedes agregar lógica para determinar si es admin
    // Por ejemplo, verificar un campo en la metadata del usuario
    return user.value?.user_metadata?.role === 'admin' || false
  })

  return {
    // Estado
    user: computed(() => user.value),
    loading: computed(() => loading.value),
    isAuthenticated,
    isAdmin,
    
    // Métodos
    login,
    loginWithGoogle,
    logout,
    register,
    resetPassword,
    updateProfile,
    initAuth
  }
}

// Función utilitaria para verificar autenticación en componentes
export const requireAuth = () => {
  const { isAuthenticated, loading } = useAuth()
  
  if (!loading.value && !isAuthenticated.value) {
    window.location.href = '/login'
    return false
  }
  
  return true
}

// Función para obtener el usuario actual (síncrona)
export const getCurrentUser = () => {
  return user.value
}

// Función para verificar si el usuario está autenticado (síncrona)
export const isUserAuthenticated = () => {
  return !!user.value
}
