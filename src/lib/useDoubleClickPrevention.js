// Hook para prevenir doble click en botones y formularios
import { ref } from 'vue'

export function useDoubleClickPrevention(delay = 1000) {
  const isProcessing = ref(false)
  const lastClickTime = ref(0)

  const preventDoubleClick = (callback) => {
    return async (...args) => {
      const now = Date.now()
      
      // Si ya está procesando o el click fue muy reciente, ignorar
      if (isProcessing.value || (now - lastClickTime.value) < delay) {
        console.log('⚠️ Doble click prevenido')
        return
      }

      lastClickTime.value = now
      isProcessing.value = true

      try {
        await callback(...args)
      } catch (error) {
        console.error('Error en función protegida:', error)
        throw error
      } finally {
        // Resetear después de un delay para evitar clicks accidentales
        setTimeout(() => {
          isProcessing.value = false
        }, delay)
      }
    }
  }

  const preventDoubleSubmit = (event) => {
    if (isProcessing.value) {
      event.preventDefault()
      event.stopPropagation()
      console.log('⚠️ Envío duplicado prevenido')
      return false
    }
  }

  return {
    isProcessing,
    preventDoubleClick,
    preventDoubleSubmit
  }
}
