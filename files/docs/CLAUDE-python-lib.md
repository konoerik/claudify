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

## Behavior Rules
- Never add a runtime dependency without discussion — keep the dependency footprint small
- When making an architectural decision (API shape, dependency policy, compatibility boundary), record it with `/log`
<!-- Add project-specific rules here. Workflow rules (context loading, commits, plan hygiene) live in .claude/claudify.md. -->
