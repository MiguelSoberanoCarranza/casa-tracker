<template>
  <div class="form-container">
    <form @submit.prevent="saveProspecto" class="prospecto-form">
      <div class="form-grid">
        <!-- Información Personal -->
        <div class="form-section">
          <h3>👤 Información Personal</h3>
          <div class="form-row">
            <div class="form-group">
              <label for="nombre">Nombre *</label>
              <input v-model="form.nombre" type="text" id="nombre" required class="form-input"
                placeholder="Nombre del prospecto">
            </div>
            <div class="form-group">
              <label for="apellido">Apellido *</label>
              <input v-model="form.apellido" type="text" id="apellido" required class="form-input"
                placeholder="Apellido del prospecto">
            </div>
          </div>

          <div class="form-row">
            <div class="form-group">
              <label for="email">Email</label>
              <input v-model="form.email" type="email" id="email" class="form-input" placeholder="email@ejemplo.com">
            </div>
            <div class="form-group">
              <label for="telefono">Teléfono</label>
              <input v-model="form.telefono" type="tel" id="telefono" class="form-input" placeholder="+52 123 456 7890">
            </div>
          </div>
        </div>

        <!-- Ubicación -->
        <div class="form-section">
          <h3>📍 Ubicación</h3>
          <div class="form-group">
            <label for="direccion">Dirección</label>
            <input v-model="form.direccion" type="text" id="direccion" class="form-input"
              placeholder="Calle, número, colonia">
          </div>

          <div class="form-row">
            <div class="form-group">
              <label for="ciudad">Ciudad</label>
              <input v-model="form.ciudad" type="text" id="ciudad" class="form-input" placeholder="Ciudad">
            </div>
            <div class="form-group">
              <label for="estado">Estado</label>
              <input v-model="form.estado" type="text" id="estado" class="form-input" placeholder="Estado">
            </div>
            <div class="form-group">
              <label for="codigo_postal">Código Postal</label>
              <input v-model="form.codigo_postal" type="text" id="codigo_postal" class="form-input" placeholder="12345">
            </div>
          </div>
        </div>

        <!-- Información de la Propiedad -->
        <div class="form-section">
          <h3>🏠 Información de la Propiedad</h3>
          <div class="form-row">
            <div class="form-group">
              <label for="presupuesto_max">Presupuesto Máximo</label>
              <input v-model="form.presupuesto_max" type="number" id="presupuesto_max" class="form-input"
                placeholder="1000000" min="0" step="1000">
            </div>
            <div class="form-group">
              <label for="tipo_propiedad">Tipo de Propiedad</label>
              <select v-model="form.tipo_propiedad" id="tipo_propiedad" class="form-input">
                <option value="">Seleccionar tipo</option>
                <option value="casa">Casa</option>
                <option value="departamento">Departamento</option>
                <option value="terreno">Terreno</option>
                <option value="local">Local Comercial</option>
                <option value="oficina">Oficina</option>
                <option value="bodega">Bodega</option>
              </select>
            </div>
          </div>

          <div class="form-row">
            <div class="form-group">
              <label for="habitaciones">Habitaciones</label>
              <input v-model="form.habitaciones" type="number" id="habitaciones" class="form-input" placeholder="3"
                min="0">
            </div>
            <div class="form-group">
              <label for="banos">Baños</label>
              <input v-model="form.banos" type="number" id="banos" class="form-input" placeholder="2" min="0"
                step="0.5">
            </div>
            <div class="form-group">
              <label for="metros_cuadrados">Metros Cuadrados</label>
              <input v-model="form.metros_cuadrados" type="number" id="metros_cuadrados" class="form-input"
                placeholder="120" min="0">
            </div>
          </div>
        </div>

        <!-- Seguimiento y Calificación -->
        <div class="form-section">
          <h3>📊 Seguimiento y Calificación</h3>
          <div class="form-row">
            <div class="form-group">
              <label for="status">Estado Actual</label>
              <select v-model="form.status" id="status" class="form-input">
                <option value="nuevo">Nuevo</option>
                <option value="contactado">Contactado</option>
                <option value="interesado">Interesado</option>
                <option value="calificado">Calificado</option>
                <option value="propuesta">Propuesta</option>
                <option value="negociacion">Negociación</option>
                <option value="vendido">Vendido</option>
                <option value="perdido">Perdido</option>
              </select>
            </div>
            <div class="form-group">
              <label for="agente_id">Agente Asignado</label>
              <select v-model="form.agente_id" id="agente_id" class="form-input">
                <option value="">Seleccionar agente</option>
                <option v-for="agente in agentes" :key="agente.id" :value="agente.id">
                  {{ agente.nombre }}
                </option>
              </select>
            </div>
          </div>

          <div class="form-row">
            <div class="form-group">
              <label for="puntuacion_interes">Puntuación de Interés</label>
              <div class="interest-selector">
                <button v-for="i in 4" :key="i" type="button" @click="form.puntuacion_interes = i"
                  :class="['interest-btn', { active: form.puntuacion_interes >= i }]">
                  ⭐
                </button>
                <span class="interest-label">
                  {{ getInterestLabel(form.puntuacion_interes) }}
                </span>
              </div>
            </div>
          </div>

          <div class="form-group">
            <label for="notas">Notas Adicionales</label>
            <textarea v-model="form.notas" id="notas" class="form-textarea" rows="4"
              placeholder="Información adicional sobre el prospecto, preferencias, comentarios importantes..."></textarea>
          </div>
        </div>
      </div>

      <!-- Botones de acción -->
      <div class="form-actions">
        <button type="button" @click="$emit('cancel')" class="btn-secondary">
          Cancelar
        </button>
        <button type="submit" :disabled="loading || isSubmitting" class="btn-primary" @click="preventDoubleSubmit">
          <span v-if="loading || isSubmitting">
            <span class="spinner"></span>
            {{ prospecto ? 'Actualizando...' : 'Guardando...' }}
          </span>
          <span v-else>
            {{ prospecto ? 'Actualizar' : 'Guardar' }}
          </span>
        </button>
      </div>
    </form>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { supabase } from '../lib/supabase.js'

