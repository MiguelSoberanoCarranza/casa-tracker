<template>
  <div>
    <!-- Loading de autenticación -->
    <div v-if="loading" class="loading-auth">
      <div>Verificando autenticación...</div>
    </div>

    <!-- Contenido principal -->
    <div v-else-if="isAuthenticated">
      <!-- Barra superior fija -->
      <nav class="top-bar">
        <div class="top-bar-content">
          <div class="logo-section">
            <h1>🏠 Casa Tracker</h1>
          </div>
          <div class="top-menu">
            <slot name="top-menu" />
            <div class="user-info">
              <span>{{ user?.email }}</span>
              <button @click="handleLogout" class="logout-btn">
                Cerrar Sesión
              </button>
            </div>
          </div>
        </div>
      </nav>

      <div class="container">
        <main class="main-content">
          <slot />
        </main>
      </div>
    </div>

    <!-- Redirigir a login si no está autenticado -->
    <div v-else>
      <div class="loading-auth">
        <div>Redirigiendo al login...</div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { useAuth } from '../lib/auth.js'

const { user, loading, isAuthenticated, logout } = useAuth()

const handleLogout = async () => {
  const result = await logout()
  if (result.success) {
    window.location.href = '/login'
  }
}
</script>

<style scoped>
.loading-auth {
  display: flex;
  align-items: center;
  justify-content: center;
  height: 100vh;
  color: white;
  font-size: 1.2rem;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.top-bar {
  height: 10vh;
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(20px);
  border-bottom: 1px solid rgba(102, 126, 234, 0.2);
  box-shadow: 0 2px 20px rgba(0, 0, 0, 0.1);
  flex-shrink: 0;
}

.top-bar-content {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 20px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  height: 100%;
  width: 100%;
}

.logo-section h1 {
  font-size: 1.8rem;
  font-weight: 700;
  background: linear-gradient(135deg, #667eea, #764ba2);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
  margin: 0;
}

.top-menu {
  display: flex;
  align-items: center;
  gap: 15px;
}

.user-info {
  display: flex;
  align-items: center;
  gap: 10px;
  color: #666;
  font-size: 0.9rem;
}

.logout-btn {
  background: #ff4757;
  color: white;
  border: none;
  padding: 8px 15px;
  border-radius: 8px;
  cursor: pointer;
  font-size: 0.9rem;
  font-weight: 500;
  transition: all 0.3s ease;
}

.logout-btn:hover {
  background: #ff3838;
  transform: translateY(-1px);
}

.container {
  flex: 1;
  padding: 20px;
  display: flex;
  flex-direction: column;
  gap: 20px;
  overflow: hidden;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  height: 90vh;
}

.main-content {
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(10px);
  border-radius: 20px;
  padding: 30px;
  box-shadow: 0 20px 40px rgba(0, 0, 0, 0.1);
  flex: 1;
  overflow-y: auto;
  display: flex;
  flex-direction: column;
  z-index: 1;
}

/* Tablet (768px - 1024px) */
@media (max-width: 1024px) and (min-width: 769px) {
  .top-bar {
    height: 10vh;
  }

  .container {
    padding: 15px;
    height: 90vh;
  }

  .top-bar-content {
    padding: 0 20px;
  }

  .logo-section h1 {
    font-size: 1.6rem;
  }

  .user-info {
    font-size: 0.85rem;
  }

  .logout-btn {
    padding: 6px 12px;
    font-size: 0.85rem;
  }

  .main-content {
    padding: 25px;
  }
}

/* Mobile Large (481px - 768px) */
@media (max-width: 768px) and (min-width: 481px) {
  .top-bar {
    height: 12vh;
  }

  .container {
    padding: 10px;
    height: 88vh;
  }

  .top-bar-content {
    padding: 0 15px;
    flex-direction: column;
    gap: 8px;
  }

  .logo-section h1 {
    font-size: 1.4rem;
  }

  .top-menu {
    width: 100%;
    justify-content: space-between;
    flex-wrap: wrap;
  }

  .user-info {
    font-size: 0.8rem;
    flex-direction: column;
    gap: 5px;
    align-items: flex-end;
  }

  .logout-btn {
    padding: 6px 12px;
    font-size: 0.8rem;
  }

  .main-content {
    padding: 15px;
  }
}

/* Mobile Small (320px - 480px) */
@media (max-width: 480px) {
  .top-bar {
    height: 14vh;
    min-height: 60px;
  }

  .container {
    padding: 8px;
    height: 86vh;
  }

  .top-bar-content {
    padding: 0 12px;
    flex-direction: column;
    gap: 6px;
    height: 100%;
    justify-content: center;
  }

  .logo-section h1 {
    font-size: 1.2rem;
    text-align: center;
  }

  .top-menu {
    width: 100%;
    justify-content: space-between;
    align-items: center;
  }

  .user-info {
    font-size: 0.75rem;
    flex-direction: column;
    gap: 4px;
    align-items: center;
    text-align: center;
  }

  .user-info span {
    word-break: break-all;
    max-width: 150px;
  }

  .logout-btn {
    padding: 6px 10px;
    font-size: 0.75rem;
    border-radius: 6px;
  }

  .main-content {
    padding: 12px;
    border-radius: 15px;
  }
}

/* Extra Small Mobile (max-width: 320px) */
@media (max-width: 320px) {
  .top-bar {
    height: 16vh;
    min-height: 65px;
  }

  .container {
    padding: 5px;
    height: 84vh;
  }

  .top-bar-content {
    padding: 0 10px;
    gap: 4px;
  }

  .logo-section h1 {
    font-size: 1.1rem;
  }

  .user-info {
    font-size: 0.7rem;
  }

  .user-info span {
    max-width: 120px;
  }

  .logout-btn {
    padding: 5px 8px;
    font-size: 0.7rem;
  }

  .main-content {
    padding: 10px;
    border-radius: 12px;
  }
}
</style>
