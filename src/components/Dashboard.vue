<template>
  <div class="dashboard">


    <!-- Contenido de las pestañas -->
    <div class="tab-content">
      <!-- Lista de Prospectos -->
      <div v-if="activeTab === 'prospectos'" class="prospectos-section">
        <div class="section-header">
          <h2>Lista de Prospectos</h2>
          <button @click="handleNewProspecto" :disabled="showAddForm" class="btn-primary" id="nuevo-prospecto-btn">
            <span class="btn-icon">✨</span>
            <span class="btn-text">
              {{ showAddForm ? 'Formulario Abierto' : 'Nuevo Prospecto' }}
            </span>
          </button>
        </div>

        <!-- Filtros -->
        <div class="filters">
          <input v-model="searchQuery" type="text" placeholder="Buscar prospectos..." class="search-input">
          <select v-model="statusFilter" class="filter-select">
            <option value="">Todos los estados</option>
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

        <!-- Lista de prospectos -->
        <div class="prospectos-list">
          <div v-for="prospecto in filteredProspectos" :key="prospecto.id" class="prospecto-card"
            @click="selectProspecto(prospecto)">
            <div class="prospecto-header">
              <h3>{{ prospecto.nombre }} {{ prospecto.apellido }}</h3>
              <span :class="['status-badge', prospecto.status]">
                {{ getStatusLabel(prospecto.status) }}
              </span>
            </div>
            <div class="prospecto-info">
              <p><strong>📧</strong> {{ prospecto.email || 'Sin email' }}</p>
              <p><strong>📱</strong> {{ prospecto.telefono || 'Sin teléfono' }}</p>
              <p><strong>🏠</strong> {{ prospecto.ciudad || 'Sin ubicación' }}</p>
              <p><strong>💰</strong> ${{ formatNumber(prospecto.presupuesto_max) || 'No especificado' }}</p>
            </div>
            <div class="prospecto-footer">
              <div class="interest-score">
                <span>Puntuación: </span>
                <div class="stars">
                  <span v-for="i in 4" :key="i" :class="['star', { filled: i <= prospecto.puntuacion_interes }]">
                    ⭐
                  </span>
                </div>
              </div>
              <span class="last-update">
                {{ formatDate(prospecto.fecha_actualizacion) }}
              </span>
            </div>
          </div>
        </div>
      </div>

      <!-- Formulario de Nuevo Prospecto -->
      <div v-if="activeTab === 'nuevo' || showAddForm" class="form-section">
        <h2>{{ selectedProspecto ? 'Editar Prospecto' : 'Nuevo Prospecto' }}</h2>
        <ProspectoForm :prospecto="selectedProspecto" @saved="handleProspectoSaved" @cancel="handleFormCancel" />
      </div>

      <!-- Seguimientos -->
      <div v-if="activeTab === 'seguimientos'" class="seguimientos-section">
        <div class="section-header">
          <h2>Seguimientos por Prioridad</h2>
          <div class="seguimientos-filters">
            <select v-model="seguimientosFilter" class="filter-select">
              <option value="">Todos los prospectos</option>
              <option value="alta_prioridad">Alta Prioridad (4 estrellas)</option>
              <option value="proxima_llamada">Próxima Llamada Hoy</option>
              <option value="atrasados">Atrasados</option>
              <option value="sin_seguimiento">Sin Seguimiento Reciente</option>
            </select>
            <button @click="toggleViewMode" class="btn-secondary btn-sm">
              {{ viewMode === 'cards' ? 'Vista Lista' : 'Vista Cards' }}
            </button>
          </div>
        </div>

        <!-- Vista de Cards Compactas -->
        <div v-if="viewMode === 'cards'" class="seguimientos-cards">
          <div v-for="prospecto in sortedProspectosForSeguimientos" :key="prospecto.id" class="seguimiento-card-compact"
            :class="{ 'high-priority': prospecto.puntuacion_interes >= 4, 'overdue': isOverdue(prospecto) }">

            <!-- Header del Card -->
            <div class="card-header">
              <div class="prospecto-info">
                <h3>{{ prospecto.nombre }} {{ prospecto.apellido }}</h3>
                <div class="priority-indicators">
                  <div class="stars">
                    <span v-for="i in 4" :key="i" :class="['star', { filled: i <= prospecto.puntuacion_interes }]">
                      ⭐
                    </span>
                  </div>
                  <span :class="['status-badge', prospecto.status]">
                    {{ getStatusLabel(prospecto.status) }}
                  </span>
                </div>
              </div>
              <div class="contact-info">
                <span v-if="prospecto.telefono" class="contact-item">📱 {{ prospecto.telefono }}</span>
                <span v-if="prospecto.email" class="contact-item">📧 {{ prospecto.email }}</span>
              </div>
            </div>

            <!-- Información de Seguimiento -->
            <div class="seguimiento-info">
              <div class="last-followup">
                <span class="label">Último seguimiento:</span>
                <span class="value">{{ getLastFollowupDate(prospecto) }}</span>
              </div>
              <div class="next-action" v-if="getNextAction(prospecto)">
                <span class="label">Próxima acción:</span>
                <span class="value" :class="{ 'overdue': isNextActionOverdue(prospecto) }">
                  {{ getNextAction(prospecto) }}
                </span>
              </div>
            </div>

            <!-- Acciones Rápidas -->
            <div class="quick-actions">
              <button @click="quickCall(prospecto)" class="btn-quick btn-call">
                📞 Llamar
              </button>
              <button @click="quickEmail(prospecto)" class="btn-quick btn-email">
                📧 Email
              </button>
              <button @click="addQuickFollowup(prospecto)" class="btn-quick btn-add">
                ➕ Seguimiento
              </button>
              <button @click="selectProspecto(prospecto)" class="btn-quick btn-details">
                👁️ Ver
              </button>
            </div>
          </div>

          <div v-if="sortedProspectosForSeguimientos.length === 0" class="no-seguimientos">
            <p>No hay prospectos para mostrar seguimientos</p>
          </div>
        </div>

        <!-- Vista de Lista Detallada -->
        <div v-else class="seguimientos-list">
          <div v-for="prospecto in sortedProspectosForSeguimientos" :key="prospecto.id" class="seguimiento-list-item"
            :class="{ 'high-priority': prospecto.puntuacion_interes >= 4, 'overdue': isOverdue(prospecto) }">

            <div class="list-item-content">
              <div class="prospecto-main">
                <div class="prospecto-name">
                  <h3>{{ prospecto.nombre }} {{ prospecto.apellido }}</h3>
                  <div class="stars">
                    <span v-for="i in 4" :key="i" :class="['star', { filled: i <= prospecto.puntuacion_interes }]">
                      ⭐
                    </span>
                  </div>
                </div>
                <div class="prospecto-details">
                  <span v-if="prospecto.telefono">📱 {{ prospecto.telefono }}</span>
                  <span v-if="prospecto.email">📧 {{ prospecto.email }}</span>
                  <span :class="['status-badge', prospecto.status]">
                    {{ getStatusLabel(prospecto.status) }}
                  </span>
                </div>
              </div>

              <div class="seguimiento-details">
                <div class="last-followup">
                  <span class="label">Último:</span>
                  <span class="value">{{ getLastFollowupDate(prospecto) }}</span>
                </div>
                <div class="next-action" v-if="getNextAction(prospecto)">
                  <span class="label">Próximo:</span>
                  <span class="value" :class="{ 'overdue': isNextActionOverdue(prospecto) }">
                    {{ getNextAction(prospecto) }}
                  </span>
                </div>
              </div>

              <div class="list-actions">
                <button @click="quickCall(prospecto)" class="btn-action btn-call" title="Llamar">
                  📞
                </button>
                <button @click="quickEmail(prospecto)" class="btn-action btn-email" title="Email">
                  📧
                </button>
                <button @click="addQuickFollowup(prospecto)" class="btn-action btn-add" title="Agregar Seguimiento">
                  ➕
                </button>
                <button @click="selectProspecto(prospecto)" class="btn-action btn-details" title="Ver Detalles">
                  👁️
                </button>
              </div>
            </div>
          </div>
        </div>

      </div>

      <!-- Detalles del Prospecto -->
      <div v-if="activeTab === 'detalles'" class="detalles-section">
        <div v-if="selectedProspecto" class="prospecto-detalle">
          <!-- Header del prospecto -->
          <div class="prospecto-detalle-header">
            <div class="prospecto-info-principal">
              <h2>{{ selectedProspecto.nombre }} {{ selectedProspecto.apellido }}</h2>
              <div class="prospecto-meta-principal">
                <div class="priority-indicators">
                  <div class="stars">
                    <span v-for="i in 4" :key="i"
                      :class="['star', { filled: i <= selectedProspecto.puntuacion_interes }]">
                      ⭐
                    </span>
                  </div>
                  <span :class="['status-badge', selectedProspecto.status]">
                    {{ getStatusLabel(selectedProspecto.status) }}
                  </span>
                </div>
                <div class="contact-info-principal">
                  <span v-if="selectedProspecto.telefono" class="contact-item">
                    📱 {{ selectedProspecto.telefono }}
                  </span>
                  <span v-if="selectedProspecto.email" class="contact-item">
                    📧 {{ selectedProspecto.email }}
                  </span>
                </div>
              </div>
            </div>
            <div class="prospecto-actions-principal">
              <button @click="quickCall(selectedProspecto)" class="btn-action-principal btn-call">
                📞 Llamar
              </button>
              <button @click="quickEmail(selectedProspecto)" class="btn-action-principal btn-email">
                📧 Email
              </button>
              <button @click="editProspecto(selectedProspecto)" class="btn-action-principal btn-edit">
                ✏️ Editar
              </button>
              <button @click="goBackToProspectos" class="btn-action-principal btn-back">
                ← Volver
              </button>
            </div>
          </div>

          <!-- Información detallada -->
          <div class="prospecto-detalle-content">
            <div class="info-grid">
              <div class="info-card">
                <h3>Información Personal</h3>
                <div class="info-item">
                  <label>Nombre:</label>
                  <span>{{ selectedProspecto.nombre }} {{ selectedProspecto.apellido }}</span>
                </div>
                <div class="info-item">
                  <label>Teléfono:</label>
                  <span>{{ selectedProspecto.telefono || 'No disponible' }}</span>
                </div>
                <div class="info-item">
                  <label>Email:</label>
                  <span>{{ selectedProspecto.email || 'No disponible' }}</span>
                </div>
                <div class="info-item">
                  <label>Estado:</label>
                  <span :class="['status-badge', selectedProspecto.status]">
                    {{ getStatusLabel(selectedProspecto.status) }}
                  </span>
                </div>
              </div>

              <div class="info-card">
                <h3>Información de Seguimiento</h3>
                <div class="info-item">
                  <label>Último seguimiento:</label>
                  <span>{{ getLastFollowupDate(selectedProspecto) }}</span>
                </div>
                <div class="info-item" v-if="getNextAction(selectedProspecto)">
                  <label>Próxima acción:</label>
                  <span :class="{ 'overdue': isNextActionOverdue(selectedProspecto) }">
                    {{ getNextAction(selectedProspecto) }}
                  </span>
                </div>
                <div class="info-item" v-if="getNextActionDate(selectedProspecto)">
                  <label>Fecha próxima acción:</label>
                  <span :class="{ 'overdue': isNextActionOverdue(selectedProspecto) }">
                    {{ formatDate(getNextActionDate(selectedProspecto)) }}
                  </span>
                </div>
                <div class="info-item">
                  <label>Puntuación de interés:</label>
                  <div class="stars">
                    <span v-for="i in 4" :key="i"
                      :class="['star', { filled: i <= selectedProspecto.puntuacion_interes }]">
                      ⭐
                    </span>
                  </div>
                </div>
              </div>

              <div class="info-card">
                <h3>Información del Sistema</h3>
                <div class="info-item">
                  <label>Fecha de creación:</label>
                  <span>{{ formatDate(selectedProspecto.fecha_creacion) }}</span>
                </div>
                <div class="info-item">
                  <label>Última actualización:</label>
                  <span>{{ formatDate(selectedProspecto.fecha_actualizacion) }}</span>
                </div>
                <div class="info-item">
                  <label>ID del prospecto:</label>
                  <span class="id-text">{{ selectedProspecto.id }}</span>
                </div>
              </div>
            </div>

            <!-- Sección de Seguimientos -->
            <div class="seguimientos-section-detalle">
              <SeguimientosList :prospecto="selectedProspecto" @updated="loadProspectos" />
            </div>
          </div>
        </div>

        <div v-else class="no-prospecto-selected">
          <h3>No hay prospecto seleccionado</h3>
          <p>Selecciona un prospecto desde la lista para ver sus detalles.</p>
          <button @click="goBackToProspectos" class="btn-primary">
            Ver Lista de Prospectos
          </button>
        </div>
      </div>

      <!-- Recordatorios -->
      <div v-if="activeTab === 'recordatorios'" class="recordatorios-section">
        <Recordatorios />
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted, nextTick } from 'vue'
import { supabase } from '../lib/supabase.js'
import ProspectoForm from './ProspectoForm.vue'
import SeguimientosList from './SeguimientosList.vue'
import Recordatorios from './Recordatorios.vue'

