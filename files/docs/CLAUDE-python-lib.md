# CLAUDE.md

## Project Overview
<!-- One paragraph: what this library does, what problem it solves, who uses it. -->

## Tech Stack
- **Language:** Python 3.10+
- **Package manager:** uv (see Operating Rules)
- **Testing:** pytest
- **Distribution:** <!-- PyPI / internal / private -->

## Key Conventions
- Public API lives in `<!-- e.g. src/mylib/__init__.py -->`
- Keep public surface minimal — prefer explicit `__all__`
- Semantic versioning: bump patch for fixes, minor for new public API, major for breaking changes
- <!-- e.g. type hints required on all public functions, docstrings in Google style -->

## Development Workflow
```bash
# Install the environment (editable, with dev extras)
uv sync

# Run tests
uv run pytest

# Run tests with coverage
uv run pytest --cov

# Lint and type-check
uv run ruff check .
uv run mypy src/
```

## Operating Rules

### Environment
- Always `uv` with the local `.venv` — never the system Python
- Every command goes through the venv: `uv run pytest`, `uv run mypy ...`
- Dependencies change only via `uv add` / `uv remove` — `pyproject.toml` is the single source of truth; never bare `pip install`

### Debugging
Start by writing a failing test that reproduces the bug — it becomes the regression test — and read the full traceback before forming a hypothesis. Debug with stdlib tools (`logging`, `breakpoint()`), the existing suite, `git diff`/`git log`, and bisect when the regression point is unknown; never add a dependency to debug. Remove instrumentation once fixed. A fix is done when you have run `uv run pytest` yourself and it exits 0, not when the output looks right.

## Behavior Rules
- Never add a runtime dependency without discussion — keep the dependency footprint small
- When making an architectural decision (API shape, dependency policy, compatibility boundary), record it with `/log`
<!-- Add project-specific rules here. Workflow rules (context loading, commits, plan hygiene) live in .claude/claudify.md. -->
