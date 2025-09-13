import { defineConfig } from 'astro/config';
import vue from '@astrojs/vue';
import vercel from '@astrojs/vercel';

export default defineConfig({
  integrations: [vue()],
  output: 'server',
  adapter: vercel()
});
