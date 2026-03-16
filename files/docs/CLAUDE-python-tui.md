# CLAUDE.md

## Project Overview
<!-- One paragraph: what this app does and who it's for. -->

## Tech Stack
- **Language:** Python 3.10+
- **TUI framework:** [Textual](https://textual.textualize.io)
- **Package manager:** <!-- uv / pip / poetry -->
- **Testing:** pytest + `textual.testing.AppTest`

## Key Conventions
- App entry point is `<!-- e.g. src/app.py or app.py -->`
- Screens live in `<!-- e.g. src/screens/ -->`
- Widgets live in `<!-- e.g. src/widgets/ -->`
- Styles live in `<!-- e.g. src/app.tcss -->` — prefer TCSS over inline styles
- Use `reactive` attributes for state; avoid direct DOM mutation outside of watchers
- Message passing over direct method calls between widgets

## Development Workflow
```bash
# Run in dev mode (hot reload + Textual devtools)
textual run --dev app.py

# Run normally
python app.py

# Open Textual devtools console
textual console

# Run tests
pytest

# Run a single test
pytest tests/test_app.py -v
```

## Context Loading

Read on every session:
- `docs/CONTEXT.md` — current focus, last decisions, next action

Read when the user mentions tasks, features, bugs, or current work:
- `docs/PLAN.md` — `## Active` section only

Read when touching app structure, widgets, screens, or architecture:
- `docs/ARCHITECTURE.md` — `## Quick Reference` first; full file only if needed

Load only when explicitly asked about goals or priorities:
- `docs/ROADMAP.md`

Never auto-load:
- `.claude/archive/`

## Behavior Rules
- Do not create `BACKLOG.md`, `TASKS.md`, `TODO.md` — use `PLAN.md`
- When making an architectural decision (new screen, widget pattern, state model), record it with `/log`
- Prefer composing existing Textual built-ins over custom implementations
- Keep `PLAN.md ## Active` short — triage if it exceeds 10 items
