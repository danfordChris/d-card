import { scrub } from "./scrub.js";

// Structured JSON logs, one line per entry (Vercel and Railway index JSON fields). Scrubbed.

export type LogLevel = "debug" | "info" | "warn" | "error";
export type Logger = {
  (message: string, fields?: Record<string, unknown>): void;
  info(message: string, fields?: Record<string, unknown>): void;
  warn(message: string, fields?: Record<string, unknown>): void;
  error(message: string, fields?: Record<string, unknown>): void;
  child(fields: Record<string, unknown>): Logger;
};

export function createLogger(base: Record<string, unknown> = {}, write: (line: string) => void = (l) => console.log(l)): Logger {
  const emit = (level: LogLevel, message: string, fields: Record<string, unknown> = {}) => {
    const err = fields.err instanceof Error ? { err: { name: fields.err.name, message: fields.err.message, stack: fields.err.stack } } : {};
    write(JSON.stringify(scrub({ time: new Date().toISOString(), level, msg: message, ...base, ...fields, ...err })));
  };
  const log = ((message: string, fields?: Record<string, unknown>) => emit("info", message, fields)) as Logger;
  log.info = (m, f) => emit("info", m, f);
  log.warn = (m, f) => emit("warn", m, f);
  log.error = (m, f) => emit("error", m, f);
  log.child = (fields) => createLogger({ ...base, ...fields }, write);
  return log;
}
