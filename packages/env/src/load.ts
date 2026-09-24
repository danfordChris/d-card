import { existsSync } from "node:fs";
import { dirname, join } from "node:path";

/** Loads the nearest `.env` above `start` into process.env (existing variables win). Returns its path. */
export function loadDotEnv(start = process.cwd()): string | null {
  let dir = start;
  for (;;) {
    const candidate = join(dir, ".env");
    if (existsSync(candidate)) {
      process.loadEnvFile(candidate);
      return candidate;
    }
    const parent = dirname(dir);
    if (parent === dir) return null;
    dir = parent;
  }
}
