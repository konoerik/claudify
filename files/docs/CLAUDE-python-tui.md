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

## Behavior Rules
- Prefer composing existing Textual built-ins over custom implementations
- When making an architectural decision (new screen, widget pattern, state model), record it with `/log`
<!-- Add project-specific rules here. Workflow rules (context loading, commits, plan hygiene) live in .claude/claudify.md. -->
