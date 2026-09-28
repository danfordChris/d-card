import type { VercelConfig } from "@vercel/config/v1";

// Vercel project settings for apps/web (Root Directory = apps/web).
// Deployments are driven by .github/workflows/deploy.yml — see docs/deployment.md.
export const config: VercelConfig = {
  framework: "nextjs",
  installCommand: "pnpm install --frozen-lockfile",
  // Build workspace dependencies (@dcard/db, core, api-contract) before Next.js.
  buildCommand: "cd ../.. && pnpm turbo run build --filter=@dcard/web...",
  // Cape Town: closest Vercel region to Tanzania (docs/design/architecture/codebase.md).
  regions: ["cpt1"],
};
