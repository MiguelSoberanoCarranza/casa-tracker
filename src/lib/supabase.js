import { createClient } from '@supabase/supabase-js'

const supabaseUrl = import.meta.env.PUBLIC_SUPABASE_URL
const supabaseKey = import.meta.env.PUBLIC_SUPABASE_ANON_KEY

export const supabase = createClient(supabaseUrl, supabaseKey)

// Tipos de datos para TypeScript (opcional)
export const ProspectStatus = {
  NUEVO: 'nuevo',
  CONTACTADO: 'contactado',
  INTERESADO: 'interesado',
  CALIFICADO: 'calificado',
  PROPUESTA: 'propuesta',
  NEGOCIACION: 'negociacion',
  VENDIDO: 'vendido',
  PERDIDO: 'perdido'
}

export const InterestLevel = {
  BAJO: 1,
  MEDIO: 2,
  ALTO: 3,
  MUY_ALTO: 4
}
