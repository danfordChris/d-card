import { DUMMY_PREFIX, ENV_GROUPS, type ProviderGroup } from "./schema.js";

export type Env = Record<string, string | undefined>;

export type GroupReport = {
  group: ProviderGroup;
  missing: string[];
  invalid: string[];
  dummy: string[];
  /** All required keys present with real (non-dummy, valid) values. */
  configured: boolean;
};

export type EnvReport = {
  ok: boolean;
  groups: GroupReport[];
};

export const isDummy = (value: string | undefined): boolean =>
  value !== undefined && value.startsWith(DUMMY_PREFIX);

/** Validates env values: required keys present, non-dummy values match their format. */
export function checkEnv(env: Env): EnvReport {
  const groups = ENV_GROUPS.map((group): GroupReport => {
    const missing: string[] = [];
    const invalid: string[] = [];
    const dummy: string[] = [];
    for (const spec of group.keys) {
      const value = env[spec.key];
      if (value === undefined || value === "") {
        if (spec.required) missing.push(spec.key);
        continue;
      }
      if (isDummy(value)) {
        dummy.push(spec.key);
        continue;
      }
      if (spec.pattern && !spec.pattern.test(value)) {
        invalid.push(spec.key);
      }
    }
    const configured = missing.length === 0 && invalid.length === 0 && dummy.length === 0;
    return { group, missing, invalid, dummy, configured };
  });
  return { ok: groups.every((g) => g.missing.length === 0 && g.invalid.length === 0), groups };
}

/** Returns the named group's values, throwing if any required key is missing, invalid or dummy. */
export function requireProvider(env: Env, groupId: string): Record<string, string> {
  const report = checkEnv(env).groups.find((g) => g.group.id === groupId);
  if (!report) {
    throw new Error(`Unknown env group: ${groupId}`);
  }
  if (!report.configured) {
    const problems = [
      ...report.missing.map((k) => `${k} (missing)`),
      ...report.invalid.map((k) => `${k} (invalid format)`),
      ...report.dummy.map((k) => `${k} (dummy value)`),
    ];
    throw new Error(
      `${report.group.name} is not configured: ${problems.join(", ")}.\nGet values from: ${report.group.source}`,
    );
  }
  return Object.fromEntries(report.group.keys.map((k) => [k.key, env[k.key] ?? ""]));
}

export function formatReport(report: EnvReport): string {
  const lines: string[] = [];
  for (const g of report.groups) {
    const status = g.missing.length || g.invalid.length ? "ERROR" : g.configured ? "ready" : "dummy values";
    lines.push(`${g.configured ? "✓" : g.missing.length || g.invalid.length ? "✗" : "•"} ${g.group.name}: ${status}`);
    for (const k of g.missing) lines.push(`    missing: ${k}`);
    for (const k of g.invalid) lines.push(`    invalid format: ${k}`);
    for (const k of g.dummy) lines.push(`    dummy: ${k}`);
  }
  lines.push(report.ok ? "env:check ok" : "env:check failed");
  return lines.join("\n");
}

/** Returns the given keys, throwing if any is missing or still a dummy value. */
export function requireKeys(env: Env, keys: string[]): Record<string, string> {
  const bad = keys.filter((k) => !env[k] || isDummy(env[k]));
  if (bad.length > 0) {
    throw new Error(`Set real values in .env for: ${bad.join(", ")}`);
  }
  return Object.fromEntries(keys.map((k) => [k, env[k] as string]));
}