// Estado reactivo
const prospectos = ref([])
const selectedProspecto = ref(null)
const activeTab = ref('prospectos')
const showAddForm = ref(false)
const searchQuery = ref('')
const statusFilter = ref('')
const seguimientosFilter = ref('')
const expandedSeguimientos = ref([])
const viewMode = ref('cards') // 'cards' o 'list'
const seguimientosData = ref({}) // Cache de datos de seguimientos

// Computed properties

const filteredProspectos = computed(() => {
  let filtered = prospectos.value

  if (searchQuery.value) {
    const query = searchQuery.value.toLowerCase()
    filtered = filtered.filter(p =>
      p.nombre.toLowerCase().includes(query) ||
      p.apellido.toLowerCase().includes(query) ||
      (p.email && p.email.toLowerCase().includes(query)) ||
      (p.telefono && p.telefono.includes(query))
    )
  }

  if (statusFilter.value) {
    filtered = filtered.filter(p => p.status === statusFilter.value)
  }

  return filtered.sort((a, b) => new Date(b.fecha_actualizacion) - new Date(a.fecha_actualizacion))
})

// Filtro y ordenamiento para prospectos en la sección de seguimientos
const sortedProspectosForSeguimientos = computed(() => {
  let filtered = prospectos.value

  // Aplicar filtros
  if (seguimientosFilter.value === 'alta_prioridad') {
    filtered = filtered.filter(p => p.puntuacion_interes >= 4)
  } else if (seguimientosFilter.value === 'proxima_llamada') {
    filtered = filtered.filter(p => isNextActionToday(p))
  } else if (seguimientosFilter.value === 'atrasados') {
    filtered = filtered.filter(p => isOverdue(p))
  } else if (seguimientosFilter.value === 'sin_seguimiento') {
    filtered = filtered.filter(p => !hasRecentFollowup(p))
  }

  // Ordenar por prioridad (estrellas) y luego por próxima acción
  return filtered.sort((a, b) => {
    // Primero por puntuación de interés (estrellas) - mayor primero
    if (b.puntuacion_interes !== a.puntuacion_interes) {
      return b.puntuacion_interes - a.puntuacion_interes
    }

    // Luego por si tiene próxima acción programada
    const aHasNext = getNextAction(a)
    const bHasNext = getNextAction(b)

    if (aHasNext && !bHasNext) return -1
    if (!aHasNext && bHasNext) return 1

    // Si ambos tienen próxima acción, ordenar por fecha
    if (aHasNext && bHasNext) {
      const aDate = getNextActionDate(a)
      const bDate = getNextActionDate(b)
      if (aDate && bDate) {
        return new Date(aDate) - new Date(bDate)
      }
    }

    // Finalmente por fecha de actualización
    return new Date(b.fecha_actualizacion) - new Date(a.fecha_actualizacion)
  })
})

