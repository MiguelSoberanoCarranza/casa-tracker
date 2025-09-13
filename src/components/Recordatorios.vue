<template>
  <div class="recordatorios-container">
    <div class="recordatorios-header">
      <h3>📅 Recordatorios Programados</h3>
      <div class="recordatorios-filters">
        <button v-for="filter in filters" :key="filter.id" @click="activeFilter = filter.id"
          :class="['filter-btn', { active: activeFilter === filter.id }]">
          {{ filter.icon }} {{ filter.name }}
        </button>
      </div>
    </div>

    <div class="recordatorios-list">
      <div v-if="loading" class="loading">
        <p>Cargando recordatorios...</p>
      </div>

      <div v-else-if="filteredRecordatorios.length === 0" class="no-recordatorios">
        <p>{{ getNoRecordatoriosMessage() }}</p>
      </div>

      <div v-else>
        <div v-for="recordatorio in filteredRecordatorios" :key="recordatorio.seguimiento_id" class="recordatorio-card"
          :class="getRecordatorioClass(recordatorio.proxima_accion_fecha)">
          <div class="recordatorio-header">
            <div class="prospecto-info">
              <h4>{{ recordatorio.prospecto_nombre }} {{ recordatorio.prospecto_apellido }}</h4>
              <p class="contacto">
                📧 {{ recordatorio.prospecto_email || 'Sin email' }} |
                📱 {{ recordatorio.prospecto_telefono || 'Sin teléfono' }}
              </p>
            </div>
            <div class="fecha-info">
              <div class="fecha-principal">
                {{ formatDateTime(recordatorio.proxima_accion_fecha) }}
              </div>
              <div class="dias-restantes">
                {{ getDiasRestantes(recordatorio.proxima_accion_fecha) }}
              </div>
            </div>
          </div>

          <div class="recordatorio-content">
            <div class="accion-info">
              <span class="tipo-icon">{{ getTipoIcon(recordatorio.proxima_accion_tipo) }}</span>
              <span class="tipo-text">{{ getTipoLabel(recordatorio.proxima_accion_tipo) }}</span>
            </div>
            <p class="descripcion">{{ recordatorio.proxima_accion }}</p>
            <div v-if="recordatorio.agente_nombre" class="agente-info">
              👤 {{ recordatorio.agente_nombre }}
            </div>
          </div>

          <div class="recordatorio-actions">
            <button @click="completarRecordatorio(recordatorio.seguimiento_id)" class="btn-completar">
              ✅ Completar
            </button>
            <button @click="editarRecordatorio(recordatorio)" class="btn-editar">
              ✏️ Editar
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { supabase } from '../lib/supabase.js'

const emit = defineEmits(['openSeguimiento'])

const recordatorios = ref([])
const loading = ref(false)
const activeFilter = ref('todos')

const filters = [
  { id: 'hoy', name: 'Hoy', icon: '📅' },
  { id: 'proximos', name: 'Próximos 7 días', icon: '📆' },
  { id: 'vencidos', name: 'Vencidos', icon: '⚠️' },
  { id: 'todos', name: 'Todos', icon: '📋' }
]

const filteredRecordatorios = computed(() => {
  const now = new Date()
  const today = new Date(now.getFullYear(), now.getMonth(), now.getDate())
  const nextWeek = new Date(today.getTime() + 7 * 24 * 60 * 60 * 1000)

  return recordatorios.value.filter(recordatorio => {
    const fecha = new Date(recordatorio.proxima_accion_fecha)

    switch (activeFilter.value) {
      case 'hoy':
        return fecha.toDateString() === today.toDateString()
      case 'proximos':
        return fecha >= today && fecha <= nextWeek
      case 'vencidos':
        return fecha < today
      case 'todos':
        return true
      default:
        return true
    }
  }).sort((a, b) => new Date(a.proxima_accion_fecha) - new Date(b.proxima_accion_fecha))
})

