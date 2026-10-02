# UI Design System

Approved by the owner on 2026-09-28, from the clickable prototype: https://claude.ai/artifact/VPpuUGour1sRuU2sgD6ZhD. The research behind it is in `docs/research/ui-reference-projects.md`.

## Context

- The user experience is the product's main marketing. Screens must feel human-made from start to finish, calm, trustworthy and Swahili-first.
- The design applies to three surfaces: the D-Card mobile app (host and guest), D-Card Door, and the web app (dashboard, card page, admin).

## Requirements

- **One design language** across all apps: purple and white, a bento grid layout, Playfair Display, Hugeicons, and light and dark themes.
- **Tokens first.** Colours, type, spacing and radius live in token files: `dcard_ui` for Flutter, `globals.css` `@theme` for web. Screens never hard-code hex values.
- **Every async surface has four states:** loading, empty, no results and error (with retry).
- **Accessibility:**
  - body text contrast of at least 4.5:1;
  - touch targets of at least 44 px;
  - real buttons, links and labels;
  - screen-reader labels on icon-only controls;
  - colour is never the only signal.

## Decisions

### Colour roles (light / dark)

| Role | Light | Dark | Use |
|---|---|---|---|
| `bg` | `#FFFFFF` | `#110D16` | Page background |
| `tile` | `#F5F1FA` | `#1B1522` | Default bento tile, filled inputs, list avatars |
| `tile2` | `#EDE5F6` | `#241C2E` | Secondary tile, progress track |
| `soft` / `onSoft` | `#E4D7F2` / `#3E1C5E` | `#3A2456` / `#EADCFB` | Highlight tile (one per group) |
| `hero` / `onHero` / `heroMuted` | `#5A2D82` / `#FFFFFF` / `#E4D7F2` | `#3A2456` / `#F3EFF8` / `#D9C8F0` | One hero tile per screen |
| `primary` / `onPrimary` | `#5A2D82` / `#FFFFFF` | `#C8ADEE` / `#2A1142` | Buttons, active states, progress |
| `ink` / `muted` | `#1A1523` / `#625A72` | `#F3EFF8` / `#B6AEC4` | Text |
| `line` | `#EEE9F4` | `#2A2233` | Faint dividers between list rows only |
| `success` bg / fg | `#E3F2E9` / `#1B6B43` | `#16301F` / `#8BDDB0` | Issued, paid, admitted |
| `warning` bg / fg | `#FBF0D9` / `#7A5000` | `#33280F` / `#F0C674` | Pending, partly paid, locked |
| `danger` bg / fg | `#FCE7E5` / `#A11F15` | `#3A1714` / `#F4A097` | Cancelled, not paid, refused |
| `nav` / `navFg` / `navAccent` | `#1A1024` / `#A396B6` / `#C8ADEE` | `#221A2C` / `#9C90AE` / `#D4BEF3` | Bottom navigation |

The theme follows the system setting by default, and users can override it in Account (Light, Dark or System).

### Typography

- **Playfair Display** (500–800) for:
  - screen titles and headings;
  - names;
  - big numbers (money, counts, card numbers);
  - tile headlines.
- **Plus Jakarta Sans** (400–700) for labels, captions, inputs, buttons and body text at 12–15 px, where a display serif is hard to read.
- Both fonts are bundled, so nothing is fetched at runtime (the door app works offline). On web they are self-hosted through `next/font`.
- Numbers use tabular figures where they line up in tables.

### Layout: bento grid

- Screens are built from tiles of different sizes:
  - a 2-column grid on phones;
  - 3 columns for action tiles;
  - 4 columns on web;
  - 10–12 px gaps.
- **Tile shape:**
  - 24 px corners (20 px for small action tiles, 28 px for hero or status tiles);
  - 16–22 px padding;
  - separated by tonal fills and space.
- **Borders and shadows:**
  - no outlined cards and no bright borders;
  - no decorative shadows or gradients;
  - the only exceptions are the floating bottom nav's soft shadow and spotlight.
