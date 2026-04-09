# Architecture

## Quick Reference
**Stack:** Python 3.10+, stdlib only
**Entry point:** <!-- `main.py` or `package/__main__.py` -->
**Key paths:** <!-- e.g. main.py, lib/parser.py, tests/ -->
**Key constraints:** No external dependencies; CLI via argparse


## Decisions (ADRs)
<!-- Append new ADRs with /log -->


## Detail

### Structure
```
<!-- Fill in your layout, e.g. single script:
main.py
tests/
└── test_main.py

or multi-module:
mypackage/
├── __init__.py       # public API
├── __main__.py       # entry point: python -m mypackage
├── cli.py            # argparse setup
└── core.py           # business logic
tests/
└── test_core.py
-->
```

### CLI interface
<!-- Key arguments, subcommands, input/output behaviour. -->

### Data flow
<!-- How data enters (stdin, file, args), is processed, and exits (stdout, file, exit code). -->
