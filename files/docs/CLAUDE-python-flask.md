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

## Behavior Rules
- Use the app factory pattern — never create the app at module level
- When making an architectural decision (new blueprint, auth strategy, data model), record it with `/log`
<!-- Add project-specific rules here. Workflow rules (context loading, commits, plan hygiene) live in .claude/claudify.md. -->
