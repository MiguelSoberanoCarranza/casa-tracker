<template>
  <div class="seguimientos-container">
    <div class="seguimientos-header">
      <h3>Seguimientos de {{ prospecto.nombre }} {{ prospecto.apellido }}</h3>
      <button @click="showAddForm = true" class="btn-primary">
        ➕ Nuevo Seguimiento
      </button>
    </div>

    <!-- Formulario de nuevo seguimiento -->
    <div v-if="showAddForm" class="seguimiento-form">
      <h4>Agregar Seguimiento</h4>
      <form @submit.prevent="saveSeguimiento">
        <div class="form-row">
          <div class="form-group">
            <label for="tipo_seguimiento">Tipo de Seguimiento</label>
            <select v-model="seguimientoForm.tipo_seguimiento" id="tipo_seguimiento" required class="form-input">
              <option value="">Seleccionar tipo</option>
              <option value="llamada">📞 Llamada</option>
              <option value="email">📧 Email</option>
              <option value="visita">🏠 Visita</option>
              <option value="mensaje">💬 Mensaje</option>
              <option value="reunion">🤝 Reunión</option>
            </select>
          </div>
          <div class="form-group">
            <label for="resultado">Resultado</label>
            <select v-model="seguimientoForm.resultado" id="resultado" class="form-input">
              <option value="">Seleccionar resultado</option>
              <option value="positivo">✅ Positivo</option>
              <option value="negativo">❌ Negativo</option>
              <option value="neutral">⚪ Neutral</option>
              <option value="pendiente">⏳ Pendiente</option>
            </select>
          </div>
        </div>

        <div class="form-group">
          <label for="descripcion">Descripción *</label>
          <textarea v-model="seguimientoForm.descripcion" id="descripcion" required class="form-textarea" rows="3"
            placeholder="Describe lo que sucedió en este seguimiento..."></textarea>
        </div>

        <div class="form-group">
          <label for="proxima_accion">Próxima Acción</label>
          <input v-model="seguimientoForm.proxima_accion" type="text" id="proxima_accion" class="form-input"
            placeholder="¿Qué sigue después de este seguimiento?">
        </div>

        <div class="form-row">
          <div class="form-group">
            <label for="proxima_accion_tipo">Tipo de Próxima Acción</label>
            <select v-model="seguimientoForm.proxima_accion_tipo" id="proxima_accion_tipo" class="form-input">
              <option value="">Seleccionar tipo</option>
              <option value="llamada">📞 Llamada</option>
              <option value="email">📧 Email</option>
              <option value="visita">🏠 Visita</option>
              <option value="mensaje">💬 Mensaje</option>
              <option value="reunion">🤝 Reunión</option>
            </select>
          </div>
          <div class="form-group">
            <label for="proxima_accion_fecha">Fecha Programada</label>
            <input v-model="seguimientoForm.proxima_accion_fecha" type="datetime-local" id="proxima_accion_fecha"
              class="form-input" :min="new Date().toISOString().slice(0, 16)">
          </div>
        </div>

        <div class="form-actions">
          <button type="button" @click="cancelForm" class="btn-secondary">
            Cancelar
          </button>
          <button type="submit" :disabled="loading" class="btn-primary">
            {{ loading ? 'Guardando...' : 'Guardar Seguimiento' }}
          </button>
        </div>
      </form>
    </div>

    <!-- Lista de seguimientos -->
    <div class="seguimientos-list">
      <div v-if="seguimientos.length === 0" class="no-seguimientos">
        <p>No hay seguimientos registrados para este prospecto.</p>
      </div>

      <div v-else>
        <div v-for="seguimiento in seguimientos" :key="seguimiento.id" class="seguimiento-card">
          <div class="seguimiento-header">
            <div class="seguimiento-tipo">
              <span class="tipo-icon">{{ getTipoIcon(seguimiento.tipo_seguimiento) }}</span>
              <span class="tipo-text">{{ getTipoLabel(seguimiento.tipo_seguimiento) }}</span>
            </div>
            <div class="seguimiento-meta">
              <div class="seguimiento-fecha">
                {{ formatDate(seguimiento.fecha_seguimiento) }}
              </div>
              <div v-if="seguimiento.agentes" class="seguimiento-agente">
                👤 {{ seguimiento.agentes.nombre }}
              </div>
            </div>
          </div>

          <div class="seguimiento-content">
            <p class="descripcion">{{ seguimiento.descripcion }}</p>

            <div v-if="seguimiento.resultado" class="resultado">
              <strong>Resultado:</strong>
              <span :class="['resultado-badge', seguimiento.resultado]">
                {{ getResultadoLabel(seguimiento.resultado) }}
              </span>
            </div>

            <div v-if="seguimiento.proxima_accion" class="proxima-accion">
              <strong>Próxima acción:</strong> {{ seguimiento.proxima_accion }}
              <div v-if="seguimiento.proxima_accion_fecha" class="proxima-accion-fecha">
                <span class="fecha-label">📅 Programado para:</span>
                <span class="fecha-valor">{{ formatDateTime(seguimiento.proxima_accion_fecha) }}</span>
                <span v-if="seguimiento.proxima_accion_tipo" class="tipo-programado">
                  ({{ getTipoLabel(seguimiento.proxima_accion_tipo) }})
                </span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Actualizar puntuación de interés -->
    <div class="interest-update">
      <h4>Actualizar Puntuación de Interés</h4>
      <div class="interest-selector">
        <button v-for="i in 4" :key="i" type="button" @click="updateInterestScore(i)"
          :class="['interest-btn', { active: prospecto.puntuacion_interes >= i }]">
          ⭐
        </button>
        <span class="interest-label">
          {{ getInterestLabel(prospecto.puntuacion_interes) }}
        </span>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { supabase } from '../lib/supabase.js'

