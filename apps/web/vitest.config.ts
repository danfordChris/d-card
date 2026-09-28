import react from "@vitejs/plugin-react";
import { defineConfig } from "vitest/config";

export default defineConfig({
  plugins: [react()],
  test: {
    include: ["test/**/*.test.{ts,tsx}"],
    setupFiles: ["./test/setup-env.ts"],
    fileParallelism: false,
    hookTimeout: 30_000,
  },
});
