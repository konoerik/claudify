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
python main.py --help

# Run as package
python -m mypackage

# Run all tests
python -m unittest discover

# Run a specific test module
python -m unittest tests.test_module -v
```

## Behavior Rules
- stdlib only — no pip, no requirements.txt with runtime dependencies
- When making a structural decision (splitting into a package, adding a module), record it with `/log`
<!-- Add project-specific rules here. Workflow rules (context loading, commits, plan hygiene) live in .claude/claudify.md. -->
