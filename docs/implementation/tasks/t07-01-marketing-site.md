# T07-01 — Marketing site (Swahili-first, fast, separate deploy)

## Status

- `done`
- Last updated: 2026-09-25

## Linked Phase

- Phase: `docs/implementation/phases/phase-07-hardening-pilot.md`
- Feature-inventory subfeature(s): none (new design `docs/design/features/marketing-site.md`)

## Agent Context

- Skills: none required
- Design docs: `docs/design/features/marketing-site.md`, `docs/design/features/plans-and-billing.md`, `docs/research/marketing-sites.md`
- Constraints: Astro static output + Tailwind (ADR 0003); no client JavaScript; Swahili default, English at `/en/`; prices from the plans design; contact numbers only from configuration; no fake trust signals; commits follow `.agents/skills/git-commit/SKILL.md` (no AI attribution)
- Do not touch: `docs/design/` (except this feature's doc), `.agents/workflows/`, other tasks' in-scope paths

## Session Budget

- Mode: `interactive`
- Stop when: all acceptance criteria pass
- Handoff when: context becomes recap-heavy, or a behavior is missing from design (record it in `docs/changes/proposed/`)

## Objective

A fast public website in Swahili and English explains D-Card, shows plans and sample cards, and sends hosts to sign up.

## Scope Boundary

**In scope:**
- `apps/site/**`
- `pnpm-workspace.yaml` (if needed), root `README.md` (site section)

**Out of scope:**
- The web app (`apps/web`)
- Blog, CMS, analytics

## Acceptance Criteria

- [x] `apps/site` builds to static HTML with `pnpm --filter @dcard/site build`; `/` (sw) and `/en/` render hero, how it works, features, sample cards, plans (1,000 / 1,500 / 2,000 per card, minimum Tsh 50,000, 20% off the first event), FAQ and contact.
- [x] Built pages contain no `<script>` tags (zero client JavaScript) and pass an automated check in `apps/site/test`.
- [x] Lighthouse mobile: performance ≥ 95, accessibility ≥ 95 (local run recorded).
- [x] WhatsApp/phone buttons render only when `SITE_WHATSAPP` / `SITE_PHONE` are set; the call to action links to `SITE_APP_URL/signup`.
- [x] Each language has title/description, `hreflang` alternates, Open Graph image, `sitemap.xml` and `robots.txt`.

## Dependencies

- None.

## Implementation Checklist

- [x] Scaffold Astro + Tailwind in `apps/site`.
- [x] Copy (sw/en) and sections.
- [x] Sample card images from the D-Card renderer.
- [x] SEO files; build checks; Lighthouse.

## Verification

- Command: `pnpm --filter @dcard/site build && pnpm --filter @dcard/site test`
- Evidence:

- `apps/site`: Astro 7 static site + Tailwind 4 (ADR 0003), Swahili at `/`, English at `/en/`, 404, `sitemap.xml`, `robots.txt`, favicon, Open Graph image. Sections: hero (one call to action → `SITE_APP_URL/signup`), how it works, features, sample cards, plans (Msingi 1,000 · Kawaida 1,500 "most popular" · Premium 2,000 per card; minimum Tsh 50,000; 20% off the first event; blocks of 10; mobile money before sending), FAQ (native `<details>`), contact.
- Sample cards and the OG image are rendered by D-Card's own card renderer (`apps/web` next/og) with sample data, saved as 540 px JPEGs (~60 KB each).
- `apps/site/test/site.test.ts` (6; builds the site twice): no `.js` files and no `<script>` in any HTML; every section in sw and en; plan prices and rules present; sign-up link to the app; contact buttons hidden until configured and normalised to 255… when set (a local `0754…` number previously produced a broken `tel:` link — fixed); only theme-defined brand/gold colours used (an undefined `brand-800` made two pricing buttons unreadable — fixed); canonical, hreflang, OG, sitemap, robots.
- `astro-check` (Astro files): 0 errors (pnpm `packageExtensions` adds a runtime dependency `@astrojs/astro2tsx` forgot to declare).
- Lighthouse 12, mobile, local static preview: `/` and `/en/` → performance 100, accessibility 100, best practices 100, SEO 100; LCP 1.7 s, TBT 0 ms, CLS 0, 250 KB total.
- Visual check at 390 px: no horizontal scroll; hero, pricing buttons readable after the colour fix.
- `pnpm turbo run typecheck lint test build --force` → 27/27 (2026-09-25). Deploy steps in `docs/deployment.md` (separate Vercel project).
