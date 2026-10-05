import type { VercelConfig } from "@vercel/config/v1";

// Vercel project settings for apps/site (Root Directory = apps/site).
// Git pushes deploy it; see docs/deployment.md#marketing-site-appssite.
export const config: VercelConfig = {
  framework: "astro",
  installCommand: "pnpm install --frozen-lockfile",
  buildCommand: "cd ../.. && pnpm turbo run build --filter=@dcard/site...",
  outputDirectory: "dist",
};