// Tabs
const tabs = [
  { id: 'prospectos', name: 'Prospectos', icon: '👤' },
  { id: 'nuevo', name: 'Nuevo', icon: '✨' },
  { id: 'detalles', name: 'Detalles', icon: '👁️' },
  { id: 'recordatorios', name: 'Recordatorios', icon: '📅' }
]

// Métodos
const loadProspectos = async () => {
  try {

    // Obtener el usuario actual
    const { data: { user }, error: userError } = await supabase.auth.getUser()

    if (userError) {
      throw userError
    }

    if (!user) {
      prospectos.value = []
      return
    }


    // Filtrar prospectos por el agente actual
    const { data, error } = await supabase
      .from('prospectos')
      .select('*')
      .eq('agente_id', user.id)
      .order('fecha_actualizacion', { ascending: false })


    if (error) {
      throw error
    }


    // Eliminar duplicados en el frontend como medida de seguridad
    const uniqueProspectos = data ? data.filter((prospecto, index, self) =>
      index === self.findIndex(p =>
        p.id === prospecto.id ||
        (p.nombre === prospecto.nombre &&
          p.apellido === prospecto.apellido &&
          p.email === prospecto.email &&
          p.telefono === prospecto.telefono)
      )
    ) : []

    prospectos.value = uniqueProspectos
  } catch (error) {
    prospectos.value = []
  }
}

