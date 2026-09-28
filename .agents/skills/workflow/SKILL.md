---
name: workflow
description: Companion reference for repositories that intentionally adopt the workflow contract, including generation of PRD and TRD artifacts without violating layer boundaries; do not treat this as canonical over the repository's own `spec/*`.
---

# Workflow Contract Companion

Use this only as companion guidance. The repository's own workflow spec remains authoritative.

## Canonical Sources

Read in this order before making any change:

1. `.agents/workflows/workflow-contract/spec/workflow-spec.md` — operating loop, agent modes, layer rules, content style
2. `.agents/workflows/workflow-contract/spec/guardrails-spec.md` — hard rules and enforcement categories
3. `.agents/workflows/workflow-contract/spec/lifecycle-spec.md` — state transitions, readiness gate, completion gate
4. `.agents/workflows/workflow-contract/spec/task-spec.md` — minimum viable task standard (required when creating or updating tasks)
5. `.agents/workflows/workflow-contract/spec/feature-inventory-spec.md` — platform feature register: statuses, layer rules, update triggers (required when adding a feature or changing a phase/task status)

## Step 1: Classify

Identify three things before touching any file.

**Layer:**
- `design` — approved product/system truth
- `implementation` — execution planning: project, phases, tasks, status
- `changes/wayfinding` — unresolved decision maps for large efforts
- `changes/proposed` — unresolved ideas and proposals

**Lifecycle state:**
- Idea → Wayfinding → Proposed → Adopted → Planned → Active → Reported → Reconciled
- Identify where the work currently sits and which transition it must make.

**Agent mode:**
- `Thinking` — producing design docs, task definitions, proposals. No code changes.
- `Execution` — implementing against a prepared task. Task must pass readiness gate before starting.
- `Review` — reconciling output against design truth. Detecting and surfacing drift.

Do not proceed until all three are identified.

## Step 2: Bootstrap

If workflow structure is missing, run:

```
python3 .agents/workflows/workflow-contract/scripts/init_workflow_contract.py
```

## Step 3: Apply Layer Rules

- Large foggy efforts → `docs/changes/wayfinding/` first.
- New behavior not present in design → `docs/changes/proposed/` first.
- Execution work → `docs/implementation/` only after design truth exists in `docs/design/`.
- Status updates → `docs/implementation/status/` only.
- Feature-level status rollup → `docs/implementation/feature-inventory/` (one directory per feature, one file per subfeature; created from `templates/feature-inventory/`). Update a subfeature `Status` whenever a linked phase or task changes state; add a feature directory or subfeature file whenever a proposal is adopted into `docs/design/`.
- No duplicate truth across layers.

## Step 3A: Generate PRD And TRD In The Correct Layers

When the user asks for a PRD, TRD, or both, map them into this workflow as follows:

- `PRD` → product and behavior truth in `docs/design/`
- `TRD` → execution and technical delivery plan in `docs/implementation/`

Do not collapse them into one document.

### PRD placement

Place the PRD in `docs/design/` using a feature-specific file name.

Examples:

- `docs/design/<feature>.md`
- `docs/design/<domain>/<feature>.md`

### TRD placement

Place the TRD in `docs/implementation/` using a planning-oriented file name.

Examples:

- `docs/implementation/<feature>.md`
- `docs/implementation/phases/<feature>.md`
- `docs/implementation/tasks/<feature>.md` when the request is already task-shaped

### Boundary

- PRD defines user problems, product behavior, constraints, acceptance truth, and domain rules.
- TRD defines architecture approach, sequencing, scope slices, dependencies, rollout, verification, and task breakdown.
- PRD must not contain status tracking, checklists for execution, or sprint/task management.
- TRD must not invent net-new product behavior that is absent from the PRD or an accepted proposal.

## Step 3B: PRD Minimum Shape

Use this shape when generating a PRD unless the repository already has a stricter design template:

```md
# <Feature Name> PRD

## Objective

One sentence describing the concrete user or business outcome.

## Problem

- Current user or business pain
- Existing constraints
- Why the change matters now

## Scope

### In Scope

- Explicit behaviors and surfaces covered by this PRD

### Out Of Scope

- Explicit exclusions

## User Outcomes

- Observable user-facing results

## Requirements

- Functional requirements
- Business rules
- Edge cases and constraints

## Acceptance Truth

- Binary statements that define when the intended behavior is correct

## Open Questions

- Only unresolved items that still need a decision
```

## Step 3C: TRD Minimum Shape

Use this shape when generating a TRD unless the repository already has a stricter implementation template:

```md
# <Feature Name> TRD

## Objective

One sentence describing the delivery outcome of this technical work.

## Scope Boundary

- In-scope modules, services, or document areas
- Explicit out-of-scope boundaries

## Design Inputs

- PRD path
- Accepted proposals
- ADRs or existing contracts

## Technical Approach

- Architecture decisions
- Data model or API implications
- Integration points
- Migration or compatibility notes

## Delivery Plan

- Ordered implementation slices
- Dependencies and blockers
- Rollout notes if relevant

## Acceptance Criteria

- Binary technical completion conditions

## Verification

- Commands, tests, or review evidence required
```

## Step 3D: Generation Order

When both artifacts are requested:

1. Generate or update the PRD first.
2. Confirm the TRD derives from that PRD and existing repo truth.
3. Generate or update the TRD second.

If requirements are still foggy:

- start in `docs/changes/wayfinding/` for large unclear efforts
- start in `docs/changes/proposed/` for concrete but unresolved behavior
- do not generate a TRD that pretends unresolved product decisions are settled

## Step 4: Task Readiness

Required when creating or updating any task doc. Read `.agents/workflows/workflow-contract/spec/task-spec.md`.

A task is ready for execution only when all sections are populated:

| Section | Required content |
|---|---|
| `Objective` | One sentence: concrete, verifiable outcome |
| `Scope Boundary` | Explicit in-scope paths/modules and out-of-scope boundaries |
| `Acceptance Criteria` | Binary, judgment-free conditions referencing specific endpoints, files, or behaviors |
| `Agent Context` | Skills to load, design docs to read, constraints, do-not-touch paths |
| `Session Budget` | Mode, stop conditions, handoff trigger |
| `Implementation Checklist` | Ordered steps |
| `Verification` | Command and evidence |

Do not set status to `in-progress` until all sections are populated.

## Step 5: Validate

Run before marking any doc task complete:

```
python3 .agents/workflows/workflow-contract/scripts/validate_workflow.py
```

Validator categories:

| Category | Failure means |
|---|---|
| `STRUCTURE` | Required path missing or disallowed path present |
| `METADATA` | Required section heading absent from a doc |
| `READINESS` | `in-progress` task lacks acceptance criteria, scope boundary, or session budget; `done` task lacks verification |
| `SCOPE` | Two `in-progress` tasks claim the same scope entry |
| `TRANSITIONS` | Invalid status value in a proposal doc |
| `REFERENCES` | Legacy path reference found in codebase |

Fix all failures before completion. Do not suppress or skip.
