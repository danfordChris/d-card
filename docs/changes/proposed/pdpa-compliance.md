# Personal Data Protection Act 2022 Compliance

## Status

proposed

## Context

- D-Card stores guest names and phone numbers, contribution amounts, check-in records and (via Firebase) login data held by Google.
- MVP privacy basics are already in design: `docs/design/features/privacy-and-audit.md`.

## Problem

- Legal obligations are unconfirmed: PDPC registration, consent wording, data-controller role (host vs D-Card), cross-border transfer (Google, Meta, Firebase).

## Proposed Change

- Legal adviser reviews the design before launch.
- Adopt resulting obligations into `docs/design/features/privacy-and-audit.md`.
