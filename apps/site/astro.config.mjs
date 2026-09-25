import tailwindcss from "@tailwindcss/vite";
import { defineConfig } from "astro/config";

// Static marketing site (docs/design/features/marketing-site.md). Zero client JavaScript.
export default defineConfig({
  site: process.env.SITE_URL ?? "http://localhost:4321",
  output: "static",
  trailingSlash: "always",
  build: { inlineStylesheets: "always" },
  vite: { plugins: [tailwindcss()] },
});
