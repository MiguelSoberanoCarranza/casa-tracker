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
        <ProspectoForm :prospecto="selectedProspecto" @saved="handleProspectoSaved"
          @cancel="showAddForm = false; selectedProspecto = null" />
      </div>

      <!-- Seguimientos -->
      <div v-if="activeTab === 'seguimientos'" class="seguimientos-section">
        <div class="section-header">
          <h2>Seguimientos</h2>
          <div class="seguimientos-filters">
            <select v-model="seguimientosFilter" class="filter-select">
              <option value="">Todos los prospectos</option>
              <option value="con_seguimientos">Con seguimientos</option>
              <option value="sin_seguimientos">Sin seguimientos</option>
              <option value="recientes">Seguimientos recientes</option>
            </select>
          </div>
        </div>

        <!-- Lista de prospectos con sus seguimientos -->
        <div class="prospectos-seguimientos">
          <div v-for="prospecto in filteredProspectosForSeguimientos" :key="prospecto.id"
            class="prospecto-seguimientos-card">
            <div class="prospecto-header">
              <div class="prospecto-info">
                <h3>{{ prospecto.nombre }} {{ prospecto.apellido }}</h3>
                <div class="prospecto-meta">
                  <span v-if="prospecto.email">📧 {{ prospecto.email }}</span>
                  <span v-if="prospecto.telefono">📱 {{ prospecto.telefono }}</span>
                  <span :class="['status-badge', prospecto.status]">
                    {{ getStatusLabel(prospecto.status) }}
                  </span>
                </div>
              </div>
              <div class="prospecto-actions">
                <button @click="selectProspecto(prospecto)" class="btn-secondary btn-sm">
                  Ver Detalles
                </button>
                <button @click="toggleSeguimientos(prospecto.id)" class="btn-primary btn-sm">
                  {{ expandedSeguimientos.includes(prospecto.id) ? 'Ocultar' : 'Ver' }} Seguimientos
                </button>
              </div>
            </div>

            <!-- Seguimientos del prospecto -->
            <div v-if="expandedSeguimientos.includes(prospecto.id)" class="seguimientos-content">
              <SeguimientosList :prospecto="prospecto" @updated="loadProspectos" />
            </div>
          </div>

          <div v-if="filteredProspectosForSeguimientos.length === 0" class="no-seguimientos">
            <p>No hay prospectos para mostrar seguimientos</p>
          </div>
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
import { ref, computed, onMounted, onUnmounted } from 'vue'
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

// Filtro para prospectos en la sección de seguimientos
const filteredProspectosForSeguimientos = computed(() => {
  let filtered = prospectos.value

  if (seguimientosFilter.value === 'con_seguimientos') {
    // Filtrar solo prospectos que tengan seguimientos
    // Por ahora mostramos todos, pero esto se puede mejorar con una consulta específica
    filtered = filtered
  } else if (seguimientosFilter.value === 'sin_seguimientos') {
    // Filtrar solo prospectos sin seguimientos
    // Por ahora mostramos todos, pero esto se puede mejorar con una consulta específica
    filtered = filtered
  } else if (seguimientosFilter.value === 'recientes') {
    // Filtrar prospectos con seguimientos recientes
    // Por ahora mostramos todos, pero esto se puede mejorar con una consulta específica
    filtered = filtered
  }

  return filtered.sort((a, b) => new Date(b.fecha_actualizacion) - new Date(a.fecha_actualizacion))
})

// Tabs
const tabs = [
  { id: 'prospectos', name: 'Prospectos', icon: '👤' },
  { id: 'nuevo', name: 'Nuevo', icon: '✨' },
  { id: 'seguimientos', name: 'Seguimientos', icon: '📋' },
  { id: 'recordatorios', name: 'Recordatorios', icon: '📅' }
]

// Métodos
const loadProspectos = async () => {
  try {
    console.log('🔄 Iniciando carga de prospectos...')
    console.log('📡 Supabase client:', supabase)

    // Obtener el usuario actual
    const { data: { user }, error: userError } = await supabase.auth.getUser()

    if (userError) {
      console.error('❌ Error obteniendo usuario:', userError)
      throw userError
    }

    if (!user) {
      console.error('❌ No hay usuario autenticado')
      prospectos.value = []
      return
    }

    console.log('👤 Usuario actual:', user.id)

    // Filtrar prospectos por el agente actual
    const { data, error } = await supabase
      .from('prospectos')
      .select('*')
      .eq('agente_id', user.id)
      .order('fecha_actualizacion', { ascending: false })

    console.log('📊 Respuesta de Supabase:', { data, error })

    if (error) {
      console.error('❌ Error de Supabase:', error)
      throw error
    }

    console.log('✅ Prospectos cargados exitosamente:', data?.length || 0)

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

    console.log('🔍 Duplicados eliminados:', (data?.length || 0) - uniqueProspectos.length)
    prospectos.value = uniqueProspectos
  } catch (error) {
    console.error('💥 Error completo cargando prospectos:', error)
    console.error('📋 Stack trace:', error.stack)
    prospectos.value = []
  }
}

