# CLAUDE.md

## Project Overview
<!-- One paragraph: what this app does and who it's for. -->

## Tech Stack
- **Language:** Python 3.10+
- **Framework:** [Flask](https://flask.palletsprojects.com)
- **Package manager:** <!-- uv / pip / poetry -->
- **Database:** <!-- e.g. PostgreSQL via SQLAlchemy, SQLite, none -->
- **Testing:** pytest + pytest-flask

## Key Conventions
- App factory in `<!-- e.g. src/app.py or app/__init__.py -->`
- Blueprints live in `<!-- e.g. src/blueprints/ or app/blueprints/ -->`
- Config classes in `<!-- e.g. src/config.py -->`
- Environment variables loaded via python-dotenv; never hardcode secrets
- <!-- e.g. SQLAlchemy models in src/models/, Marshmallow schemas in src/schemas/ -->

## Development Workflow
```bash
# Run dev server
flask run --debug

# Run tests
pytest

# Run a single test
pytest tests/test_app.py -v

# Lint
ruff check .
```

## Context Loading

Read on every session:
- `CONTEXT.md` — current focus, last decisions, next action

Read when the user mentions tasks, features, bugs, or current work:
- `PLAN.md` — `## Active` section only

Read when touching app structure, routes, models, or architecture:
- `ARCHITECTURE.md` — `## Quick Reference` first; full file only if needed

Load only when explicitly asked about goals or priorities:
- `ROADMAP.md`

Never auto-load:
- `.claude/archive/`

## Behavior Rules
- Do not create `BACKLOG.md`, `TASKS.md`, `TODO.md` — use `PLAN.md`
- When making an architectural decision (new blueprint, auth strategy, data model), record it with `/log`
- Use the app factory pattern — never create the app at module level
- Keep `PLAN.md ## Active` short — triage if it exceeds 10 items