- **One hero tile per screen**, in the `hero` colour, for the most important fact.
- **Lists are plain rows** with faint `line` dividers, not boxed cards.
- **Status** shows as pill badges with a coloured background and text; they are never outlined.

### Components (shared; one per pattern)

| Component | Flutter (`dcard_ui`) | Web (`components/ui`) |
|---|---|---|
| Tile (variants: tile, tile2, soft, hero; optional link) | `DcTile` | `Tile` |
| Stat tile (label, big Playfair number, note, optional progress) | `DcStatTile` | `StatTile` |
| Button (primary, tonal; loading; icon) | `DcButton` | `Button` |
| Filled input with label above | `DcField` | `Field` |
| Status badge (success, warning, danger, neutral) | `DcBadge` | `Badge` |
| Progress bar | `DcProgress` | `Progress` |
| Top bar (circular back button, Playfair title, optional action) | `DcTopBar` | page header |
| Spotlight bottom navigation | `DcSpotlightNavBar` | — (web uses side navigation) |
| Empty / no results / error states | `DcStateView` | `EmptyState` |
| Segmented control (door Scan / Number / Name) | `DcSegmented` | `Tabs` |

### Navigation

- **Mobile (host and guest):** a floating dark bar, 72 px high with 28 px corners, 16 px from the sides and 18 px from the bottom. It has five icon-only tabs: Home, My cards, New event, Notifications and Account.
  - The active tab has a lavender strip on the top edge, a spotlight cone and a glowing icon.
  - Every tab has a screen-reader label, and the active tab is marked as the current page.
- **Door app:** no bottom navigation. A header shows the event, gate and sync chip, with a segmented Scan / Number / Name control.
- **Web:** a side navigation panel on a `tile` background, with the active item as a primary pill. The content area uses a 4-column bento dashboard.

### Icons

- Hugeicons stroke-rounded only: `hugeicons` in Flutter, `@hugeicons/react` with `@hugeicons/core-free-icons` on web.
- No Material icons and no emoji.

### Utilities

- `flutter_pack` (the owner's package, pub.dev) was chosen for preferences and helpers. It cannot be added yet: its `package_info_plus ^9` needs `win32 ^5`, while the workspace's `flutter_secure_storage ^11` needs `win32 ^6`, so pub cannot resolve both. The theme setting uses `shared_preferences` (key `settings.theme_mode`) until `flutter_pack` supports `win32 ^6`.
- D-Card keeps its generated `dcard_api` client for API calls.
- The door app does not add `flutter_pack`. It uses encrypted `sqflite_sqlcipher`, and `flutter_pack` brings plain `sqflite`, which would conflict natively.

### Flows

The approved prototype defines the screens and their order:
- **Host:** Welcome → Sign in → Dashboard → New event → Plan & payment → Event → Guests → Add guests → Contributions → Messages → Team, plus the web dashboard.
- **Guest:** WhatsApp/SMS invitation → card page (no login) → gallery → attendance confirmation → optional sign-in → My cards → card.
- **Door:** Sign in → choose event → scan → card number (with lockout) → name search → result → walk-in request → approver → offline & sync → device revoked.

## Contracts

- **Flutter:**
  - `dcard_ui` exports `DcTheme.light()` and `DcTheme.dark()` (`ThemeData`), `DcColors` (a `ThemeExtension` with the roles above), `DcSpace`, `DcRadius`, `DcType`, and the components listed above.
  - Apps use `Theme.of(context).extension<DcColors>()`.
- **Web:**
  - CSS variables `--dc-*` for every role, switched by `prefers-color-scheme` and a `data-theme` attribute.
  - Tailwind colours `bg`, `tile`, `tile2`, `soft`, `hero`, `primary`, `ink`, `muted`, `line`, `success`, `warning`, `danger`.
  - Font families `font-display` (Playfair) and `font-sans` (Jakarta).

## Acceptance Criteria

- Both Flutter apps and the web app use only the token roles; there are no hex literals in screens.
- Light and dark themes both render correctly on every screen.
- Every screen in the three approved flows matches the prototype's layout, typeface and navigation.