const props = defineProps({
  prospecto: {
    type: Object,
    default: null
  }
})

const emit = defineEmits(['saved', 'cancel'])

const loading = ref(false)
const isSubmitting = ref(false)
const agentes = ref([])

// Formulario reactivo
const form = reactive({
  nombre: '',
  apellido: '',
  email: '',
  telefono: '',
  direccion: '',
  ciudad: '',
  estado: '',
  codigo_postal: '',
  presupuesto_max: null,
  tipo_propiedad: '',
  habitaciones: null,
  banos: null,
  metros_cuadrados: null,
  status: 'nuevo',
  puntuacion_interes: 1,
  agente_id: null,
  notas: ''
})

// Cargar agentes
const loadAgentes = async () => {
  try {
    const { data, error } = await supabase
      .from('agentes')
      .select('id, nombre, email')
      .eq('activo', true)
      .order('nombre')

    if (error) throw error
    agentes.value = data || []
  } catch (error) {
    console.error('Error cargando agentes:', error)
  }
}

// Obtener el usuario actual y asignarlo como agente
const setCurrentUserAsAgent = async () => {
  try {
    const { data: { user }, error: userError } = await supabase.auth.getUser()

    if (userError) {
      console.error('Error obteniendo usuario:', userError)
      return
    }

    if (user) {
      // Asignar el usuario actual como agente
      form.agente_id = user.id
      console.log('👤 Usuario asignado como agente:', user.id)
    }
  } catch (error) {
    console.error('Error asignando usuario como agente:', error)
  }
}

// Cargar datos del prospecto si se está editando
onMounted(async () => {
  await loadAgentes()

  // Si es un nuevo prospecto, asignar el usuario actual
  if (!props.prospecto) {
    await setCurrentUserAsAgent()
  } else {
    // Si es edición, cargar los datos existentes
    Object.assign(form, props.prospecto)
  }
})

// Función para prevenir doble click
const preventDoubleSubmit = (event) => {
  if (loading.value || isSubmitting.value) {
    event.preventDefault()
    event.stopPropagation()
    console.log('⚠️ Doble click prevenido')
    return false
  }
}

const saveProspecto = async () => {
  // Prevenir múltiples envíos
  if (loading.value || isSubmitting.value) {
    console.log('⚠️ Ya se está guardando, ignorando envío duplicado')
    return
  }

  loading.value = true
  isSubmitting.value = true

  try {
    // Verificar duplicados antes de guardar (solo para nuevos prospectos)
    if (!props.prospecto) {
      const { data: existingProspectos, error: checkError } = await supabase
        .from('prospectos')
        .select('id, nombre, apellido, email, telefono')
        .eq('agente_id', form.agente_id)
        .eq('nombre', form.nombre)
        .eq('apellido', form.apellido)
        .or(`email.eq.${form.email},telefono.eq.${form.telefono}`)

      if (checkError) throw checkError

      if (existingProspectos && existingProspectos.length > 0) {
        alert('Ya existe un prospecto con el mismo nombre y datos de contacto. Por favor, verifica los datos.')
        loading.value = false
        return
      }
    }

    const prospectoData = {
      ...form,
      presupuesto_max: form.presupuesto_max ? parseFloat(form.presupuesto_max) : null,
      habitaciones: form.habitaciones ? parseInt(form.habitaciones) : null,
      banos: form.banos ? parseFloat(form.banos) : null,
      metros_cuadrados: form.metros_cuadrados ? parseInt(form.metros_cuadrados) : null,
      fecha_actualizacion: new Date().toISOString()
    }

    if (props.prospecto) {
      // Actualizar prospecto existente
      const { error } = await supabase
        .from('prospectos')
        .update(prospectoData)
        .eq('id', props.prospecto.id)

      if (error) throw error
    } else {
      // Crear nuevo prospecto
      const { error } = await supabase
        .from('prospectos')
        .insert([prospectoData])

      if (error) throw error
    }

    emit('saved')
  } catch (error) {
    console.error('Error guardando prospecto:', error)
    alert('Error al guardar el prospecto. Por favor, intenta de nuevo.')
  } finally {
    loading.value = false
    isSubmitting.value = false
  }
}

