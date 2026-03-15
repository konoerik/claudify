# CLAUDE.md

## Project Overview
<!-- One paragraph: what this project is, what it does, who it's for. -->

## Tech Stack
<!-- Language, framework, key dependencies, deployment target. -->

## Key Conventions
<!-- Coding style, naming rules, patterns to follow or avoid. -->

## Development Workflow
<!-- How to run, test, build. Commands the assistant will need. -->
```bash
# run:
# test:
# build:
# lint:
```

## Context Loading

Read on every session:
- `CONTEXT.md` — current focus, last decisions, next action

Read when the user mentions tasks, features, bugs, or current work:
- `PLAN.md` — `## Active` section only

Read when touching code structure, patterns, or making architectural decisions:
- `ARCHITECTURE.md` — `## Quick Reference` section first; load full file only if needed

Load only when explicitly asked about goals or priorities:
- `ROADMAP.md`

Never auto-load:
- `.claude/archive/`

## Behavior Rules
- Prefer editing existing files over creating new ones
- Do not create `BACKLOG.md`, `TASKS.md`, `TODO.md`, or similar — use `PLAN.md`
- When making an architectural decision, record it with `/log` before ending the session
- Keep `PLAN.md ## Active` short — if it exceeds 10 items, triage before adding more
