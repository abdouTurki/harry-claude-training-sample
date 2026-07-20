import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";

// L'URL de l'API est injectée au build via VITE_API_URL (voir docker-compose).
export default defineConfig({
  plugins: [react()],
  server: { host: true, port: 5173 },
});
