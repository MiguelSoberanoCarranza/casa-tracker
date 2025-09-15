<template>
  <div class="form-container">
    <form @submit.prevent="saveProspecto" class="prospecto-form">
      <div class="form-grid">
        <!-- Información Personal -->
        <div class="form-section">
          <h3>
            <User class="section-icon" size="20" />
            Información Personal
          </h3>
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
          <h3>
            <MapPin class="section-icon" size="20" />
            Ubicación
          </h3>
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
          <h3>
            <Home class="section-icon" size="20" />
            Información de la Propiedad
          </h3>
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
          <h3>
            <BarChart3 class="section-icon" size="20" />
            Seguimiento y Calificación
          </h3>
          <div class="form-row">
            <div class="form-group">
              <label for="status">Estado Actual</label>
              <select v-model="form.status" id="status" class="form-input">
                <optgroup label="Estados Activos">
                  <option value="nuevo">Nuevo</option>
                  <option value="contactado">Contactado</option>
                  <option value="interesado">Interesado</option>
                  <option value="calificado">Calificado</option>
                  <option value="propuesta">Propuesta</option>
                  <option value="negociacion">Negociación</option>
                </optgroup>
                <optgroup label="Estados Finales">
                  <option value="vendido">Vendido</option>
                  <option value="perdido">Perdido</option>
                  <option value="inactivo">Inactivo</option>
                  <option value="no_interesado">No Interesado</option>
                </optgroup>
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
                <div class="stars-modern">
                  <Star v-for="i in 4" :key="i" :class="['star-modern', { filled: i <= form.puntuacion_interes }]" 
                    size="20" @click="form.puntuacion_interes = i" />
                </div>
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
          <X class="btn-icon" size="16" />
          Cancelar
        </button>
        <button v-if="prospecto" type="button" @click="deleteProspecto" class="btn-danger"
          :disabled="loading || isSubmitting">
          <span v-if="loading || isSubmitting">
            <span class="spinner"></span>
            Eliminando...
          </span>
          <span v-else>
            <Trash2 class="btn-icon" size="16" />
            Eliminar
          </span>
        </button>
        <button type="submit" :disabled="loading || isSubmitting" class="btn-primary" @click="preventDoubleSubmit">
          <span v-if="loading || isSubmitting">
            <span class="spinner"></span>
            {{ prospecto ? 'Actualizando...' : 'Guardando...' }}
          </span>
          <span v-else>
            <Save class="btn-icon" size="16" />
            {{ prospecto ? 'Actualizar' : 'Guardar' }}
          </span>
        </button>
      </div>
    </form>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, watch } from 'vue'
import { supabase } from '../lib/supabase.js'
import { 
  User, 
  MapPin, 
  Home, 
  BarChart3, 
  Star, 
  Trash2, 
  Save, 
  X
} from 'lucide-vue-next'

const props = defineProps({
  prospecto: {
    type: Object,
    default: null
  }
})

const emit = defineEmits(['saved', 'cancel', 'deleted'])

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
  }
}

// Obtener el usuario actual y asignarlo como agente
const setCurrentUserAsAgent = async () => {
  try {
    const { data: { user }, error: userError } = await supabase.auth.getUser()

    if (userError) {
      return
    }

    if (user) {
      // Asignar el usuario actual como agente
      form.agente_id = user.id
    }
  } catch (error) {
  }
}

// Función para resetear el formulario
const resetForm = () => {
  Object.assign(form, {
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
    agente_id: '',
    puntuacion_interes: 1,
    notas: ''
  })
}

// Función para cargar datos del prospecto
const loadProspectoData = async () => {
  if (!props.prospecto) {
    // Nuevo prospecto - resetear formulario y asignar usuario actual
    resetForm()
    await setCurrentUserAsAgent()
  } else {
    // Edición - cargar los datos existentes
    Object.assign(form, props.prospecto)
  }
}

// Watch para reaccionar a cambios en la prop prospecto
watch(() => props.prospecto, loadProspectoData, { immediate: false })

// Cargar datos del prospecto si se está editando
onMounted(async () => {
  await loadAgentes()
  await loadProspectoData()
})

// Función para prevenir doble click
const preventDoubleSubmit = (event) => {
  if (loading.value || isSubmitting.value) {
    event.preventDefault()
    event.stopPropagation()
    return false
  }
}