const selectProspecto = (prospecto) => {
  console.log('👁️ Seleccionando prospecto:', prospecto.nombre)
  try {
    selectedProspecto.value = prospecto
    activeTab.value = 'detalles'
    console.log('👁️ Estado actualizado:', { selectedProspecto: selectedProspecto.value, activeTab: activeTab.value })
  } catch (error) {
    console.error('Error seleccionando prospecto:', error)
  }
}

const handleProspectoSaved = () => {
  try {
    showAddForm.value = false
    selectedProspecto.value = null
    activeTab.value = 'prospectos' // Regresar a la vista de prospectos
    loadProspectos()
  } catch (error) {
    console.error('Error al guardar prospecto:', error)
  }
}

const handleFormCancel = () => {
  showAddForm.value = false
  selectedProspecto.value = null
  activeTab.value = 'prospectos' // Regresar a la vista de prospectos
}

const handleNewProspecto = () => {
  try {
    // Prevenir doble click
    if (showAddForm.value) {
      return
    }


    showAddForm.value = true
    selectedProspecto.value = null
    activeTab.value = 'nuevo'


  } catch (error) {
  }
}

// La función global se asignará en onMounted para evitar errores de SSR

const getStatusLabel = (status) => {
  const labels = {
    nuevo: 'Nuevo',
    contactado: 'Contactado',
    interesado: 'Interesado',
    calificado: 'Calificado',
    propuesta: 'Propuesta',
    negociacion: 'Negociación',
    vendido: 'Vendido',
    perdido: 'Perdido'
  }
  return labels[status] || status
}

const formatNumber = (num) => {
  if (!num) return '0'
  return new Intl.NumberFormat('es-MX').format(num)
}

const formatDate = (date) => {
  if (!date) return 'N/A'
  return new Date(date).toLocaleDateString('es-MX')
}

// Función para cambiar pestaña desde el TopMenu
const handleTabChange = (tabId) => {
  activeTab.value = tabId

  // Si se va a la pestaña 'nuevo', limpiar el formulario
  if (tabId === 'nuevo') {
    selectedProspecto.value = null
    showAddForm.value = true
  } else {
    // Si se va a otra pestaña, cerrar el formulario
    showAddForm.value = false
  }
}

// Función para alternar la visualización de seguimientos
const toggleSeguimientos = (prospectoId) => {
  const index = expandedSeguimientos.value.indexOf(prospectoId)
  if (index > -1) {
    expandedSeguimientos.value.splice(index, 1)
  } else {
    expandedSeguimientos.value.push(prospectoId)
  }
}

// Función para alternar modo de vista
const toggleViewMode = () => {
  viewMode.value = viewMode.value === 'cards' ? 'list' : 'cards'
}

// Función para obtener la fecha del último seguimiento
const getLastFollowupDate = (prospecto) => {
  const seguimientos = seguimientosData.value[prospecto.id] || []
  if (seguimientos.length === 0) return 'Sin seguimientos'

  const lastFollowup = seguimientos[0] // Ya están ordenados por fecha descendente
  return formatDate(lastFollowup.fecha_seguimiento)
}

// Función para obtener la próxima acción
const getNextAction = (prospecto) => {
  const seguimientos = seguimientosData.value[prospecto.id] || []
  const lastFollowup = seguimientos.find(s => s.proxima_accion)
  return lastFollowup ? lastFollowup.proxima_accion : null
}

// Función para obtener la fecha de la próxima acción
const getNextActionDate = (prospecto) => {
  const seguimientos = seguimientosData.value[prospecto.id] || []
  const lastFollowup = seguimientos.find(s => s.proxima_accion_fecha)
  return lastFollowup ? lastFollowup.proxima_accion_fecha : null
}

// Función para verificar si está atrasado
const isOverdue = (prospecto) => {
  const nextDate = getNextActionDate(prospecto)
  if (!nextDate) return false
  return new Date(nextDate) < new Date()
}

// Función para verificar si la próxima acción es hoy
const isNextActionToday = (prospecto) => {
  const nextDate = getNextActionDate(prospecto)
  if (!nextDate) return false
  const today = new Date().toDateString()
  const actionDate = new Date(nextDate).toDateString()
  return today === actionDate
}

// Función para verificar si la próxima acción está atrasada
const isNextActionOverdue = (prospecto) => {
  return isOverdue(prospecto)
}

// Función para verificar si tiene seguimiento reciente (últimos 7 días)
const hasRecentFollowup = (prospecto) => {
  const seguimientos = seguimientosData.value[prospecto.id] || []
  if (seguimientos.length === 0) return false

  const lastFollowup = seguimientos[0]
  const sevenDaysAgo = new Date()
  sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7)

  return new Date(lastFollowup.fecha_seguimiento) > sevenDaysAgo
}

// Acciones rápidas
const quickCall = (prospecto) => {
  console.log('📞 Llamando a:', prospecto.nombre, prospecto.telefono)
  if (prospecto.telefono) {
    // Limpiar el número de teléfono
    const cleanPhone = prospecto.telefono.replace(/\D/g, '')
    console.log('📞 Número limpio:', cleanPhone)
    window.open(`tel:${cleanPhone}`, '_self')
  } else {
    alert('No hay número de teléfono disponible')
  }
}

const quickEmail = (prospecto) => {
  console.log('📧 Enviando email a:', prospecto.nombre, prospecto.email)
  if (prospecto.email) {
    // Crear un enlace de email con asunto
    const subject = `Seguimiento - ${prospecto.nombre} ${prospecto.apellido}`
    const body = `Hola ${prospecto.nombre},\n\nEspero que te encuentres bien. Te contacto para dar seguimiento a nuestra conversación anterior.\n\nSaludos cordiales.`
    console.log('📧 Abriendo email con:', { subject, body })
    window.open(`mailto:${prospecto.email}?subject=${encodeURIComponent(subject)}&body=${encodeURIComponent(body)}`, '_self')
  } else {
    alert('No hay email disponible')
  }
}

