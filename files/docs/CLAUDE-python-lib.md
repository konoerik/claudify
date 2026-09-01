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

### Verification
- Delegate a verbose test run or coverage report to a forked subagent when the output is long and disposable — only the pass/fail summary and any failure detail returns to the main thread
- Keep verification in the main thread when a failure needs judgment tied to ongoing context, not just pass/fail
- Never delegate the Debugging sequence's Verify step below — that confirmation runs in the thread that made the fix

### Debugging
Work this sequence — do not improvise tooling:
1. **Reproduce** — write the failing test first; it becomes the regression test
2. **Read the full traceback** — before forming a hypothesis
3. **Isolate** — narrow with the existing suite and `git diff`/`git log`; bisect if the regression point is unknown
4. **Instrument** — stdlib only: `logging`, `breakpoint()`; remove instrumentation once fixed
5. **Never add a dependency to debug** — existing tools only
6. **Verify** — run `uv run pytest` yourself and confirm a zero exit code; a fix isn't done until the real command passes, not your read of the output

## Behavior Rules
- Never add a runtime dependency without discussion — keep the dependency footprint small
- When making an architectural decision (API shape, dependency policy, compatibility boundary), record it with `/log`
<!-- Add project-specific rules here. Workflow rules (context loading, commits, plan hygiene) live in .claude/claudify.md. -->