const saveProspecto = async () => {
  // Prevenir múltiples envíos
  if (loading.value || isSubmitting.value) {
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
        .eq('activo', true)
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

// Función para eliminar prospecto (borrado lógico)
const deleteProspecto = async () => {
  if (!props.prospecto) {
    return
  }

  // Confirmar eliminación
  const confirmDelete = confirm(`¿Estás seguro de que quieres eliminar el prospecto "${props.prospecto.nombre} ${props.prospecto.apellido}"?\n\nEsta acción puede deshacerse más tarde.`)

  if (!confirmDelete) {
    return
  }

  loading.value = true
  isSubmitting.value = true

  try {
    const { error } = await supabase
      .from('prospectos')
      .update({
        activo: false,
        fecha_actualizacion: new Date().toISOString()
      })
      .eq('id', props.prospecto.id)

    if (error) throw error

    // Emitir evento de eliminación exitosa
    emit('deleted')
  } catch (error) {
    alert('Error al eliminar el prospecto. Por favor, intenta de nuevo.')
  } finally {
    loading.value = false
    isSubmitting.value = false
  }
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

/* Iconos de sección */
.section-icon {
  color: #667eea;
  flex-shrink: 0;
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
  gap: 15px;
  flex-wrap: wrap;
}

/* Estilos de botones de interés eliminados - ahora usamos estrellas directas */

/* Contenedor de estrellas - estilos estándar del Dashboard */
.stars-modern {
  display: flex;
  gap: 2px;
}

/* Iconos de estrellas - estilos estándar star-modern */
.star-modern {
  opacity: 0.3;
  transition: all 0.3s ease;
  color: #d4d4d8;
  cursor: pointer;
}

.star-modern.filled {
  opacity: 1;
  color: #fbbf24;
  filter: drop-shadow(0 0 4px rgba(251, 191, 36, 0.5));
}

.star-modern:hover {
  opacity: 0.6;
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
.btn-secondary,
.btn-danger {
  padding: 12px 25px;
  border-radius: 8px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.3s ease;
  border: 2px solid transparent;
  font-size: 1rem;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
}

/* Iconos de botones */
.btn-icon {
  flex-shrink: 0;
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

.btn-danger {
  background: linear-gradient(135deg, #dc3545, #c82333);
  color: white;
  box-shadow: 0 5px 15px rgba(220, 53, 69, 0.3);
  border: 2px solid #dc3545;
}

.btn-danger:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 8px 25px rgba(220, 53, 69, 0.4);
  border-color: #c82333;
}

.btn-danger:disabled {
  opacity: 0.6;
  cursor: not-allowed;
  transform: none;
  box-shadow: 0 5px 15px rgba(220, 53, 69, 0.3);
}

/* Tablet (768px - 1024px) */
@media (max-width: 1024px) and (min-width: 769px) {
  .form-row {
    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
    gap: 15px;
  }

  .form-section {
    padding: 20px;
  }

  .form-section h3 {
    font-size: 1.1rem;
  }

  .form-actions {
    flex-direction: row;
    justify-content: flex-end;
    gap: 12px;
  }

  .btn-primary,
  .btn-secondary,
  .btn-danger {
    padding: 10px 20px;
    font-size: 0.9rem;
  }
}

/* Mobile Large (481px - 768px) */
@media (max-width: 768px) and (min-width: 481px) {
  .form-row {
    grid-template-columns: 1fr;
    gap: 15px;
  }

  .form-section {
    padding: 20px;
  }

  .form-section h3 {
    font-size: 1.1rem;
  }

  .form-actions {
    flex-direction: column;
    gap: 12px;
  }

  .btn-primary,
  .btn-secondary,
  .btn-danger {
    width: 100%;
    padding: 12px 20px;
    font-size: 0.9rem;
  }

  .interest-selector {
    justify-content: center;
    flex-wrap: wrap;
  }

  .interest-btn {
    padding: 6px 8px;
    font-size: 1rem;
  }
}

/* Mobile Small (320px - 480px) */
@media (max-width: 480px) {
  .form-container {
    padding: 0;
  }

  .prospecto-form {
    padding: 20px;
    border-radius: 10px;
  }

  .form-row {
    grid-template-columns: 1fr;
    gap: 12px;
  }

  .form-section {
    padding: 15px;
    border-radius: 8px;
  }

  .form-section h3 {
    font-size: 1rem;
    margin-bottom: 15px;
  }

  .form-group label {
    font-size: 0.9rem;
    margin-bottom: 6px;
  }

  .form-input,
  .form-textarea {
    padding: 10px 12px;
    font-size: 16px;
    /* Previene zoom en iOS */
    border-radius: 6px;
  }

  .form-textarea {
    min-height: 80px;
  }

  .form-actions {
    flex-direction: column;
    gap: 10px;
    margin-top: 20px;
    padding-top: 20px;
  }

  .btn-primary,
  .btn-secondary,
  .btn-danger {
    width: 100%;
    padding: 12px 16px;
    font-size: 0.9rem;
    border-radius: 6px;
  }

  .interest-selector {
    justify-content: center;
    flex-wrap: wrap;
    gap: 8px;
  }

  .interest-btn {
    padding: 6px 8px;
    font-size: 0.9rem;
    border-radius: 4px;
  }

  .interest-label {
    font-size: 0.85rem;
  }
}

/* Extra Small Mobile (max-width: 320px) */
@media (max-width: 320px) {
  .prospecto-form {
    padding: 15px;
  }

  .form-section {
    padding: 12px;
  }

  .form-section h3 {
    font-size: 0.95rem;
  }

  .form-group label {
    font-size: 0.85rem;
  }

  .form-input,
  .form-textarea {
    padding: 8px 10px;
    font-size: 16px;
  }

  .btn-primary,
  .btn-secondary,
  .btn-danger {
    padding: 10px 14px;
    font-size: 0.85rem;
  }

  .interest-btn {
    padding: 5px 7px;
    font-size: 0.85rem;
  }
}
</style>