const addQuickFollowup = (prospecto) => {
  console.log('➕ Agregando seguimiento para:', prospecto.nombre)
  selectedProspecto.value = prospecto
  activeTab.value = 'detalles'
  console.log('➕ Estado actualizado:', { selectedProspecto: selectedProspecto.value, activeTab: activeTab.value })
  // Forzar actualización de la vista
  nextTick(() => {
    // Scroll hacia la sección de seguimientos
    const seguimientosSection = document.querySelector('.seguimientos-section-detalle')
    if (seguimientosSection) {
      seguimientosSection.scrollIntoView({ behavior: 'smooth' })
    }
  })
}

// Función para editar prospecto
const editProspecto = (prospecto) => {
  console.log('✏️ Editando prospecto:', prospecto.nombre)
  selectedProspecto.value = prospecto
  activeTab.value = 'nuevo'
  showAddForm.value = true
  // Scroll hacia el formulario
  nextTick(() => {
    const formSection = document.querySelector('.form-section')
    if (formSection) {
      formSection.scrollIntoView({ behavior: 'smooth' })
    }
  })
}


// Función para volver a la lista de prospectos
const goBackToProspectos = () => {
  console.log('← Volviendo a la lista de prospectos')
  selectedProspecto.value = null
  activeTab.value = 'prospectos'
}

// Función para cargar datos de seguimientos
const loadSeguimientosData = async () => {
  try {
    const { data: { user } } = await supabase.auth.getUser()
    if (!user) return

    const { data, error } = await supabase
      .from('seguimientos')
      .select(`
        *,
        prospectos (
          id,
          nombre,
          apellido
        )
      `)
      .eq('agente_id', user.id)
      .order('fecha_seguimiento', { ascending: false })

    if (error) throw error

    // Agrupar seguimientos por prospecto
    const grouped = {}
    data?.forEach(seguimiento => {
      const prospectoId = seguimiento.prospecto_id
      if (!grouped[prospectoId]) {
        grouped[prospectoId] = []
      }
      grouped[prospectoId].push(seguimiento)
    })

    seguimientosData.value = grouped
  } catch (error) {
  }
}

// Escuchar eventos del TopMenu
onMounted(async () => {
  try {
    if (!supabase) {
      return
    }

    // Probar conexión básica
    try {
      const { data, error } = await supabase.auth.getSession()
    } catch (authError) {
    }

    await loadProspectos()
    await loadSeguimientosData()

    // Escuchar eventos de cambio de pestaña
    window.addEventListener('tab-change', (event) => {
      try {
        handleTabChange(event.detail.tabId)
      } catch (error) {
      }
    })

    // NOTA: Removido el event listener duplicado que podía causar múltiples ejecuciones
    // El botón ya tiene @click="handleNewProspecto" en el template de Vue
  } catch (error) {
  }
})

onUnmounted(() => {
  window.removeEventListener('tab-change', handleTabChange)
})
</script>

<style scoped>
.dashboard {
  width: 100%;
  height: 100%;
  display: flex;
  flex-direction: column;
  gap: 20px;
}



.tab-content {
  flex: 1;
  overflow-y: auto;
  min-height: 0;
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 25px;
}

.section-header h2 {
  font-size: 1.8rem;
  color: #333;
}

.btn-primary {
  background: linear-gradient(135deg, #667eea, #764ba2);
  color: white;
  border: none;
  padding: 12px 20px;
  border-radius: 10px;
  cursor: pointer;
  font-weight: 500;
  transition: all 0.3s ease;
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.3);
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 0.9rem;
}

.btn-primary:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(102, 126, 234, 0.4);
}

.btn-icon {
  font-size: 1rem;
}

.btn-text {
  font-weight: 600;
}

.filters {
  display: flex;
  gap: 15px;
  margin-bottom: 25px;
  flex-wrap: wrap;
}

.search-input,
.filter-select {
  padding: 12px 15px;
  border: 2px solid #e0e0e0;
  border-radius: 10px;
  font-size: 1rem;
  transition: border-color 0.3s ease;
  min-width: 200px;
}

.search-input:focus,
.filter-select:focus {
  outline: none;
  border-color: #667eea;
}

.prospectos-list {
  display: grid;
  gap: 20px;
}

.prospecto-card {
  background: white;
  border-radius: 15px;
  padding: 25px;
  box-shadow: 0 5px 20px rgba(0, 0, 0, 0.1);
  cursor: pointer;
  transition: all 0.3s ease;
  border: 2px solid transparent;
}

.prospecto-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 15px 40px rgba(0, 0, 0, 0.15);
  border-color: #667eea;
}

.prospecto-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 15px;
}

.prospecto-header h3 {
  font-size: 1.3rem;
  color: #333;
}

.status-badge {
  padding: 6px 12px;
  border-radius: 20px;
  font-size: 0.8rem;
  font-weight: 500;
  text-transform: uppercase;
}

.status-badge.nuevo {
  background: #e3f2fd;
  color: #1976d2;
}

.status-badge.contactado {
  background: #fff3e0;
  color: #f57c00;
}

.status-badge.interesado {
  background: #e8f5e8;
  color: #388e3c;
}

.status-badge.calificado {
  background: #f3e5f5;
  color: #7b1fa2;
}

.status-badge.propuesta {
  background: #fff8e1;
  color: #fbc02d;
}

.status-badge.negociacion {
  background: #e1f5fe;
  color: #0288d1;
}

.status-badge.vendido {
  background: #e8f5e8;
  color: #2e7d32;
}

.status-badge.perdido {
  background: #ffebee;
  color: #d32f2f;
}

