# CLAUDE.md

## Project Overview
<!-- One paragraph: what this library does, what problem it solves, who uses it. -->

## Tech Stack
- **Language:** Python 3.10+
- **Package manager:** <!-- uv / pip / poetry -->
- **Testing:** pytest
- **Distribution:** <!-- PyPI / internal / private -->

## Key Conventions
- Public API lives in `<!-- e.g. src/mylib/__init__.py -->`
- Keep public surface minimal — prefer explicit `__all__`
- Semantic versioning: bump patch for fixes, minor for new public API, major for breaking changes
- <!-- e.g. type hints required on all public functions, docstrings in Google style -->

## Development Workflow
```bash
# Install in editable mode
pip install -e ".[dev]"

# Run tests
pytest

# Run tests with coverage
pytest --cov

# Lint and type-check
ruff check .
mypy src/
```

## Context Loading

Read on every session:
- `CONTEXT.md` — current focus, last decisions, next action

Read when the user mentions tasks, features, bugs, or current work:
- `PLAN.md` — `## Active` section only

Read when touching public API, module structure, or versioning:
- `ARCHITECTURE.md` — `## Quick Reference` first; full file only if needed

Load only when explicitly asked about goals or priorities:
- `ROADMAP.md`

Never auto-load:
- `.claude/archive/`

## Behavior Rules
- Do not create `BACKLOG.md`, `TASKS.md`, `TODO.md` — use `PLAN.md`
- When making an architectural decision (API shape, dependency policy, compatibility boundary), record it with `/decide`
- Never add a runtime dependency without discussion — keep the dependency footprint small
- Keep `PLAN.md ## Active` short — triage if it exceeds 10 items
