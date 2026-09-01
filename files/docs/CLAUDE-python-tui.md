# CLAUDE.md

## Project Overview
<!-- One paragraph: what this app does and who it's for. -->

## Tech Stack
- **Language:** Python 3.10+
- **TUI framework:** [Textual](https://textual.textualize.io)
- **Package manager:** uv (see Operating Rules)
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
uv run textual run --dev app.py

# Run normally
uv run python app.py

# Open Textual devtools console
uv run textual console

# Run tests
uv run pytest

# Run a single test
uv run pytest tests/test_app.py -v
```

## Operating Rules

### Environment
- Always `uv` with the local `.venv` — never the system Python
- Every command goes through the venv: `uv run pytest`, `uv run textual ...`
- Dependencies change only via `uv add` / `uv remove` — `pyproject.toml` is the single source of truth; never bare `pip install`

### Verification
- Delegate a `textual run --dev` interaction or snapshot check to a forked subagent when its output is large and disposable — only the verdict returns to the main thread
- Keep verification in the main thread when it needs judgment tied to ongoing context the fork won't have — matching intended layout, comparing against a prior iteration
- Never delegate the Debugging sequence's Verify step below — that confirmation runs in the thread that made the fix

### Debugging
Work this sequence — do not improvise tooling:
1. **Reproduce** — smallest command that shows the failure (one test, or one interaction in `textual run --dev`)
2. **Read the full traceback** — before forming a hypothesis
3. **Isolate** — narrow with existing tests and `git diff`/`git log`; bisect if the regression point is unknown
4. **Instrument** — the app owns stdout, so no `print()`/`breakpoint()` in a running TUI: use `self.log()` and watch it in `textual console`; remove instrumentation once fixed
5. **Never add a dependency to debug** — existing tools only
6. **Verify** — run `uv run pytest` yourself and confirm a zero exit code; a fix isn't done until the real command passes, not your read of the output

## Behavior Rules
- Prefer composing existing Textual built-ins over custom implementations
- When making an architectural decision (new screen, widget pattern, state model), record it with `/log`
<!-- Add project-specific rules here. Workflow rules (context loading, commits, plan hygiene) live in .claude/claudify.md. -->