const selectProspecto = (prospecto) => {
  try {
    console.log('🎯 Seleccionando prospecto:', prospecto)
    selectedProspecto.value = prospecto
    activeTab.value = 'seguimientos'
    console.log('✅ Prospecto seleccionado y cambiando a pestaña seguimientos')
  } catch (error) {
    console.error('💥 Error seleccionando prospecto:', error)
  }
}

const handleProspectoSaved = () => {
  try {
    console.log('💾 Prospecto guardado, actualizando lista...')
    showAddForm.value = false
    selectedProspecto.value = null
    loadProspectos()
    console.log('✅ Lista actualizada después de guardar')
  } catch (error) {
    console.error('💥 Error manejando prospecto guardado:', error)
  }
}

const handleNewProspecto = () => {
  try {
    // Prevenir doble click
    if (showAddForm.value) {
      console.log('⚠️ Formulario ya abierto, ignorando doble click')
      return
    }

    console.log('✨ Botón Nuevo Prospecto clickeado')
    console.log('📊 Estado actual:', {
      showAddForm: showAddForm.value,
      activeTab: activeTab.value,
      selectedProspecto: selectedProspecto.value
    })

    showAddForm.value = true
    selectedProspecto.value = null
    activeTab.value = 'nuevo'

    console.log('✅ Formulario de nuevo prospecto abierto')

    // Verificar que el cambio se aplicó
    setTimeout(() => {
      console.log('🔍 Verificación después de 100ms:', {
        showAddForm: showAddForm.value,
        activeTab: activeTab.value
      })
    }, 100)
  } catch (error) {
    console.error('💥 Error manejando nuevo prospecto:', error)
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

// Escuchar eventos del TopMenu
onMounted(async () => {
  try {
    console.log('🚀 Dashboard montado, iniciando...')
    console.log('🔧 Variables de entorno:', {
      url: import.meta.env.PUBLIC_SUPABASE_URL,
      key: import.meta.env.PUBLIC_SUPABASE_ANON_KEY ? 'Configurado' : 'No configurado'
    })

    // Verificar si Vue está funcionando
    console.log('🎯 Vue está funcionando:', {
      showAddForm: showAddForm.value,
      activeTab: activeTab.value,
      prospectos: prospectos.value.length
    })

    // Verificar si Supabase está disponible
    console.log('🔍 Verificando Supabase client:', supabase)

    if (!supabase) {
      console.error('❌ Supabase client no está disponible')
      return
    }

    // Probar conexión básica
    try {
      const { data, error } = await supabase.auth.getSession()
      console.log('🔐 Sesión de autenticación:', { data, error })
    } catch (authError) {
      console.error('❌ Error verificando autenticación:', authError)
    }

    await loadProspectos()

    // Escuchar eventos de cambio de pestaña
    window.addEventListener('tab-change', (event) => {
      try {
        console.log('🔄 Cambio de pestaña recibido:', event.detail.tabId)
        handleTabChange(event.detail.tabId)
      } catch (error) {
        console.error('💥 Error manejando cambio de pestaña:', error)
      }
    })

    console.log('✅ Dashboard inicializado correctamente')

    // NOTA: Removido el event listener duplicado que podía causar múltiples ejecuciones
    // El botón ya tiene @click="handleNewProspecto" en el template de Vue
    console.log('✅ Dashboard inicializado sin event listeners duplicados')
  } catch (error) {
    console.error('💥 Error inicializando dashboard:', error)
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

/* Estilos para la sección de seguimientos */
.seguimientos-filters {
  display: flex;
  gap: 15px;
  align-items: center;
}

.prospectos-seguimientos {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.prospecto-seguimientos-card {
  background: white;
  border-radius: 15px;
  padding: 25px;
  box-shadow: 0 5px 20px rgba(0, 0, 0, 0.1);
  border: 2px solid transparent;
  transition: all 0.3s ease;
}

.prospecto-seguimientos-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.15);
  border-color: #667eea;
}

.prospecto-seguimientos-card .prospecto-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 15px;
  gap: 20px;
}

.prospecto-seguimientos-card .prospecto-info h3 {
  font-size: 1.3rem;
  color: #333;
  margin-bottom: 10px;
}

.prospecto-seguimientos-card .prospecto-meta {
  display: flex;
  flex-wrap: wrap;
  gap: 15px;
  align-items: center;
}

.prospecto-seguimientos-card .prospecto-meta span {
  color: #666;
  font-size: 0.9rem;
}

.prospecto-seguimientos-card .prospecto-actions {
  display: flex;
  gap: 10px;
  flex-shrink: 0;
}

.btn-sm {
  padding: 8px 16px;
  font-size: 0.85rem;
  border-radius: 8px;
}

.seguimientos-content {
  margin-top: 20px;
  padding-top: 20px;
  border-top: 1px solid #f0f0f0;
}

.no-seguimientos {
  text-align: center;
  padding: 40px 20px;
  color: #666;
  font-style: italic;
  background: #f8f9fa;
  border-radius: 10px;
  border: 2px dashed #e0e0e0;
}

@media (max-width: 768px) {
  .section-header {
    flex-direction: column;
    gap: 15px;
    align-items: stretch;
  }

  .filters {
    flex-direction: column;
  }

  .search-input,
  .filter-select {
    min-width: auto;
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
    justify-content: stretch;
  }

  .prospecto-seguimientos-card .prospecto-actions .btn-sm {
    flex: 1;
  }
}
</style>