const loadRecordatorios = async () => {
  loading.value = true
  try {
    console.log('🔄 Cargando recordatorios...')

    // Cargar seguimientos que tienen próxima acción programada
    const { data, error } = await supabase
      .from('seguimientos')
      .select(`
        id,
        prospecto_id,
        proxima_accion_fecha,
        proxima_accion_tipo,
        proxima_accion,
        prospectos!inner (
          id,
          nombre,
          apellido,
          email,
          telefono
        )
      `)
      .not('proxima_accion_fecha', 'is', null)
      .order('proxima_accion_fecha', { ascending: true })

    if (error) {
      console.error('❌ Error cargando recordatorios:', error)
      throw error
    }

    console.log('✅ Recordatorios cargados:', data?.length || 0)

    // Transformar los datos para que coincidan con la estructura esperada
    recordatorios.value = (data || []).map(item => ({
      seguimiento_id: item.id,
      prospecto_id: item.prospecto_id,
      proxima_accion_fecha: item.proxima_accion_fecha,
      proxima_accion_tipo: item.proxima_accion_tipo,
      proxima_accion: item.proxima_accion,
      fecha_actualizacion: new Date().toISOString(), // Usamos fecha actual como fallback
      prospecto_nombre: item.prospectos?.nombre || '',
      prospecto_apellido: item.prospectos?.apellido || '',
      prospecto_email: item.prospectos?.email || '',
      prospecto_telefono: item.prospectos?.telefono || '',
      agente_nombre: 'Usuario Actual' // Por ahora usamos un valor por defecto
    }))

  } catch (error) {
    console.error('💥 Error cargando recordatorios:', error)
    recordatorios.value = []
  } finally {
    loading.value = false
  }
}

const completarRecordatorio = async (seguimientoId) => {
  try {
    console.log('🔄 Completando recordatorio:', seguimientoId)

    // Primero obtener la información del prospecto antes de actualizar
    const recordatorio = recordatorios.value.find(r => r.seguimiento_id === seguimientoId)
    if (!recordatorio) {
      console.error('❌ No se encontró el recordatorio')
      return
    }

    const { error } = await supabase
      .from('seguimientos')
      .update({
        proxima_accion_fecha: null,
        proxima_accion_tipo: null,
        proxima_accion: null
      })
      .eq('id', seguimientoId)

    if (error) {
      console.error('❌ Error completando recordatorio:', error)
      throw error
    }

    console.log('✅ Recordatorio completado')

    // Crear objeto prospecto para pasar al seguimiento
    const prospectoParaSeguimiento = {
      id: recordatorio.prospecto_id,
      nombre: recordatorio.prospecto_nombre,
      apellido: recordatorio.prospecto_apellido,
      email: recordatorio.prospecto_email,
      telefono: recordatorio.prospecto_telefono
    }

    // Emitir evento para abrir seguimiento
    emit('openSeguimiento', prospectoParaSeguimiento)

    // Recargar recordatorios
    await loadRecordatorios()
  } catch (error) {
    console.error('💥 Error completando recordatorio:', error)
    alert('Error al completar el recordatorio')
  }
}

const editarRecordatorio = (recordatorio) => {
  // Aquí podrías abrir un modal o navegar a editar
  console.log('Editar recordatorio:', recordatorio)
  alert('Función de edición en desarrollo')
}

const getRecordatorioClass = (fecha) => {
  const now = new Date()
  const recordatorioFecha = new Date(fecha)
  const diffTime = recordatorioFecha - now
  const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24))

  if (diffDays < 0) return 'vencido'
  if (diffDays === 0) return 'hoy'
  if (diffDays <= 3) return 'proximo'
  return 'normal'
}

const getDiasRestantes = (fecha) => {
  const now = new Date()
  const recordatorioFecha = new Date(fecha)
  const diffTime = recordatorioFecha - now
  const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24))

  if (diffDays < 0) return `${Math.abs(diffDays)} días vencido`
  if (diffDays === 0) return 'Hoy'
  if (diffDays === 1) return 'Mañana'
  return `En ${diffDays} días`
}

const getNoRecordatoriosMessage = () => {
  switch (activeFilter.value) {
    case 'hoy': return 'No hay recordatorios para hoy'
    case 'proximos': return 'No hay recordatorios en los próximos 7 días'
    case 'vencidos': return 'No hay recordatorios vencidos'
    case 'todos': return 'No hay recordatorios programados'
    default: return 'No hay recordatorios'
  }
}

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

onMounted(async () => {
  console.log('🚀 Recordatorios montado, iniciando...')
  await loadRecordatorios()
})
</script>

