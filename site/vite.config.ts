import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";
import tailwindcss from "@tailwindcss/vite";

// BASE_PATH : "/" avec un domaine personnalisé (www.primes-services.be),
// "/nom-du-repo/" si le site est servi sous https://<user>.github.io/<repo>/
const base = process.env.BASE_PATH ?? "/";

export default defineConfig({
  base,
  plugins: [react(), tailwindcss()],
  build: { target: "es2022", sourcemap: false },
});
