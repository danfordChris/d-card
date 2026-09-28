# AGENTS.md

Project agent instructions for **D-Card** (digital event invitation cards, Tanzania).

## Workflow Authority

- Canonical workflow policy: `.agents/workflows/workflow-contract/spec/*`
- Canonical validator: `python3 .agents/workflows/workflow-contract/scripts/validate_workflow.py`

## Start Here

1. Classify the task.
2. Run `python3 .agents/workflows/workflow-contract/scripts/validate_workflow.py`.
3. Read `docs/design/`.
4. Read `docs/implementation/`.
5. If the effort is large and foggy, read or create `docs/changes/wayfinding/`.
6. If behavior is unresolved but already concrete, read or create `docs/changes/proposed/`.
7. Load required repo skill(s).
8. Inspect target service code before editing.

## Documentation Workflow

Use `$workflow` for design docs, implementation docs, wayfinding, backlog/phase/task/status updates, proposals, reconciliation and validator failures.

Layer rules:

- `docs/design/`: approved product/system truth.
- `docs/adr/`: hard-to-reverse decisions.
- `docs/implementation/`: execution plans, phases, tasks, feature inventory and status only.
- `docs/changes/wayfinding/`: unresolved decision maps for large efforts only.
- `docs/changes/proposed/`: unresolved proposals only.
- `docs/research/`: sourced market/provider facts; reference only, not truth.

Do not define net-new behavior in implementation docs. Put unresolved behavior in `docs/changes/proposed` until accepted.

## Project Constraints

- Stack: Next.js (web + API), Flutter (apps `mobile` and `door`), PostgreSQL + Drizzle, Redis + BullMQ, Firebase Auth. See `docs/adr/0003-technical-stack.md`.
- Flutter local storage: sqflite (`sqflite_sqlcipher`) and `shared_preferences` only. Never Hive.
- Payments: Snippe. SMS: NextSMS. WhatsApp: Meta Cloud API. Media: host's Google Drive (no media on D-Card servers).
- Phone numbers: always stored as `255` + 9 digits.
- Research market practice before recording a new product decision.

## Git Commits and Pull Requests

- **Never** add Claude, Claude Code or any AI tool as author, co-author or attribution in commits or PRs: no `Co-Authored-By:` trailers, no "Generated with Claude Code" lines, no AI footers.
- Commit messages: short imperative subject (≤ 72 chars), blank line, body explaining what and why.
- Commit only when asked; never force-push shared branches; never commit `.env` or secrets.
- Enforced by `.claude/settings.json` (`attribution.commit` and `attribution.pr` set to `""`) and the `git-commit` skill.