const props = defineProps({
  prospecto: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['updated'])

const seguimientos = ref([])
const showAddForm = ref(false)
const loading = ref(false)

const seguimientoForm = reactive({
  tipo_seguimiento: '',
  descripcion: '',
  resultado: '',
  proxima_accion: '',
  proxima_accion_fecha: '',
  proxima_accion_tipo: ''
})

// Cargar seguimientos
const loadSeguimientos = async () => {
  try {
    // Obtener el usuario autenticado actual
    const { data: { user }, error: userError } = await supabase.auth.getUser()

    if (userError || !user) {
      return
    }

    const { data, error } = await supabase
      .from('seguimientos')
      .select(`
        *,
        agentes (
          id,
          nombre,
          email
        )
      `)
      .eq('prospecto_id', props.prospecto.id)
      .eq('agente_id', user.id)
      .order('fecha_seguimiento', { ascending: false })

    if (error) throw error
    seguimientos.value = data || []
  } catch (error) {
  }
}

// Guardar seguimiento
const saveSeguimiento = async () => {
  loading.value = true

  try {
    // Obtener el usuario autenticado actual
    const { data: { user }, error: userError } = await supabase.auth.getUser()

    if (userError || !user) {
      alert('Error de autenticación. Por favor, inicia sesión nuevamente.')
      return
    }

    const agenteId = user.id

    const seguimientoData = {
      prospecto_id: props.prospecto.id,
      agente_id: agenteId,
      tipo_seguimiento: seguimientoForm.tipo_seguimiento,
      descripcion: seguimientoForm.descripcion,
      resultado: seguimientoForm.resultado || null,
      proxima_accion: seguimientoForm.proxima_accion || null,
      proxima_accion_tipo: seguimientoForm.proxima_accion_tipo || null,
      proxima_accion_fecha: seguimientoForm.proxima_accion_fecha ? new Date(seguimientoForm.proxima_accion_fecha).toISOString() : null,
      fecha_seguimiento: new Date().toISOString()
    }

    const { error } = await supabase
      .from('seguimientos')
      .insert([seguimientoData])

    if (error) throw error

    // Actualizar fecha de actualización del prospecto
    await supabase
      .from('prospectos')
      .update({ fecha_actualizacion: new Date().toISOString() })
      .eq('id', props.prospecto.id)

    // Limpiar formulario y recargar datos
    Object.assign(seguimientoForm, {
      tipo_seguimiento: '',
      descripcion: '',
      resultado: '',
      proxima_accion: ''
    })

    showAddForm.value = false
    loadSeguimientos()
    emit('updated')
  } catch (error) {
    alert('Error al guardar el seguimiento. Por favor, intenta de nuevo.')
  } finally {
    loading.value = false
  }
}

// Actualizar puntuación de interés
const updateInterestScore = async (score) => {
  try {
    // Obtener el usuario autenticado actual
    const { data: { user }, error: userError } = await supabase.auth.getUser()

    if (userError || !user) {
      alert('Error de autenticación. Por favor, inicia sesión nuevamente.')
      return
    }

    const { error } = await supabase
      .from('prospectos')
      .update({
        puntuacion_interes: score,
        fecha_actualizacion: new Date().toISOString()
      })
      .eq('id', props.prospecto.id)
      .eq('agente_id', user.id)

    if (error) throw error

    // Actualizar el prospecto local
    props.prospecto.puntuacion_interes = score
    emit('updated')
  } catch (error) {
    alert('Error al actualizar la puntuación. Por favor, intenta de nuevo.')
  }
}

const cancelForm = () => {
  showAddForm.value = false
  Object.assign(seguimientoForm, {
    tipo_seguimiento: '',
    descripcion: '',
    resultado: '',
    proxima_accion: '',
    proxima_accion_fecha: '',
    proxima_accion_tipo: ''
  })
}

// Funciones de utilidad
const getTipoIcon = (tipo) => {
  const icons = {
    llamada: '📞',
    email: '📧',
    visita: '🏠',
    mensaje: '💬',
    reunion: '🤝'
  }
  return icons[tipo] || '📝'
}

const getTipoLabel = (tipo) => {
  const labels = {
    llamada: 'Llamada',
    email: 'Email',
    visita: 'Visita',
    mensaje: 'Mensaje',
    reunion: 'Reunión'
  }
  return labels[tipo] || tipo
}

const getResultadoLabel = (resultado) => {
  const labels = {
    positivo: 'Positivo',
    negativo: 'Negativo',
    neutral: 'Neutral',
    pendiente: 'Pendiente'
  }
  return labels[resultado] || resultado
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

const formatDate = (date) => {
  if (!date) return 'N/A'
  return new Date(date).toLocaleDateString('es-MX', {
    year: 'numeric',
    month: 'short',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  })
}

const formatDateTime = (date) => {
  if (!date) return 'N/A'
  return new Date(date).toLocaleString('es-MX', {
    year: 'numeric',
    month: 'short',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit',
    weekday: 'short'
  })
}

onMounted(() => {
  loadSeguimientos()
})
</script>

<style scoped>
.seguimientos-container {
  max-width: 100%;
}

.seguimientos-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 25px;
  padding-bottom: 15px;
  border-bottom: 2px solid #f0f0f0;
}

.seguimientos-header h3 {
  color: #333;
  font-size: 1.4rem;
}

.seguimiento-form {
  background: #f8f9fa;
  border-radius: 10px;
  padding: 25px;
  margin-bottom: 30px;
  border: 1px solid #e0e0e0;
}

.seguimiento-form h4 {
  margin-bottom: 20px;
  color: #333;
  font-size: 1.2rem;
}

.form-row {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 20px;
  margin-bottom: 20px;
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
  padding: 10px 12px;
  border: 2px solid #e0e0e0;
  border-radius: 6px;
  font-size: 0.95rem;
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
  min-height: 80px;
}

.form-actions {
  display: flex;
  justify-content: flex-end;
  gap: 15px;
  margin-top: 20px;
}

.btn-primary,
.btn-secondary {
  padding: 10px 20px;
  border-radius: 6px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.3s ease;
  border: none;
  font-size: 0.95rem;
}

.btn-primary {
  background: linear-gradient(135deg, #667eea, #764ba2);
  color: white;
  box-shadow: 0 3px 10px rgba(102, 126, 234, 0.3);
}

.btn-primary:hover:not(:disabled) {
  transform: translateY(-1px);
  box-shadow: 0 5px 15px rgba(102, 126, 234, 0.4);
}

.btn-primary:disabled {
  opacity: 0.6;
  cursor: not-allowed;
  transform: none;
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

.seguimientos-list {
  margin-bottom: 30px;
}

.no-seguimientos {
  text-align: center;
  padding: 40px 20px;
  color: #666;
  font-style: italic;
}

.seguimiento-card {
  background: white;
  border-radius: 10px;
  padding: 20px;
  margin-bottom: 15px;
  box-shadow: 0 3px 10px rgba(0, 0, 0, 0.1);
  border-left: 4px solid #667eea;
}

.seguimiento-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 15px;
}

.seguimiento-tipo {
  display: flex;
  align-items: center;
  gap: 8px;
  font-weight: 500;
  color: #333;
}

.tipo-icon {
  font-size: 1.2rem;
}

.tipo-text {
  font-size: 1rem;
}

.seguimiento-meta {
  display: flex;
  flex-direction: column;
  align-items: flex-end;
  gap: 5px;
}

.seguimiento-fecha {
  color: #666;
  font-size: 0.9rem;
}

.seguimiento-agente {
  color: #667eea;
  font-size: 0.8rem;
  font-weight: 500;
  background: rgba(102, 126, 234, 0.1);
  padding: 2px 8px;
  border-radius: 12px;
}

.seguimiento-content {
  color: #555;
}

.descripcion {
  margin-bottom: 10px;
  line-height: 1.5;
}

.resultado,
.proxima-accion {
  margin-bottom: 8px;
  font-size: 0.9rem;
}

.proxima-accion-fecha {
  margin-top: 8px;
  padding: 8px 12px;
  background: linear-gradient(135deg, #e3f2fd, #f3e5f5);
  border-radius: 8px;
  border-left: 4px solid #667eea;
  display: flex;
  align-items: center;
  gap: 8px;
  flex-wrap: wrap;
}

.fecha-label {
  font-weight: 600;
  color: #667eea;
  font-size: 0.85rem;
}

.fecha-valor {
  color: #333;
  font-weight: 500;
  font-size: 0.9rem;
}

.tipo-programado {
  color: #666;
  font-size: 0.8rem;
  font-style: italic;
}

.resultado-badge {
  padding: 4px 8px;
  border-radius: 12px;
  font-size: 0.8rem;
  font-weight: 500;
  text-transform: uppercase;
}

.resultado-badge.positivo {
  background: #e8f5e8;
  color: #2e7d32;
}

.resultado-badge.negativo {
  background: #ffebee;
  color: #d32f2f;
}

.resultado-badge.neutral {
  background: #f5f5f5;
  color: #666;
}

.resultado-badge.pendiente {
  background: #fff3e0;
  color: #f57c00;
}

.interest-update {
  background: #f8f9fa;
  border-radius: 10px;
  padding: 20px;
  border: 1px solid #e0e0e0;
}

.interest-update h4 {
  margin-bottom: 15px;
  color: #333;
  font-size: 1.1rem;
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
  border-radius: 6px;
  padding: 6px 10px;
  cursor: pointer;
  font-size: 1.1rem;
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

/* Tablet (768px - 1024px) */
@media (max-width: 1024px) and (min-width: 769px) {
  .seguimientos-header {
    flex-direction: row;
    gap: 20px;
    align-items: center;
  }

  .form-row {
    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
    gap: 15px;
  }

  .form-actions {
    flex-direction: row;
    justify-content: flex-end;
    gap: 12px;
  }

  .btn-primary,
  .btn-secondary {
    padding: 10px 20px;
    font-size: 0.9rem;
  }

  .seguimiento-card {
    padding: 18px;
  }

  .seguimiento-header {
    flex-direction: row;
    align-items: center;
  }
}

/* Mobile Large (481px - 768px) */
@media (max-width: 768px) and (min-width: 481px) {
  .seguimientos-header {
    flex-direction: column;
    gap: 15px;
    align-items: stretch;
  }

  .seguimientos-header h3 {
    font-size: 1.2rem;
  }

  .form-row {
    grid-template-columns: 1fr;
    gap: 15px;
  }

  .form-actions {
    flex-direction: column;
    gap: 12px;
  }

  .btn-primary,
  .btn-secondary {
    width: 100%;
    padding: 12px 20px;
    font-size: 0.9rem;
  }

  .interest-selector {
    justify-content: center;
    flex-wrap: wrap;
  }

  .seguimiento-card {
    padding: 16px;
  }

  .seguimiento-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 10px;
  }

  .seguimiento-meta {
    flex-direction: column;
    align-items: flex-start;
    gap: 5px;
  }
}

/* Mobile Small (320px - 480px) */
@media (max-width: 480px) {
  .seguimientos-container {
    padding: 0;
  }

  .seguimientos-header {
    flex-direction: column;
    gap: 12px;
    align-items: stretch;
    margin-bottom: 20px;
    padding-bottom: 12px;
  }

  .seguimientos-header h3 {
    font-size: 1.1rem;
  }

  .seguimiento-form {
    padding: 20px;
    margin-bottom: 25px;
  }

  .seguimiento-form h4 {
    font-size: 1.1rem;
    margin-bottom: 15px;
  }

  .form-row {
    grid-template-columns: 1fr;
    gap: 12px;
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
    min-height: 70px;
  }

  .form-actions {
    flex-direction: column;
    gap: 10px;
    margin-top: 15px;
  }

  .btn-primary,
  .btn-secondary {
    width: 100%;
    padding: 12px 16px;
    font-size: 0.9rem;
    border-radius: 6px;
  }

  .seguimiento-card {
    padding: 15px;
    margin-bottom: 12px;
  }

  .seguimiento-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 8px;
    margin-bottom: 12px;
  }

  .seguimiento-tipo {
    font-size: 0.9rem;
  }

  .seguimiento-meta {
    flex-direction: column;
    align-items: flex-start;
    gap: 4px;
  }

  .seguimiento-fecha {
    font-size: 0.8rem;
  }

  .seguimiento-agente {
    font-size: 0.75rem;
    padding: 2px 6px;
  }

  .descripcion {
    font-size: 0.9rem;
    line-height: 1.4;
  }

  .resultado,
  .proxima-accion {
    font-size: 0.85rem;
  }

  .proxima-accion-fecha {
    padding: 6px 10px;
    flex-direction: column;
    align-items: flex-start;
    gap: 4px;
  }

  .fecha-label {
    font-size: 0.8rem;
  }

  .fecha-valor {
    font-size: 0.85rem;
  }

  .tipo-programado {
    font-size: 0.75rem;
  }

  .interest-update {
    padding: 15px;
  }

  .interest-update h4 {
    font-size: 1rem;
    margin-bottom: 12px;
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
  .seguimientos-header h3 {
    font-size: 1rem;
  }

  .seguimiento-form {
    padding: 15px;
  }

  .seguimiento-form h4 {
    font-size: 1rem;
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
  .btn-secondary {
    padding: 10px 14px;
    font-size: 0.85rem;
  }

  .seguimiento-card {
    padding: 12px;
  }

  .seguimiento-tipo {
    font-size: 0.85rem;
  }

  .seguimiento-fecha {
    font-size: 0.75rem;
  }

  .seguimiento-agente {
    font-size: 0.7rem;
  }

  .descripcion {
    font-size: 0.85rem;
  }

  .resultado,
  .proxima-accion {
    font-size: 0.8rem;
  }

  .interest-btn {
    padding: 5px 7px;
    font-size: 0.85rem;
  }
}
</style>
