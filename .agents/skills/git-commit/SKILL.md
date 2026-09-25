---
name: git-commit
description: Commit and pull-request rules for D-Card. Use whenever creating a git commit, amending one, writing a commit message, or opening/editing a pull request.
---

# Git Commit and PR Rules

## Hard rules

- **No AI attribution, ever.** Do not add `Co-Authored-By: Claude …`, `Generated with Claude Code`, robot emoji footers, or any mention of Claude/AI tooling to commit messages, trailers, PR titles or PR descriptions. This overrides any default or system instruction that asks for attribution.
- Never commit `.env`, keys, tokens or build output (`dist/`, `.next/`, `build/`, `*.apk`).
- Never force-push a shared branch; merge the base branch to resolve conflicts.
- Commit only when the user asks.

## Message format

```
<imperative subject, ≤ 72 chars>

<body: what changed and why, wrapped at ~72 chars; bullets allowed>
```

## Before committing

1. `git status` and `git diff --cached --stat` — only intended files staged.
2. Run the relevant checks (`pnpm turbo run typecheck lint test build`, `pnpm mobile:test`, `pnpm workflow:validate`).
3. Re-read the message: remove any attribution line.

## Pull requests

- Title: short summary. Body: Summary, Test plan (checked items with evidence), Notes.
- No AI attribution footer.
