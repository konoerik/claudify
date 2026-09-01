# CLAUDE.md

## Project Overview
<!-- One paragraph: what this app does and who it's for. -->

## Tech Stack
- **Language:** Python 3.10+
- **Framework:** [Flask](https://flask.palletsprojects.com)
- **Package manager:** uv (see Operating Rules)
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
uv run flask run --debug

# Run tests
uv run pytest

# Run a single test
uv run pytest tests/test_app.py -v

# Lint
uv run ruff check .
```

## Operating Rules

### Environment
- Always `uv` with the local `.venv` — never the system Python
- Every command goes through the venv: `uv run pytest`, `uv run flask ...`
- Dependencies change only via `uv add` / `uv remove` — `pyproject.toml` is the single source of truth; never bare `pip install`

### Verification
- Delegate a Playwright/browser check to a forked subagent when its output is large and disposable (a screenshot, a full DOM dump) — only the verdict ("renders correctly" / "500 on submit, see console error X") returns to the main thread
- Keep verification in the main thread when it needs judgment tied to ongoing context the fork won't have — matching stakeholder intent, comparing against a prior iteration
- Never delegate the Debugging sequence's Verify step below — that confirmation runs in the thread that made the fix

### Debugging
Work this sequence — do not improvise tooling:
1. **Reproduce** — smallest command that shows the failure (one test, one `curl` request) before changing anything
2. **Read the full traceback** — before forming a hypothesis
3. **Isolate** — narrow with existing tests and `git diff`/`git log`; bisect if the regression point is unknown
4. **Instrument** — stdlib only: `app.logger`, `breakpoint()`; remove instrumentation once fixed
5. **Never add a dependency to debug** — no debug toolbars or helper packages; existing tools only
6. **Verify** — run `uv run pytest` yourself and confirm a zero exit code; a fix isn't done until the real command passes, not your read of the output

## Behavior Rules
- Use the app factory pattern — never create the app at module level
- When making an architectural decision (new blueprint, auth strategy, data model), record it with `/log`
<!-- Add project-specific rules here. Workflow rules (context loading, commits, plan hygiene) live in .claude/claudify.md. -->
