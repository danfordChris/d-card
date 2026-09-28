# UI reference projects (owner's earlier apps)

Checked 2026-09-26 (read-only code review). Reference only; the adopted direction lives in `docs/design/ui/design-system.md` until accepted.

The owner named three projects to learn from. Colours may change; patterns, structure and UX should carry over.

| Project | Path | Stack | Use for |
|---|---|---|---|
| Notify Africa (SMS gateway) | `/Users/danfordchris/projects/starterpacks/myProjects/flutter_setup/notify` | Flutter, Provider + `ipf_flutter_starter_pack`, go_router | **Primary mobile reference** (D-Card app, D-Card Door) |
| Solomon Stockbrokers app | `/Users/danfordchris/projects/ipf_apps/solomon-stockbrokers-app` | Flutter, Provider + starter pack, go_router, flex_color_scheme, smooth_sheets | Trust and money flows (review → confirm → receipt), data density |
| Solomon Stockbrokers web | `/Users/danfordchris/projects/ipf_apps/solomon-stockbrokers-web` | React Router v7 (Remix-style) + Vite, Tailwind v4, Radix | Web admin shell, list/table, forms, folder conventions (patterns only — not Next.js) |

## Notify Africa (mobile)

- **Structure:** `lib/core/{constants,extensions,resources,router,theme,utils}`, `lib/features/<feature>/{screens,widgets,providers,services,models,enums,data}`, `lib/shared/{widgets,providers,utils}`, `lib/services/` (API, session, env, localisation). Services are static classes with a private `_Endpoints`, `raiseOnError()`, `fromJson`; errors go through one `SessionManager.handleError` → haptic → toast.
- **Theme:** tokens in `core/theme/app_colors.dart`, `app_spacing.dart` (spacing 2–64, radius 12/16/24/32/100/999), `app_text_theme.dart`. Font **Plus Jakarta Sans** (local TTFs, weights 200–800). Type scale: headlineSmall 24/32 w700, titleLarge 20/28 w700, titleSmall 16/24 w700, body 16/14/12, labels 14/12/10 w600. Buttons pill (radius 100, min height 48, elevation 0); inputs white, radius 12–16, 2 px border, primary on focus, label above.
- **Icons:** `hugeicons` stroke-rounded, sizes 24 nav/header, 20 search/stats, 18 settings rows, 14 pills; icon disc motif (tinted circle 36/40/48/56–72 px).
- **Shell:** `AppLayoutShell` — dark brand frame, light content panel with only the bottom corners rounded (32), dark bottom nav/footer merged into the frame. Custom bottom nav, 5 tabs via `StatefulShellRoute.indexedStack` (tap active tab → back to its root).
- **Search:** `AppSearchField` under the page title with an in-field filter icon (dot when active), debounce ~400 ms, **server-side** `q`; filter sheet (`AppSelectionSheet`: grey sheet, uppercase section labels, white groups, Clear/Apply) and removable active-filter chips.
- **Dashboard:** greeting header (time of day, avatar, bell with badge) → horizontal stats cards (bleed off the right edge to hint scrolling) → quick actions → overview cards (title left, "View all" right) → recent list rows (icon disc, bold name, neutral subtitle, status pill). Skeletons = real widgets with realistic fake data (`skeletonizer`).
- **Lists/forms:** list "Body" widget with `RefreshIndicator`, infinite scroll (load more at ~200 px from end), empty state (icon disc, title, one line, CTA); create via floating pill button; forms = label-above fields with 16 px gaps and a Cancel/Save row; success toast then pop; `SuccessScreen` with "what happens next".
- **Settings:** profile card, uppercase grouped sections in white radius-16 groups, rows with 36 px icon tile + label + optional subtitle + chevron; language screen with flag rows; logout in its own red row with confirm; version footer.
- **Worth keeping:** haptics layer (`shared/utils/haptic_utils.dart`), microcopy (greeting, confirmations naming the item), bottom sheets (`AppBottomsheet`), toasts bottom-centre (`toastification`, 3 s).
- **Do not copy:** mixed icon sets (hugeicons + Material + Solar), ~360 hard-coded colours outside the theme, missing `fontFamily` in `ThemeData` (buttons fall back to the system font), stock `AlertDialog`s, non-animated grey "shimmers", screen-percentage tile sizes, duplicated private badge/empty widgets, green glows and gradient hero cards (conflict with the no-gradient rule).

## Solomon Stockbrokers (mobile)

- Same architecture family as Notify (provider → static service `_Endpoints` → `raiseOnError` → model; `AppRoute` enum; indexed-stack shell; `ModalSheetPage` for profile/notifications).
- **Strong patterns:** money/transaction flow — form with a live fee breakdown (`TripleRail` label/value rows, bold total) → review → confirm (swipe up to submit) → `replace` to a receipt with a reference; balance hidden by default with an eye toggle; "Secure payment" shield; right-aligned fixed-width numeric column; chip rows instead of tab bars; low/avg/high stat strip; one currency formatter (`AppFormatter.formatCurrency` → `TZS 1,234`); PIN (`pinput`) + biometrics; `easy_scroll_pagination`; `flutter_slidable` row actions; skeletons from real tiles.
- **Depth without elevation:** 2 px surface border + one 2-blur hairline shadow on cards/inputs; radius scale 12/16/20/24/30.
- **Do not copy:** glass-on-photo headers, gradient button rings, blur nav bar (conflict with the no-gradient/no-decoration rule); Solar as the main icon set; providers holding widgets; empty logout/inactivity hooks; no tests.

## Solomon Stockbrokers (web / admin)

- **Folder conventions:** feature folders with co-located `*-list-item.tsx`, `*-loading.tsx`, `resources/{schemas,utils}.ts`, `new/` (create modal), `$id/` (detail slide-over) and per-feature `*-tabs.ts` config with permission gates. Zod schemas are the source of truth; status enums map to `{ label, value, variant }` for badges.
- **Admin shell:** tinted frame around one white rounded canvas; 260 px sidebar (collapsible to 80) with grouped pill navigation and icon chips; icon-only top-right actions; folder-style section tabs; ⌘K / ⌘, / sidebar shortcuts; pending-navigation pulse.
- **List pattern:** `TableSection` (search + filter menu + removable active-filter chips from URL params) + compound `createTable<T>()` (URL-driven sort, sticky uppercase header, zebra rows) + row-shaped skeleton + empty state that distinguishes "no data" from "no results" + pagination (max 4 pages with ellipsis).
- **Forms/detail:** Zod + react-hook-form, fields declared as data and rendered by one `RenderFormField` in a two-column grid inside a route modal; details in a route slide-over with a fixed-width label column; promise-based `confirm()`; per-action hooks with their own pending flag; toast after mutation.
- **Tokens:** Tailwind v4 `@theme` roles (surface, surface-container, outline, container, status triplets) — good structure; borders over shadows.
- **Do not copy:** React Router loaders/actions and the internal `r3-utils`; gradient buttons, gradient modal headers, 3D art, `hover:scale`; Arial; three icon sets; two chart libraries; **list filters that never reach the API**; inputs that show a red ring without the error text; hard-coded English; fixed non-responsive grids.
