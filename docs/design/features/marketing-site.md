# Marketing Site

## Context

- Public website that explains D-Card and sends hosts to sign up. Separate from the web app (owner decision 2026-09-25).
- Market: `docs/research/marketing-sites.md`. Plans: `docs/design/features/plans-and-billing.md`.

## Requirements

| ID | Requirement | Pri |
|----|-------------|-----|
| WEB-1 | **Swahili first** (`/`), English at `/en/`, language switch on every page. | M |
| WEB-2 | **Fast on phones:** static HTML, no JavaScript needed to read or navigate, system fonts, optimised images; Lighthouse performance ≥ 95 on mobile. | M |
| WEB-3 | Sections: hero with one call to action (create an event → web app sign-up), how it works (3 steps), features (WhatsApp + SMS cards, contributions with automatic cards, QR door check-in that works offline, RSVP), sample cards, plans and prices per guest card (Msingi 1,000 · Kawaida 1,500 · Premium 2,000, minimum Tsh 50,000 per event, 20% off the first event), FAQ, contact. | M |
| WEB-4 | Contact: WhatsApp and phone buttons from site configuration; hidden until the numbers are set (no invented numbers). | M |
| WEB-5 | Honest trust signals only: no fake counters or testimonials. | M |
| WEB-6 | Search and sharing: title/description per language, `hreflang`, Open Graph image, sitemap, robots. | M |
| WEB-7 | Accessible: semantic headings, contrast AA, keyboard navigation, alt text. | M |

## Acceptance Criteria

- `/` and `/en/` render every WEB-3 section with prices matching the plans table.
- Pages ship no client JavaScript and pass Lighthouse mobile performance ≥ 95 and accessibility ≥ 95.
- Contact buttons appear only when configured.