const getInterestLabel = (score) => {
  const labels = {
    1: 'Bajo',
    2: 'Medio',
    3: 'Alto',
    4: 'Muy Alto'
  }
  return labels[score] || 'Bajo'
}
</script>

<style scoped>
.form-container {
  max-width: 100%;
}

.prospecto-form {
  background: white;
  border-radius: 15px;
  padding: 30px;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
}

.form-grid {
  display: grid;
  gap: 30px;
}

.form-section {
  border: 1px solid #e0e0e0;
  border-radius: 10px;
  padding: 25px;
  background: #fafafa;
}

.form-section h3 {
  margin-bottom: 20px;
  color: #333;
  font-size: 1.2rem;
  font-weight: 600;
  display: flex;
  align-items: center;
  gap: 8px;
}

.form-row {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 20px;
  margin-bottom: 20px;
}

.form-row:last-child {
  margin-bottom: 0;
}

.form-group {
  display: flex;
  flex-direction: column;
}

.form-group label {
  margin-bottom: 8px;
  font-weight: 500;
  color: #555;
  font-size: 0.95rem;
}

.form-input,
.form-textarea {
  padding: 12px 15px;
  border: 2px solid #e0e0e0;
  border-radius: 8px;
  font-size: 1rem;
  transition: all 0.3s ease;
  background: white;
}

.form-input:focus,
.form-textarea:focus {
  outline: none;
  border-color: #667eea;
  box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
}

.form-textarea {
  resize: vertical;
  min-height: 100px;
}

.interest-selector {
  display: flex;
  align-items: center;
  gap: 10px;
  flex-wrap: wrap;
}

.interest-btn {
  background: none;
  border: 2px solid #e0e0e0;
  border-radius: 8px;
  padding: 8px 12px;
  cursor: pointer;
  font-size: 1.2rem;
  transition: all 0.3s ease;
  background: white;
}

.interest-btn:hover {
  border-color: #667eea;
  background: #f8f9ff;
}

.interest-btn.active {
  border-color: #667eea;
  background: linear-gradient(135deg, #667eea, #764ba2);
  color: white;
}

.interest-label {
  font-weight: 500;
  color: #666;
  font-size: 0.9rem;
}

.form-actions {
  display: flex;
  justify-content: flex-end;
  gap: 15px;
  margin-top: 30px;
  padding-top: 25px;
  border-top: 1px solid #e0e0e0;
}

.btn-primary,
.btn-secondary {
  padding: 12px 25px;
  border-radius: 8px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.3s ease;
  border: none;
  font-size: 1rem;
}

.btn-primary {
  background: linear-gradient(135deg, #667eea, #764ba2);
  color: white;
  box-shadow: 0 5px 15px rgba(102, 126, 234, 0.3);
}

.btn-primary:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 8px 25px rgba(102, 126, 234, 0.4);
}

.btn-primary:disabled {
  opacity: 0.6;
  cursor: not-allowed;
  transform: none;
}

/* Spinner de carga */
.spinner {
  display: inline-block;
  width: 16px;
  height: 16px;
  border: 2px solid #ffffff;
  border-radius: 50%;
  border-top-color: transparent;
  animation: spin 1s ease-in-out infinite;
  margin-right: 8px;
}

@keyframes spin {
  to {
    transform: rotate(360deg);
  }
}

/* Efecto de click deshabilitado */
.btn-primary:disabled:hover {
  transform: none;
  box-shadow: 0 5px 15px rgba(102, 126, 234, 0.3);
}

.btn-secondary {
  background: #f8f9fa;
  color: #666;
  border: 2px solid #e0e0e0;
}

.btn-secondary:hover {
  background: #e9ecef;
  border-color: #d0d0d0;
}

@media (max-width: 768px) {
  .form-row {
    grid-template-columns: 1fr;
  }

  .form-actions {
    flex-direction: column;
  }

  .interest-selector {
    justify-content: center;
  }
}
</style>
