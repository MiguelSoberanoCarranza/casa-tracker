// Script de diagnóstico para el frontend
// Ejecutar en la consola del navegador para detectar problemas

console.log('🔍 INICIANDO DIAGNÓSTICO DE DUPLICADOS EN FRONTEND');

// 1. Verificar si hay múltiples event listeners en el botón
const btn = document.getElementById('nuevo-prospecto-btn');
if (btn) {
  console.log('✅ Botón encontrado:', btn);
  
  // Verificar si hay múltiples listeners (esto es difícil de detectar directamente)
  // Pero podemos verificar si el botón tiene atributos de Vue
  console.log('📋 Atributos del botón:', btn.attributes);
  
  // Simular click y ver si se ejecuta múltiples veces
  let clickCount = 0;
  const originalClick = btn.onclick;
  
  btn.onclick = function(e) {
    clickCount++;
    console.log(`🖱️ Click #${clickCount} detectado`);
    if (originalClick) originalClick.call(this, e);
  };
  
  console.log('🖱️ Haz click en el botón "Nuevo Prospecto" para ver si se ejecuta múltiples veces');
} else {
  console.log('❌ Botón no encontrado');
}

// 2. Verificar si hay múltiples instancias de Vue
console.log('🔍 Verificando instancias de Vue...');
const vueInstances = document.querySelectorAll('[data-v-]');
console.log(`📊 Elementos con data-v-: ${vueInstances.length}`);

// 3. Verificar si hay múltiples formularios
const forms = document.querySelectorAll('form');
console.log(`📋 Formularios encontrados: ${forms.length}`);
forms.forEach((form, index) => {
  console.log(`Formulario ${index + 1}:`, form);
});

// 4. Verificar event listeners globales
console.log('🔍 Event listeners globales:');
console.log('window.handleNewProspecto:', typeof window.handleNewProspecto);

// 5. Monitorear llamadas a Supabase
const originalFetch = window.fetch;
let supabaseCalls = 0;

window.fetch = function(...args) {
  if (args[0] && args[0].includes('supabase')) {
    supabaseCalls++;
    console.log(`📡 Llamada a Supabase #${supabaseCalls}:`, args[0]);
  }
  return originalFetch.apply(this, args);
};

console.log('📡 Monitoreando llamadas a Supabase...');

// 6. Verificar si hay múltiples componentes Dashboard montados
const dashboardElements = document.querySelectorAll('[class*="dashboard"]');
console.log(`🏠 Elementos dashboard encontrados: ${dashboardElements.length}`);

// 7. Función para limpiar event listeners duplicados
window.cleanupDuplicateListeners = function() {
  console.log('🧹 Limpiando event listeners duplicados...');
  
  // Remover todos los event listeners del botón
  if (btn) {
    const newBtn = btn.cloneNode(true);
    btn.parentNode.replaceChild(newBtn, btn);
    console.log('✅ Event listeners del botón limpiados');
  }
  
  // Remover listeners globales
  delete window.handleNewProspecto;
  console.log('✅ Listeners globales removidos');
};

console.log('✅ Diagnóstico completado. Usa window.cleanupDuplicateListeners() para limpiar listeners duplicados');