<style scoped>
.recordatorios-container {
  max-width: 100%;
}

.recordatorios-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 25px;
  flex-wrap: wrap;
  gap: 15px;
}

.recordatorios-header h3 {
  color: #333;
  font-size: 1.4rem;
  margin: 0;
}

.recordatorios-filters {
  display: flex;
  gap: 8px;
  flex-wrap: wrap;
}

.filter-btn {
  background: #f8f9fa;
  border: 2px solid #e0e0e0;
  padding: 8px 16px;
  border-radius: 20px;
  cursor: pointer;
  font-size: 0.85rem;
  font-weight: 500;
  transition: all 0.3s ease;
  color: #666;
}

.filter-btn:hover {
  background: #e9ecef;
  border-color: #d0d0d0;
}

.filter-btn.active {
  background: linear-gradient(135deg, #667eea, #764ba2);
  color: white;
  border-color: #667eea;
  box-shadow: 0 2px 8px rgba(102, 126, 234, 0.3);
}

.recordatorios-list {
  display: grid;
  gap: 15px;
}

.loading,
.no-recordatorios {
  text-align: center;
  padding: 40px 20px;
  color: #666;
  font-style: italic;
}

.recordatorio-card {
  background: white;
  border-radius: 12px;
  padding: 20px;
  box-shadow: 0 3px 10px rgba(0, 0, 0, 0.1);
  border-left: 4px solid #667eea;
  transition: all 0.3s ease;
}

.recordatorio-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(0, 0, 0, 0.15);
}

.recordatorio-card.vencido {
  border-left-color: #f44336;
  background: #ffebee;
}

.recordatorio-card.hoy {
  border-left-color: #ff9800;
  background: #fff3e0;
}

.recordatorio-card.proximo {
  border-left-color: #2196f3;
  background: #e3f2fd;
}

.recordatorio-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 15px;
  gap: 15px;
}

.prospecto-info h4 {
  margin: 0 0 5px 0;
  color: #333;
  font-size: 1.1rem;
}

.contacto {
  margin: 0;
  color: #666;
  font-size: 0.85rem;
}

.fecha-info {
  text-align: right;
  min-width: 120px;
}

.fecha-principal {
  font-weight: 600;
  color: #333;
  font-size: 0.9rem;
  margin-bottom: 4px;
}

.dias-restantes {
  font-size: 0.8rem;
  font-weight: 500;
  padding: 2px 8px;
  border-radius: 12px;
  background: rgba(102, 126, 234, 0.1);
  color: #667eea;
}

.recordatorio-card.vencido .dias-restantes {
  background: rgba(244, 67, 54, 0.1);
  color: #f44336;
}

.recordatorio-card.hoy .dias-restantes {
  background: rgba(255, 152, 0, 0.1);
  color: #ff9800;
}

.recordatorio-content {
  margin-bottom: 15px;
}

.accion-info {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 8px;
}

.tipo-icon {
  font-size: 1.1rem;
}

.tipo-text {
  font-weight: 500;
  color: #667eea;
  font-size: 0.9rem;
}

.descripcion {
  margin: 0 0 8px 0;
  color: #555;
  line-height: 1.4;
}

.agente-info {
  font-size: 0.8rem;
  color: #666;
  font-style: italic;
}

.recordatorio-actions {
  display: flex;
  gap: 10px;
  justify-content: flex-end;
}

.btn-completar,
.btn-editar {
  padding: 6px 12px;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  font-size: 0.8rem;
  font-weight: 500;
  transition: all 0.3s ease;
}

.btn-completar {
  background: #4caf50;
  color: white;
}

.btn-completar:hover {
  background: #45a049;
  transform: translateY(-1px);
}

.btn-editar {
  background: #f8f9fa;
  color: #666;
  border: 1px solid #e0e0e0;
}

.btn-editar:hover {
  background: #e9ecef;
  border-color: #d0d0d0;
}

@media (max-width: 768px) {
  .recordatorios-header {
    flex-direction: column;
    align-items: stretch;
  }

  .recordatorios-filters {
    justify-content: center;
  }

  .recordatorio-header {
    flex-direction: column;
    gap: 10px;
  }

  .fecha-info {
    text-align: left;
  }

  .recordatorio-actions {
    justify-content: center;
  }
}
</style>
