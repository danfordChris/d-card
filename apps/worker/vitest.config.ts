import { defineConfig } from "vitest/config";

export default defineConfig({
  test: {
    include: ["test/**/*.test.ts"],
    setupFiles: ["./test/setup-env.ts"],
    hookTimeout: 30_000,
    testTimeout: 15_000,
  },
});
