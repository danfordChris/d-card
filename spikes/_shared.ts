// Shared helpers for integration spikes. Spikes are manual, throwaway checks
// (task T00-10); they never run in CI. Results go to docs/research/spike-results.md.
import { loadDotEnv, requireKeys, requireProvider } from "../packages/env/src/index.js";

loadDotEnv();

export const env = process.env;
export { requireKeys, requireProvider };

export function log(step: string, data?: unknown): void {
  const time = new Date().toISOString();
  console.log(`[${time}] ${step}`);
  if (data !== undefined) console.log(JSON.stringify(data, null, 2));
}

/** Runs a spike and turns configuration errors into a readable message + exit code 1. */
export async function run(name: string, fn: () => Promise<void>): Promise<void> {
  try {
    log(`spike:${name} start`);
    await fn();
    log(`spike:${name} done`);
  } catch (err) {
    console.error(`spike:${name} failed: ${(err as Error).message}`);
    process.exitCode = 1;
  }
}

export async function postJson(url: string, body: unknown, headers: Record<string, string>): Promise<unknown> {
  const res = await fetch(url, {
    method: "POST",
    headers: { "content-type": "application/json", accept: "application/json", ...headers },
    body: JSON.stringify(body),
  });
  const text = await res.text();
  let parsed: unknown = text;
  try {
    parsed = JSON.parse(text);
  } catch {
    // keep raw text
  }
  if (!res.ok) throw new Error(`${res.status} ${res.statusText}: ${text}`);
  return parsed;
}
