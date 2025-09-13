<template>
  <div class="dashboard">
    <!-- Contenido de las pestañas -->
    <div class="tab-content">
      <!-- Lista de Prospectos -->
      <div v-if="activeTab === 'prospectos'" class="prospectos-section">
        <div class="section-header">
          <h2>Lista de Prospectos</h2>
          <button @click="showAddForm = true" class="btn-primary">
            <span class="btn-icon">✨</span>
            <span class="btn-text">Nuevo Prospecto</span>
          </button>
        </div>
        
        <!-- Filtros -->
        <div class="filters">
          <input 
            v-model="searchQuery" 
            type="text" 
            placeholder="Buscar prospectos..."
            class="search-input"
          >
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
          <div v-if="loading" class="loading-message">
            Cargando prospectos...
          </div>
          <div v-else-if="filteredProspectos.length === 0" class="empty-message">
            <p>No hay prospectos registrados</p>
            <button @click="showAddForm = true" class="btn-primary">
              <span class="btn-icon">✨</span>
              <span class="btn-text">Agregar Primer Prospecto</span>
            </button>
          </div>
          <div 
            v-else
            v-for="prospecto in filteredProspectos" 
            :key="prospecto.id"
            class="prospecto-card"
            @click="selectProspecto(prospecto)"
          >
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
        <ProspectoForm 
          :prospecto="selectedProspecto"
          @saved="handleProspectoSaved"
          @cancel="showAddForm = false; selectedProspecto = null"
        />
      </div>

      <!-- Seguimientos -->
      <div v-if="activeTab === 'seguimientos'" class="seguimientos-section">
        <h2>Seguimientos</h2>
        <div v-if="selectedProspecto">
          <SeguimientosList 
            :prospecto="selectedProspecto"
            @updated="loadProspectos"
          />
        </div>
        <div v-else class="no-selection">
          <p>Selecciona un prospecto para ver sus seguimientos</p>
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
import { ref, computed, onMounted } from 'vue'
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
const loading = ref(true)

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

// Métodos
const loadProspectos = async () => {
  try {
    loading.value = true
    const { data, error } = await supabase
      .from('prospectos')
      .select('*')
      .order('fecha_actualizacion', { ascending: false })
    
    if (error) {
      console.error('Error cargando prospectos:', error)
      // Si hay error, usar datos de ejemplo
      prospectos.value = []
    } else {
      prospectos.value = data || []
    }
  } catch (error) {
    console.error('Error cargando prospectos:', error)
    prospectos.value = []
  } finally {
    loading.value = false
  }
}

const selectProspecto = (prospecto) => {
  selectedProspecto.value = prospecto
  activeTab.value = 'seguimientos'
}

const handleProspectoSaved = () => {
  showAddForm.value = false
  selectedProspecto.value = null
  loadProspectos()
}

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

// Escuchar eventos del TopMenu
onMounted(() => {
  loadProspectos()
  
  // Escuchar eventos de cambio de pestaña
  window.addEventListener('tab-change', (event) => {
    handleTabChange(event.detail.tabId)
  })
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

.search-input, .filter-select {
  padding: 12px 15px;
  border: 2px solid #e0e0e0;
  border-radius: 10px;
  font-size: 1rem;
  transition: border-color 0.3s ease;
  min-width: 200px;
}

.search-input:focus, .filter-select:focus {
  outline: none;
  border-color: #667eea;
}

.prospectos-list {
  display: grid;
  gap: 20px;
}

.loading-message, .empty-message {
  text-align: center;
  padding: 60px 20px;
  color: #666;
  font-size: 1.1rem;
}

.empty-message p {
  margin-bottom: 20px;
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

.status-badge.nuevo { background: #e3f2fd; color: #1976d2; }
.status-badge.contactado { background: #fff3e0; color: #f57c00; }
.status-badge.interesado { background: #e8f5e8; color: #388e3c; }
.status-badge.calificado { background: #f3e5f5; color: #7b1fa2; }
.status-badge.propuesta { background: #fff8e1; color: #fbc02d; }
.status-badge.negociacion { background: #e1f5fe; color: #0288d1; }
.status-badge.vendido { background: #e8f5e8; color: #2e7d32; }
.status-badge.perdido { background: #ffebee; color: #d32f2f; }

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

@media (max-width: 768px) {
  .section-header {
    flex-direction: column;
    gap: 15px;
    align-items: stretch;
  }
  
  .filters {
    flex-direction: column;
  }
  
  .search-input, .filter-select {
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
}
</style>
