---
description: Commit staged/intended changes following D-Card rules (no AI attribution)
---

Create a git commit for the current changes following `.agents/skills/git-commit/SKILL.md`:

1. Show `git status` and stage only the files that belong to this change (never `.env`, secrets or build output).
2. Run the checks relevant to the changed areas.
3. Write the message: imperative subject ≤ 72 chars, blank line, body with what and why.
4. **Do not add any `Co-Authored-By` trailer, "Generated with Claude Code" line, or other AI attribution.**
5. Commit, then show `git log --oneline -1`.

Extra instructions from the user: $ARGUMENTS
