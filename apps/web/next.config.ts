import * as nextEnvModule from "@next/env";
import type { NextConfig } from "next";
import createNextIntlPlugin from "next-intl/plugin";
import { existsSync } from "node:fs";
import { resolve } from "node:path";

// The monorepo keeps one .env at the repo root; Next.js only reads apps/web/.env*.
// Load the root file too, so `next dev` works from any folder. Variables that are already
// set (Vercel project settings, CI, a shell that sourced .env) are never overridden.
// @next/env is CommonJS: Next compiles this file to CJS (named export works) while native ESM
// loaders only expose it on `default`. Support both.
type NextEnv = typeof import("@next/env");
const nextEnv: NextEnv = "loadEnvConfig" in nextEnvModule ? nextEnvModule : (nextEnvModule as unknown as { default: NextEnv }).default;
const repoRoot = resolve(process.cwd(), "../..");
if (existsSync(resolve(repoRoot, ".env"))) {
  // forceReload: Next has already loaded (and cached) apps/web/.env* before this file runs.
  nextEnv.loadEnvConfig(repoRoot, process.env.NODE_ENV !== "production", undefined, true);
}

const withNextIntl = createNextIntlPlugin("./src/i18n/request.ts");

// Next collects NEXT_PUBLIC_* for the browser bundle before this file runs, so values loaded
// above must be passed explicitly to be inlined into client code.
const publicEnv = Object.fromEntries(
  Object.entries(process.env).filter((e): e is [string, string] => e[0].startsWith("NEXT_PUBLIC_") && e[1] !== undefined),
);

const nextConfig: NextConfig = {
  env: publicEnv,
  serverExternalPackages: ["firebase-admin", "bullmq", "ioredis"],
};

export default withNextIntl(nextConfig);
