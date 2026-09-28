# D-Card UI Design System and Front-end Structure

## Status

proposed

## Context

- Owner direction (2026-09-26): user experience is the product's main marketing; screens must feel human-made end to end, reuse the patterns of the owner's earlier apps (colours may change), use Hugeicons everywhere, avoid decorative shadows and gradients, keep code reusable and cheap to run.
- Sourced review of the reference apps: `docs/research/ui-reference-projects.md` (Notify Africa mobile, Solomon Stockbrokers mobile and web).
- Today D-Card has no design system: system fonts, no icon package (two emoji lock markers in the web message settings), Tailwind defaults on web, basic Material widgets in `apps/mobile` and `apps/door`, shared Flutter widgets in `dart_packages/dcard_ui`.
- Not urgent: this is refinement work for later phases (backlog), not a blocker for phase 04/05 functionality.

## Problem

- Screens were built feature by feature without shared tokens or components, so they look generic and inconsistent.
- Without written rules, each new screen (and each assistant) makes its own visual choices.

## Proposed Change

### Principles

1. **Human-made, calm, trustworthy.** Flat surfaces, hairline borders, generous whitespace, one accent colour. No decorative gradients, glows, glassmorphism, 3D illustrations or `hover:scale`. Shadows only where they carry meaning (a floating action or an open sheet), one soft token, never stacked.
2. **Hugeicons only** — `hugeicons` (Flutter) and `@hugeicons/react` + `@hugeicons/core-free-icons` (web), stroke-rounded; no Material icons, emoji or other packs. Icon disc motif (tinted circle) for list rows, stats and empty states.
3. **One font family:** Plus Jakarta Sans (open licence; used by Notify) — `next/font` on web and the marketing site, bundled TTFs in `dcard_ui` with `ThemeData.fontFamily` set and every `TextTheme` slot defined (Notify's missing `fontFamily` bug avoided). Tabular figures for money and counts.
4. **Tokens first, colours swappable:** colour roles (primary, on-primary, surface, surface-container, outline, success/warning/danger/info with container variants), spacing (4-point: 4, 8, 12, 16, 20, 24, 32, 40, 48, 64), radius (12 inputs, 16 cards, 24 sheets, 999 pills), one type scale. No hex literals outside the token files (lint/CI check).
5. **Swahili-first copy** with en; no hard-coded strings; microcopy that names the thing ("Futa kadi ya Juma?"), time-of-day greeting, "what happens next" after success.
6. **Every async surface has four states:** loading (skeleton built from the real component), empty (icon disc, title, one line, action), no results (for search/filters), error (message + retry). Haptics on mobile for success/warning/error.

### Mobile (D-Card app, D-Card Door) — from Notify, trust flows from Solomon

- Keep D-Card's MVVM + repositories (tested); adopt Notify's **visual layer and component set** in `dart_packages/dcard_ui`: `AppButton` (variants, loading, Hugeicon), `InputField` family (label above, filled, focus border; phone, PIN via `pinput`, searchable dropdown sheet > 10 items), `AppSearchField` + filter sheet + active-filter chips, `AppCard`, `AppStatusBadge`, `AppDetailRows`, `AppBottomsheet`, confirm sheet (replaces stock `AlertDialog`), `AppAlert` toasts, `EmptyView`, `SuccessScreen`, `AppLayoutShell`, page header + circular back button, haptics util.
- Shell: indexed-stack bottom navigation (tap active tab → its root); dashboard order: greeting header → stat cards → quick actions → overview cards → recent list.
- Lists: server search with ~400 ms debounce, infinite scroll, pull to refresh, floating create button.
- Money flows (contributions, payments, plan checkout): Solomon's form with live breakdown → review → confirm → receipt with reference; one currency formatter (`TZS 1,234`); amounts hidden only where privacy matters (treasurer screens in public).
- Door app: large high-contrast result states (colour + icon + text), no decoration.

### Web (dashboard + admin) — structure from Solomon web, adapted to Next.js App Router

- Folders: `app/(app)/events/[id]/<feature>/` pages; `features/<feature>/{components,_lib}` with co-located `*-list-item.tsx`, `*-loading.tsx`, `schemas.ts`, `queries.ts`; shared `components/ui/*` (Button, Input family, Select, Badge, Card, Table, TableSection, Pagination, Modal, SlideOver, ConfirmProvider, Toast, EmptyState, Skeleton, Tabs).
- App shell: side navigation (grouped, collapsible) + one content canvas + icon-only top actions (matches the backlog "App navigation" request); section tabs from a config array with role gates.
- Lists: `TableSection` (search + filter menu + removable active-filter chips from the URL) + typed table with URL-driven sort and pagination; search/filter params **must reach the server query**; reset to page 1 on change; "no data" vs "no results" empty states.
- Forms: Zod schema shared with `@dcard/api-contract`, fields rendered from a typed config in a two-column grid, error text under every field, create/edit in a modal route, details in a slide-over; promise-based `confirm()`; toast after mutation.
- Admin area (`/admin`): same shell and list pattern; keyboard shortcuts (⌘K search, ⌘, settings).

### Architecture and cost guardrails (owner, 2026-09-26)

- Hosting stays cheap: web + API on Vercel (Hobby/Pro as needed), Neon and Upstash free tiers until usage requires more, one small worker host; record the monthly cost of any new service before adding it.
- Keep domain logic in `packages/core` modules per bounded context (events, guests, contributions, cards, messaging, check-in, confirmations, admin) with contracts in `@dcard/api-contract` and queue contracts in `@dcard/core/queues`; routes stay thin. Each context can later become its own service without rewriting clients.
- Reuse over duplication: one shared component per pattern (no per-feature copies of badges, empty states or dialogs).

## Open Questions (owner)

- Brand colours: keep the current D-Card purple (`brand-*`) or choose a new primary? (Tokens make either a small change.)
- Depend on the internal `ipf_flutter_starter_pack` (as Notify/Solomon do) or keep D-Card's own small helpers in `dcard_ui`? Recommendation: own helpers (no private git dependency in CI, MVVM already in place).
- Dark mode: not in MVP (neither reference app has a real one); confirm.
- Approve a clickable prototype (host app dashboard + event screen, web shell) before rolling the system out.

## Rollout (after acceptance)

1. Tokens, font and icons in `dcard_ui` and `apps/web` (`globals.css` `@theme`) + lint rule against hex literals/emoji icons.
2. Shared components (mobile and web) with widget/component tests.
3. Web app shell + side navigation; migrate event pages to `TableSection`/forms.
4. Mobile shell + dashboard; door app result screens.
5. Admin area on the same shell.