.prospecto-info {
  margin-bottom: 15px;
}

.prospecto-info p {
  margin-bottom: 8px;
  color: #666;
  font-size: 0.95rem;
}

.prospecto-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding-top: 15px;
  border-top: 1px solid #f0f0f0;
}

.interest-score {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 0.9rem;
  color: #666;
}

.stars {
  display: flex;
  gap: 2px;
}

.star {
  font-size: 1rem;
  opacity: 0.3;
  transition: opacity 0.3s ease;
}

.star.filled {
  opacity: 1;
}

.last-update {
  font-size: 0.8rem;
  color: #999;
}

.no-selection {
  text-align: center;
  padding: 60px 20px;
  color: #666;
  font-size: 1.1rem;
}

/* Estilos para la nueva sección de seguimientos */
.seguimientos-filters {
  display: flex;
  gap: 15px;
  align-items: center;
  flex-wrap: wrap;
}

/* Vista de Cards Compactas */
.seguimientos-cards {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
  gap: 20px;
}

.seguimiento-card-compact {
  background: white;
  border-radius: 12px;
  padding: 20px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  border: 2px solid transparent;
  transition: all 0.3s ease;
  position: relative;
}

.seguimiento-card-compact:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.15);
  border-color: #667eea;
}

.seguimiento-card-compact.high-priority {
  border-left: 4px solid #ff6b6b;
  background: linear-gradient(135deg, #fff5f5, #ffffff);
}

.seguimiento-card-compact.overdue {
  border-left: 4px solid #ffa726;
  background: linear-gradient(135deg, #fff8e1, #ffffff);
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 15px;
  gap: 15px;
}

.prospecto-info h3 {
  font-size: 1.2rem;
  color: #333;
  margin-bottom: 8px;
  font-weight: 600;
}

.priority-indicators {
  display: flex;
  align-items: center;
  gap: 10px;
  flex-wrap: wrap;
}

.stars {
  display: flex;
  gap: 2px;
}

.star {
  font-size: 0.9rem;
  opacity: 0.3;
  transition: opacity 0.3s ease;
}

.star.filled {
  opacity: 1;
}

.contact-info {
  display: flex;
  flex-direction: column;
  gap: 4px;
  align-items: flex-end;
}

.contact-item {
  color: #666;
  font-size: 0.85rem;
  white-space: nowrap;
}

.seguimiento-info {
  margin-bottom: 15px;
  padding: 12px;
  background: #f8f9fa;
  border-radius: 8px;
  border-left: 3px solid #667eea;
}

.seguimiento-info .label {
  font-weight: 600;
  color: #555;
  font-size: 0.85rem;
  margin-right: 8px;
}

.seguimiento-info .value {
  color: #333;
  font-size: 0.9rem;
}

.seguimiento-info .value.overdue {
  color: #ff6b6b;
  font-weight: 600;
}

.last-followup,
.next-action {
  margin-bottom: 6px;
}

.next-action {
  margin-bottom: 0;
}

.quick-actions {
  display: flex;
  gap: 8px;
  flex-wrap: wrap;
}

.btn-quick {
  padding: 8px 12px;
  border: none;
  border-radius: 6px;
  font-size: 0.8rem;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.3s ease;
  flex: 1;
  min-width: 70px;
}

.btn-quick.btn-call {
  background: #4caf50;
  color: white;
}

.btn-quick.btn-call:hover {
  background: #45a049;
  transform: translateY(-1px);
}

.btn-quick.btn-email {
  background: #2196f3;
  color: white;
}

.btn-quick.btn-email:hover {
  background: #1976d2;
  transform: translateY(-1px);
}

.btn-quick.btn-add {
  background: #ff9800;
  color: white;
}

.btn-quick.btn-add:hover {
  background: #f57c00;
  transform: translateY(-1px);
}

.btn-quick.btn-details {
  background: #9c27b0;
  color: white;
}

.btn-quick.btn-details:hover {
  background: #7b1fa2;
  transform: translateY(-1px);
}

/* Vista de Lista Detallada */
.seguimientos-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.seguimiento-list-item {
  background: white;
  border-radius: 10px;
  padding: 16px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  border: 2px solid transparent;
  transition: all 0.3s ease;
}

.seguimiento-list-item:hover {
  transform: translateY(-1px);
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.15);
  border-color: #667eea;
}

.seguimiento-list-item.high-priority {
  border-left: 4px solid #ff6b6b;
  background: linear-gradient(135deg, #fff5f5, #ffffff);
}

.seguimiento-list-item.overdue {
  border-left: 4px solid #ffa726;
  background: linear-gradient(135deg, #fff8e1, #ffffff);
}

.list-item-content {
  display: grid;
  grid-template-columns: 2fr 1fr auto;
  gap: 20px;
  align-items: center;
}

.prospecto-main {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.prospecto-name {
  display: flex;
  align-items: center;
  gap: 12px;
}

.prospecto-name h3 {
  font-size: 1.1rem;
  color: #333;
  margin: 0;
  font-weight: 600;
}

.prospecto-details {
  display: flex;
  gap: 15px;
  align-items: center;
  flex-wrap: wrap;
}

.prospecto-details span {
  color: #666;
  font-size: 0.85rem;
}

.seguimiento-details {
  display: flex;
  flex-direction: column;
  gap: 4px;
  font-size: 0.85rem;
}

.seguimiento-details .label {
  font-weight: 600;
  color: #555;
}

.seguimiento-details .value {
  color: #333;
}

.seguimiento-details .value.overdue {
  color: #ff6b6b;
  font-weight: 600;
}

.list-actions {
  display: flex;
  gap: 8px;
}

.btn-action {
  width: 36px;
  height: 36px;
  border: none;
  border-radius: 6px;
  font-size: 1rem;
  cursor: pointer;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  justify-content: center;
}

.btn-action.btn-call {
  background: #4caf50;
  color: white;
}

.btn-action.btn-email {
  background: #2196f3;
  color: white;
}

.btn-action.btn-add {
  background: #ff9800;
  color: white;
}

.btn-action.btn-details {
  background: #9c27b0;
  color: white;
}

.btn-action:hover {
  transform: scale(1.1);
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.2);
}

.no-seguimientos {
  text-align: center;
  padding: 40px 20px;
  color: #666;
  font-style: italic;
  background: #f8f9fa;
  border-radius: 10px;
  border: 2px dashed #e0e0e0;
  grid-column: 1 / -1;
}

/* Sección de Seguimientos Detallados */
.seguimientos-detallados {
  margin-top: 30px;
  background: white;
  border-radius: 15px;
  padding: 25px;
  box-shadow: 0 5px 20px rgba(0, 0, 0, 0.1);
  border: 2px solid #667eea;
}

.seguimientos-detallados .seguimientos-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
  padding-bottom: 15px;
  border-bottom: 2px solid #f0f0f0;
}

.seguimientos-detallados .seguimientos-header h3 {
  color: #333;
  font-size: 1.3rem;
  margin: 0;
}

/* Estilos para la vista de detalles del prospecto */
.detalles-section {
  padding: 20px;
}

.prospecto-detalle {
  background: white;
  border-radius: 15px;
  box-shadow: 0 5px 20px rgba(0, 0, 0, 0.1);
  overflow: hidden;
}

.prospecto-detalle-header {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 50%, #f093fb 100%);
  color: white;
  padding: 30px;
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 30px;
  position: relative;
  overflow: hidden;
}

.prospecto-detalle-header * {
  color: white !important;
}

.prospecto-detalle-header .btn-action-principal {
  color: white !important;
}

/* Estilos específicos para badges en el header */
.prospecto-detalle-header .status-badge {
  background: rgba(255, 255, 255, 0.2) !important;
  color: white !important;
  border: 1px solid rgba(255, 255, 255, 0.3) !important;
  backdrop-filter: blur(10px);
}

.prospecto-detalle-header::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: linear-gradient(135deg, rgba(255, 255, 255, 0.1) 0%, rgba(255, 255, 255, 0.05) 100%);
  pointer-events: none;
}

.prospecto-info-principal h2 {
  font-size: 2rem;
  margin: 0 0 15px 0;
  font-weight: 700;
  color: white;
}

.prospecto-meta-principal {
  display: flex;
  flex-direction: column;
  gap: 15px;
}

.priority-indicators {
  display: flex;
  align-items: center;
  gap: 15px;
  flex-wrap: wrap;
}

.stars {
  display: flex;
  gap: 3px;
}

.star {
  font-size: 1.2rem;
  opacity: 0.3;
  transition: all 0.3s ease;
  filter: grayscale(100%);
}

.star.filled {
  opacity: 1;
  filter: grayscale(0%);
  text-shadow: 0 0 8px rgba(255, 215, 0, 0.5);
}

.contact-info-principal {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.contact-item {
  font-size: 1.1rem;
  opacity: 0.9;
  color: white;
}

.prospecto-actions-principal {
  display: flex;
  gap: 12px;
  flex-wrap: wrap;
  align-items: flex-start;
}

.btn-action-principal {
  padding: 12px 20px;
  border: none;
  border-radius: 8px;
  font-size: 1rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  display: flex;
  align-items: center;
  gap: 8px;
}

.btn-action-principal.btn-call {
  background: linear-gradient(135deg, #4caf50, #45a049);
  color: white;
  box-shadow: 0 4px 15px rgba(76, 175, 80, 0.3);
}

.btn-action-principal.btn-email {
  background: linear-gradient(135deg, #2196f3, #1976d2);
  color: white;
  box-shadow: 0 4px 15px rgba(33, 150, 243, 0.3);
}

.btn-action-principal.btn-edit {
  background: linear-gradient(135deg, #ff9800, #f57c00);
  color: white;
  box-shadow: 0 4px 15px rgba(255, 152, 0, 0.3);
}

.btn-action-principal.btn-back {
  background: rgba(255, 255, 255, 0.15);
  color: white;
  border: 2px solid rgba(255, 255, 255, 0.4);
  backdrop-filter: blur(10px);
}

.btn-action-principal:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.2);
}

.prospecto-detalle-content {
  padding: 30px;
}

.info-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 25px;
  margin-bottom: 40px;
}

.info-card {
  background: linear-gradient(135deg, #ffffff 0%, #f8f9fa 100%);
  border-radius: 15px;
  padding: 25px;
  border-left: 4px solid #667eea;
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.08);
  transition: all 0.3s ease;
  position: relative;
  overflow: hidden;
}

.info-card::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 3px;
  background: linear-gradient(90deg, #667eea, #764ba2, #f093fb);
}

.info-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 12px 35px rgba(0, 0, 0, 0.12);
}

.info-card h3 {
  background: linear-gradient(135deg, #667eea, #764ba2);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
  font-size: 1.3rem;
  margin: 0 0 20px 0;
  font-weight: 700;
}

.info-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px 0;
  border-bottom: 1px solid #e0e0e0;
}

.info-item:last-child {
  border-bottom: none;
}

.info-item label {
  font-weight: 600;
  color: #667eea;
  min-width: 120px;
  font-size: 0.95rem;
}

.info-item span {
  color: #2c3e50;
  text-align: right;
  font-weight: 500;
}

.info-item span.overdue {
  color: #ff6b6b;
  font-weight: 600;
}

.id-text {
  font-family: monospace;
  font-size: 0.9rem;
  background: linear-gradient(135deg, #667eea, #764ba2);
  color: white;
  padding: 6px 12px;
  border-radius: 8px;
  font-weight: 600;
  box-shadow: 0 2px 8px rgba(102, 126, 234, 0.3);
}

.seguimientos-section-detalle {
  background: linear-gradient(135deg, #ffffff 0%, #f8f9fa 100%);
  border-radius: 15px;
  padding: 25px;
  border: 2px solid #e0e0e0;
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.08);
  position: relative;
  overflow: hidden;
}

.seguimientos-section-detalle::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 3px;
  background: linear-gradient(90deg, #667eea, #764ba2, #f093fb);
}

.no-prospecto-selected {
  text-align: center;
  padding: 60px 20px;
  background: linear-gradient(135deg, #ffffff 0%, #f8f9fa 100%);
  border-radius: 15px;
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.08);
  position: relative;
  overflow: hidden;
}

.no-prospecto-selected::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 3px;
  background: linear-gradient(90deg, #667eea, #764ba2, #f093fb);
}

.no-prospecto-selected h3 {
  background: linear-gradient(135deg, #667eea, #764ba2);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
  font-size: 1.5rem;
  margin: 0 0 15px 0;
  font-weight: 700;
}

.no-prospecto-selected p {
  color: #6c757d;
  font-size: 1.1rem;
  margin: 0 0 25px 0;
  font-weight: 500;
}

/* Tablet (768px - 1024px) */
@media (max-width: 1024px) and (min-width: 769px) {
  .section-header {
    flex-direction: column;
    gap: 20px;
    align-items: stretch;
  }

  .filters {
    flex-direction: row;
    flex-wrap: wrap;
    gap: 15px;
  }

  .search-input,
  .filter-select {
    min-width: 200px;
    flex: 1;
  }

  .prospecto-seguimientos-card .prospecto-header {
    flex-direction: row;
    align-items: flex-start;
    gap: 20px;
  }

  .prospecto-seguimientos-card .prospecto-actions {
    flex-direction: column;
    gap: 10px;
    min-width: 150px;
  }
}

/* Mobile Large (481px - 768px) */
@media (max-width: 768px) and (min-width: 481px) {
  .section-header {
    flex-direction: column;
    gap: 15px;
    align-items: stretch;
  }

  .filters {
    flex-direction: column;
    gap: 15px;
  }

  .search-input,
  .filter-select {
    min-width: auto;
    width: 100%;
  }

  .prospecto-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 10px;
  }

  .prospecto-footer {
    flex-direction: column;
    gap: 10px;
    align-items: flex-start;
  }

  .seguimientos-filters {
    flex-direction: column;
    align-items: stretch;
  }

  .prospecto-seguimientos-card .prospecto-header {
    flex-direction: column;
    align-items: stretch;
    gap: 15px;
  }

  .prospecto-seguimientos-card .prospecto-actions {
    flex-direction: row;
    justify-content: stretch;
    gap: 10px;
  }

  .prospecto-seguimientos-card .prospecto-actions .btn-sm {
    flex: 1;
  }

  .prospecto-meta {
    flex-direction: column;
    align-items: flex-start;
    gap: 8px;
  }
}

/* Mobile Small (320px - 480px) */
@media (max-width: 480px) {
  .section-header {
    flex-direction: column;
    gap: 15px;
    align-items: stretch;
  }

  .section-header h2 {
    font-size: 1.5rem;
  }

  .filters {
    flex-direction: column;
    gap: 12px;
  }

  .search-input,
  .filter-select {
    min-width: auto;
    width: 100%;
    padding: 10px 12px;
    font-size: 16px;
    /* Previene zoom en iOS */
  }

  .prospecto-card {
    padding: 20px;
    margin-bottom: 15px;
  }

  .prospecto-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 10px;
  }

  .prospecto-header h3 {
    font-size: 1.1rem;
  }

  .prospecto-footer {
    flex-direction: column;
    gap: 10px;
    align-items: flex-start;
  }

  .seguimientos-filters {
    flex-direction: column;
    align-items: stretch;
  }

  .prospecto-seguimientos-card {
    padding: 20px;
  }

  .prospecto-seguimientos-card .prospecto-header {
    flex-direction: column;
    align-items: stretch;
    gap: 15px;
  }

  .prospecto-seguimientos-card .prospecto-actions {
    flex-direction: column;
    justify-content: stretch;
    gap: 10px;
  }

  .prospecto-seguimientos-card .prospecto-actions .btn-sm {
    width: 100%;
    padding: 12px 16px;
    font-size: 0.9rem;
  }

  .prospecto-meta {
    flex-direction: column;
    align-items: flex-start;
    gap: 8px;
  }

  .prospecto-meta span {
    font-size: 0.85rem;
  }

  .btn-primary {
    padding: 12px 20px;
    font-size: 0.9rem;
  }

  .btn-secondary {
    padding: 12px 20px;
    font-size: 0.9rem;
  }
}

/* Extra Small Mobile (max-width: 320px) */
@media (max-width: 320px) {
  .section-header h2 {
    font-size: 1.3rem;
  }

  .prospecto-card {
    padding: 15px;
  }

  .prospecto-seguimientos-card {
    padding: 15px;
  }

  .btn-primary,
  .btn-secondary {
    padding: 10px 16px;
    font-size: 0.85rem;
  }

  .prospecto-header h3 {
    font-size: 1rem;
  }

  /* Responsive para vista de detalles */
  .prospecto-detalle-header {
    flex-direction: column;
    gap: 20px;
    align-items: stretch;
    padding: 20px;
  }

  .prospecto-info-principal h2 {
    font-size: 1.5rem;
  }

  .prospecto-actions-principal {
    justify-content: center;
    flex-wrap: wrap;
  }

  .btn-action-principal {
    padding: 10px 16px;
    font-size: 0.9rem;
  }

  .info-grid {
    grid-template-columns: 1fr;
    gap: 20px;
  }

  .info-card {
    padding: 20px;
  }

  .seguimientos-section-detalle {
    padding: 20px;
  }
}
</style>
