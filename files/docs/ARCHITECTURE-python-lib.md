# Architecture

## Quick Reference
**Stack:** Python 3.10+
**Entry point:** <!-- e.g. src/mylib/__init__.py -->
**Key paths:** <!-- e.g. src/mylib/, tests/ -->
**Key constraints:** <!-- e.g. no mandatory external dependencies, Python 3.10–3.13 support -->
**Patterns:** <!-- e.g. functional core, thin adapters, explicit public API via __all__ -->


## Decisions (ADRs)
<!-- Append new ADRs with /decide -->


## Detail

### Module structure
```
<!-- Fill in your project layout, e.g.:
src/
└── mylib/
    ├── __init__.py     # Public API — explicit __all__
    ├── _core.py        # Internal implementation
    └── _utils.py       # Internal helpers
tests/
└── test_core.py
-->
```

### Public API
<!-- List public symbols, their purpose, and any stability guarantees. -->

### Compatibility and versioning
<!-- Supported Python versions, deprecation policy, semver rules. -->
