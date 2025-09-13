<template>
  <div class="top-menu-content">
    <!-- Menú Desktop -->
    <div class="top-tabs desktop-menu">
      <button v-for="tab in tabs" :key="tab.id" @click="handleTabClick(tab.id)"
        :class="['top-tab-button', { active: activeTab === tab.id }]">
        <span class="tab-icon">{{ tab.icon }}</span>
        <span class="tab-text">{{ tab.name }}</span>
      </button>
    </div>

    <!-- Botón Hamburguesa Móvil -->
    <button class="mobile-menu-toggle" @click="toggleMobileMenu">
      <span class="hamburger-line"></span>
      <span class="hamburger-line"></span>
      <span class="hamburger-line"></span>
    </button>


  </div>

  <!-- Menú móvil y overlay fuera del contexto para evitar problemas de z-index -->
  <Teleport to="body">
    <div class="mobile-overlay" :class="{ active: mobileMenuOpen }" @click="closeMobileMenu"></div>
    <div class="mobile-menu" :class="{ active: mobileMenuOpen }">
      <button v-for="tab in tabs" :key="tab.id" @click="handleTabClick(tab.id)"
        :class="['mobile-tab-button', { active: activeTab === tab.id }]">
        <span class="tab-icon">{{ tab.icon }}</span>
        <span class="tab-text">{{ tab.name }}</span>
      </button>
    </div>
  </Teleport>
</template>

<script setup>
import { ref } from 'vue'

const activeTab = ref('prospectos')
const mobileMenuOpen = ref(false)

const tabs = [
  { id: 'prospectos', name: 'Prospectos', icon: '👤' },
  { id: 'nuevo', name: 'Nuevo', icon: '✨' },
  { id: 'recordatorios', name: 'Recordatorios', icon: '📅' }
]

const handleTabClick = (tabId) => {
  activeTab.value = tabId
  closeMobileMenu() // Cerrar menú móvil después de seleccionar
  // Emitir evento personalizado para el Dashboard
  window.dispatchEvent(new CustomEvent('tab-change', {
    detail: { tabId }
  }))
}

const toggleMobileMenu = () => {
  mobileMenuOpen.value = !mobileMenuOpen.value
}

const closeMobileMenu = () => {
  mobileMenuOpen.value = false
}
</script>

<style scoped>
.top-menu-content {
  display: flex;
  align-items: center;
  width: 100%;
  justify-content: start;
  position: relative;
  z-index: 1;
}

/* Menú Desktop */
.desktop-menu {
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

/* Botón Hamburguesa Móvil */
.mobile-menu-toggle {
  display: none;
  flex-direction: column;
  justify-content: space-around;
  width: 36px;
  height: 36px;
  background: linear-gradient(135deg, #667eea, #764ba2);
  border: none;
  border-radius: 8px;
  cursor: pointer;
  padding: 6px;
  transition: all 0.3s ease;
  box-shadow: 0 2px 8px rgba(102, 126, 234, 0.3);
}

.mobile-menu-toggle:hover {
  transform: scale(1.05);
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.4);
}

.mobile-menu-toggle:active {
  transform: scale(0.95);
}

.hamburger-line {
  width: 100%;
  height: 3px;
  background: white;
  border-radius: 2px;
  transition: all 0.3s ease;
}

/* Menú Móvil */
.mobile-menu {
  position: fixed !important;
  top: 60px;
  right: 15px;
  background: white;
  border-radius: 12px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.2);
  border: 1px solid rgba(102, 126, 234, 0.2);
  padding: 15px;
  z-index: 99999 !important;
  min-width: 220px;
  max-width: 280px;
  transform: translateY(-20px) scale(0.95);
  opacity: 0;
  visibility: hidden;
  transition: all 0.3s ease;
}

.mobile-menu.active {
  transform: translateY(0) scale(1);
  opacity: 1;
  visibility: visible;
  z-index: 99999 !important;
}

.mobile-tab-button {
  width: 100%;
  background: transparent;
  border: none;
  padding: 12px 16px;
  border-radius: 8px;
  cursor: pointer;
  font-weight: 500;
  transition: all 0.3s ease;
  color: #666;
  display: flex;
  align-items: center;
  gap: 10px;
  font-size: 0.9rem;
  margin-bottom: 4px;
  text-align: left;
}

.mobile-tab-button:hover {
  background: rgba(102, 126, 234, 0.1);
  color: #667eea;
}

.mobile-tab-button.active {
  background: linear-gradient(135deg, #667eea, #764ba2);
  color: white;
  box-shadow: 0 2px 8px rgba(102, 126, 234, 0.3);
}

.mobile-tab-button .tab-icon {
  font-size: 1rem;
}

.mobile-tab-button .tab-text {
  font-size: 0.85rem;
  font-weight: 600;
}

/* Overlay Móvil */
.mobile-overlay {
  display: none;
  position: fixed !important;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0, 0, 0, 0.3);
  z-index: 99998 !important;
  opacity: 0;
  transition: opacity 0.3s ease;
}

.mobile-overlay.active {
  display: block;
  opacity: 1;
}

/* Tablet (768px - 1024px) */
@media (max-width: 1024px) and (min-width: 769px) {
  .desktop-menu {
    display: flex;
    gap: 2px;
    padding: 3px;
  }

  .top-tab-button {
    padding: 6px 12px;
    font-size: 0.75rem;
    min-height: 28px;
  }

  .top-tab-button .tab-text {
    font-size: 0.7rem;
  }

  .mobile-menu-toggle {
    display: none;
  }
}

/* Mobile Large (481px - 768px) */
@media (max-width: 768px) and (min-width: 481px) {
  .desktop-menu {
    display: none !important;
  }

  .mobile-menu-toggle {
    display: flex !important;
    width: 40px;
    height: 40px;
  }

  .mobile-menu {
    top: 70px;
    right: 20px;
    min-width: 250px;
    max-width: 300px;
  }

  .mobile-tab-button {
    padding: 14px 18px;
    font-size: 0.95rem;
  }

  .mobile-overlay {
    display: none;
  }

  .mobile-overlay.active {
    display: block;
  }
}

/* Mobile Small (320px - 480px) */
@media (max-width: 480px) {
  .desktop-menu {
    display: none !important;
  }

  .mobile-menu-toggle {
    display: flex !important;
    width: 36px;
    height: 36px;
    padding: 5px;
  }

  .mobile-menu {
    top: 60px;
    right: 15px;
    left: 15px;
    min-width: auto;
    max-width: none;
    padding: 20px;
  }

  .mobile-tab-button {
    padding: 12px 16px;
    font-size: 0.9rem;
    margin-bottom: 6px;
  }

  .mobile-tab-button .tab-icon {
    font-size: 0.9rem;
  }

  .mobile-tab-button .tab-text {
    font-size: 0.8rem;
  }

  .mobile-overlay {
    display: none;
  }

  .mobile-overlay.active {
    display: block;
  }
}

/* Extra Small Mobile (max-width: 320px) */
@media (max-width: 320px) {
  .mobile-menu-toggle {
    width: 32px;
    height: 32px;
    padding: 4px;
  }

  .mobile-menu {
    top: 55px;
    right: 10px;
    left: 10px;
    padding: 15px;
  }

  .mobile-tab-button {
    padding: 10px 14px;
    font-size: 0.85rem;
    margin-bottom: 4px;
  }

  .mobile-tab-button .tab-icon {
    font-size: 0.85rem;
  }

  .mobile-tab-button .tab-text {
    font-size: 0.75rem;
  }
}
</style>
