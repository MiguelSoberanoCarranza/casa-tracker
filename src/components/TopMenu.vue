<template>
  <div class="top-menu-content">
    <div class="top-tabs">
      <button 
        v-for="tab in tabs" 
        :key="tab.id"
        @click="handleTabClick(tab.id)"
        :class="['top-tab-button', { active: activeTab === tab.id }]"
      >
        <span class="tab-icon">{{ tab.icon }}</span>
        <span class="tab-text">{{ tab.name }}</span>
      </button>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'

const activeTab = ref('prospectos')

const tabs = [
  { id: 'prospectos', name: 'Prospectos', icon: '👤' },
  { id: 'nuevo', name: 'Nuevo', icon: '✨' },
  { id: 'seguimientos', name: 'Seguimientos', icon: '📋' },
  { id: 'recordatorios', name: 'Recordatorios', icon: '📅' }
]

const handleTabClick = (tabId) => {
  activeTab.value = tabId
  // Emitir evento personalizado para el Dashboard
  window.dispatchEvent(new CustomEvent('tab-change', {
    detail: { tabId }
  }))
}
</script>

<style scoped>
.top-menu-content {
  display: flex;
  align-items: center;
  width: 100%;
  justify-content: flex-end;
}

.top-tabs {
  display: flex;
  gap: 3px;
  background: rgba(102, 126, 234, 0.15);
  padding: 4px;
  border-radius: 20px;
  backdrop-filter: blur(10px);
  border: 1px solid rgba(102, 126, 234, 0.2);
}

.top-tab-button {
  background: transparent;
  border: none;
  padding: 8px 14px;
  border-radius: 16px;
  cursor: pointer;
  font-weight: 500;
  transition: all 0.3s ease;
  color: #666;
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 0.8rem;
  white-space: nowrap;
  min-height: 32px;
}

.top-tab-button:hover {
  background: rgba(102, 126, 234, 0.25);
  color: #667eea;
  transform: translateY(-1px);
}

.top-tab-button.active {
  background: linear-gradient(135deg, #667eea, #764ba2);
  color: white;
  box-shadow: 0 2px 8px rgba(102, 126, 234, 0.4);
  transform: translateY(-1px);
}

.top-tab-button .tab-icon {
  font-size: 0.85rem;
}

.top-tab-button .tab-text {
  font-size: 0.75rem;
  font-weight: 600;
}

@media (max-width: 768px) {
  .top-tabs {
    flex-wrap: wrap;
    gap: 2px;
    padding: 3px;
    justify-content: center;
  }
  
  .top-tab-button {
    padding: 6px 10px;
    font-size: 0.7rem;
    min-height: 28px;
  }
  
  .top-tab-button .tab-text {
    font-size: 0.65rem;
  }
  
  .top-tab-button .tab-icon {
    font-size: 0.75rem;
  }
}
</style>
