# CLAUDE.md

## Project Overview
<!-- One paragraph: what this script/tool does and who it's for. -->

## Tech Stack
- **Language:** Python 3.10+
- **Dependencies:** Standard library only
- **Testing:** unittest (built-in)

## Key Conventions
- Entry point: `main.py` (single script) or `package/__main__.py` (multi-module)
- CLI interface via `argparse` — `parse_args()` accepts `argv` for testability
- No external packages — if you think you need one, discuss before adding
- <!-- e.g. config loaded from JSON via pathlib, output written to stdout -->

## Development Workflow
```bash
# Run as script
uv run python main.py --help

# Run as package
uv run python -m mypackage

# Run all tests
uv run python -m unittest discover

# Run a specific test module
uv run python -m unittest tests.test_module -v
```

## Operating Rules

### Environment
- Pin the interpreter with `uv` and a local `.venv` (`uv venv`) — never whatever `python3` happens to resolve to
- Every command goes through it: `uv run python ...`
- No packages, period — `uv add` / `pip install` are never valid moves; if a problem seems to need one, discuss first

### Verification
- Delegate a verbose script or CLI run to a forked subagent when the output is long and disposable — only the relevant result or error returns to the main thread
- Keep verification in the main thread when the result needs judgment tied to ongoing context, not just pass/fail
- Never delegate the Debugging sequence's Verify step below — that confirmation runs in the thread that made the fix

### Debugging
Work this sequence — do not improvise tooling:
1. **Reproduce** — smallest command that shows the failure (one unittest case, one CLI invocation)
2. **Read the full traceback** — before forming a hypothesis
3. **Isolate** — narrow with existing tests and `git diff`/`git log`; bisect if the regression point is unknown
4. **Instrument** — `logging`, `breakpoint()`, `traceback.print_stack()`; remove instrumentation once fixed
5. **Never add a dependency to debug** — the stdlib-only rule has no debugging exception
6. **Verify** — run `uv run python -m unittest discover` yourself and confirm a zero exit code; a fix isn't done until the real command passes, not your read of the output

## Behavior Rules
- stdlib only — no pip, no requirements.txt with runtime dependencies
- When making a structural decision (splitting into a package, adding a module), record it with `/log`
<!-- Add project-specific rules here. Workflow rules (context loading, commits, plan hygiene) live in .claude/claudify.md. -->
